import os
import csv
import time
import numpy as np
import pandas as pd

import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.formula.api import glm
import statsmodels.stats as sts
from scipy.stats import ranksums


from os.path import join as opj
from collections import (OrderedDict, namedtuple)

from sklearn.base import clone
from sklearn.utils import Bunch

import nibabel as nib
from nilearn import signal
from nilearn.input_data import NiftiMasker
from nilearn.image import load_img, concat_imgs, mean_img
from sklearn.svm import LinearSVC
from sklearn.pipeline import make_pipeline


#mask_gm = os.path.join(ROOT_FOLDER, 'masks', 'gm_mask_3mm.nii.gz')
#mask_audio_3mm = os.path.join(
#    ROOT_FOLDER, 'masks', 'audio_mask_resampled_3mm.nii.gz')
#language_mask_3mm = os.path.join(
#    ROOT_FOLDER, 'masks', 'left_language_mask_3mm.nii.gz')


# {"decoding_task": "ibc_tonotopy_cond", "alignment_data_label": "53_tasks",
# "roi_code": "fullbrain", "mask": mask_gm}

#WHOLEBRAIN_DATASETS = [{"decoding_task": ["ibc_tonotopy_cond",
#                                          "ibc_rsvp"],
#                        "alignment_data_label": "53_tasks",
#                        "roi_code": "fullbrain", "mask": mask_gm}]

#ROI_DATASETS = [{"decoding_task": "ibc_rsvp", "alignment_data_label": "53_tasks",
#                "roi_code": "language_3mm", "mask": language_mask_3mm},
#                {"decoding_task": "ibc_tonotopy_cond", "alignment_data_label": #"53_tasks",
#                 "roi_code": "audio_3mm", "mask": mask_audio_3mm}]

## my codes
def sum_lr(data, var_list):
    item_left   = [ "Left_"+x  for x in var_list];
    item_right  = [ "Right_"+x for x in var_list];
    for x in var_list:
        data[x] = data['Left_'+x]+ data['Right_'+x];
    return data, var_list+item_left+item_right

def ctr_age(data, y_var):
    from sklearn import linear_model
    import numpy as np
    dat = data.copy(); n_all = dat.shape[0];
    nc_data = dat[dat['diagnosis'] == 'NC']; n_nc = nc_data.shape[0];
    x_nc = np.hstack((np.ones((n_nc,1)),  np.array(nc_data['age']).reshape(-1, 1))); 
    x_all= np.hstack((np.ones((n_all,1)), np.array(dat['age']).reshape(-1, 1)));
    reg_list = []; new_col=[];
    for x in y_var:
        reg = linear_model.LinearRegression()
        y_nc= np.array(nc_data[x]);
        reg.fit(x_nc, y_nc);
        tmp_col = x+"_xa"
        dat[tmp_col] = dat[x]-np.matmul(x_all, reg.coef_)
        new_col.append(tmp_col); 
    return dat, new_col, reg_list

def ctr_conf(data, ctr_var, y_var, method_name):
    from sklearn import linear_model
    import numpy as np
    dat = data.copy(); n_all = dat.shape[0];
    if method_name == 'dpa': # direct proportion adjustment
        new_col=[];
        for x in y_var:
            r_name = x+'_dpa'; new_col.append(r_name);
            dat[r_name] = dat[x]/dat[ctr_var];
        dat_, col_, reg_list_ = ctr_age(dat, new_col);
        return dat_, new_col+col_
    if method_name == 'ppa': # power_corrected_portion
        reg_list = []; new_col=[];
        log_ctr  = np.log10(np.array(dat[ctr_var]));
        x_mat    = np.hstack((np.ones((n_all, 1)), np.reshape(log_ctr, [n_all, 1])))
        for x in y_var:
            reg = linear_model.LinearRegression()
            y = np.log10(np.array(dat[x]));
            reg.fit(x_mat, y);
            tmp_col = x + "_ppa";
            dat[tmp_col] = dat[x]/np.power(dat[ctr_var],reg.coef_[1])
            reg_list.append(reg); new_col.append(tmp_col);
        dat_, col_, reg_list_ = ctr_age(dat, new_col);
        return dat_, new_col+col_, reg_list 
    if method_name == 'rm_norm': #residual based on nc
        nc_data = dat[dat['diagnosis'] == 'NC']; n_nc = nc_data.shape[0];
        x_nc = np.hstack((np.ones((n_nc,1)),  np.array(nc_data[ctr_var]))); 
        x_all= np.hstack((np.ones((n_all,1)), np.array(dat[ctr_var])));
        reg_list = []; new_col=[];
        for x in y_var:
            reg = linear_model.LinearRegression()
            y_nc= np.array(nc_data[x]);
            reg.fit(x_nc, y_nc);
            tmp_col = x+"_rm_norm"
            dat[tmp_col] = dat[x]-np.matmul(x_all[:,1:], reg.coef_[1:])
            #dat[tmp_col+"_rm_norm_resid"] = dat[x]-reg.predict(x_all)
            #dat[tmp_col+"_rm_norm_resid_per"] = (dat[x]-reg.predict(x_all))/dat[x]
            reg_list.append(reg); new_col.append(tmp_col);
        dat_, col_, reg_list_ = ctr_age(dat, new_col);
        return dat_, new_col+col_, reg_list 
    if method_name == 'rm_mean': # classical residual method based on nc
        nc_data = dat[dat['diagnosis'] == 'NC']; n_nc = nc_data.shape[0];
        nc_etiv_mean = np.mean(nc_data[ctr_var]);
        x_nc = np.array(nc_data[ctr_var]).reshape(-1, 1);
        reg_list = []; new_col=[];
        nc_ctr_mean = np.mean(nc_data[ctr_var]);
        for x in y_var:
            reg = linear_model.LinearRegression();
            y_nc= np.array(nc_data[x]);
            reg.fit(x_nc, y_nc);
            tmp_col = x+"_rm_mean"
            dat[tmp_col] = dat[x]-reg.coef_[0]*(dat[ctr_var]-nc_ctr_mean)
            reg_list.append(reg); new_col.append(tmp_col);
        dat_, col_, reg_list_ = ctr_age(dat, new_col);
        return dat_, new_col+col_, reg_list 
    if method_name == 'asm': # allometric scaling coefficient (ASC)
        nc_data = dat[dat['diagnosis'] == 'NC']; n_nc = nc_data.shape[0]; 
        x_nc = np.log10(np.hstack((np.ones((n_nc,1)),  np.array(nc_data[ctr_var]).reshape(-1, 1)))); 
        x_all= np.log10(np.hstack((np.ones((n_all,1)), np.array(dat[ctr_var]).reshape(-1, 1))));
        reg_list = []; new_col=[];
        for x in y_var:
            reg = linear_model.LinearRegression()
            y_nc= np.log10(np.array(nc_data[x]));
            reg.fit(x_nc, y_nc);
            tmp_col = x+"_asm"
            dat[tmp_col] = np.log10(dat[x])-np.matmul(x_all[:,1:], reg.coef_[1:])
            reg_list.append(reg); new_col.append(tmp_col);
        dat_, col_, reg_list_ = ctr_age(dat, new_col);
        return dat_, new_col+col_, reg_list  
    if method_name == 'wdcr':# whole dataset confound regression
        pass
    if method_name == 'propensity_score_matching':# whole dataset confound regression
        pass
    if method_name == 'ipsw':# whole dataset confound regression
        pass
    if method_name == 'counter_balancing':# whole dataset confound regression
        pass
    else:
        print([method_name, ' not supported...'])
        return data,[],[]
    return 1

def glm_test(data, tar_list, model_str):
    res_dict={}
    for var_ in tar_list:
        res_dict[var_]={};
        formula = var_ +model_str
        mod = smf.glm(formula=formula, data=data)
        res = mod.fit()
        res_dict[var_ ] = {'formula':formula, 'res':res};
    return res_dict

def rep_model(glm_dict):
    for k in glm_dict.keys():
        print('\n')
        print(glm_dict[k]['formula'],'\n')
        print(glm_dict[k]['res'].rsquared)
        print(glm_dict[k]['res'].summary())
        print(glm_dict[k]['res'].summary2())
    return glm_dict

def sts_test(tar_list, data_df, stats_cols, alpha, n_permu, method_name):
    """calculate cohen d and wilcoxon test """
    out_df= pd.DataFrame();
    for k in tar_list:
        sample_PD = data_df[data_df['diagnosis'] == 'PD'][[k]];
        sample_ET = data_df[data_df['diagnosis'] == 'ET'][[k]];
        sample_NC = data_df[data_df['diagnosis'] == 'NC'][[k]];
        [test_stat_etnc, p_val_etnc, samples_etnc] = permute_Stats(sample_ET, sample_NC, 'cohen_d', alpha, n_permu, 0); 
        (rs_etnc, p_etnc)=ranksums(sample_ET, sample_NC);
        [test_stat_pdnc, p_val_pdnc, samples_pdnc] = permute_Stats(sample_PD, sample_NC, 'cohen_d', alpha, n_permu, 0);
        (rs_pdnc, p_pdnc)=ranksums(sample_PD, sample_NC);
        [test_stat_etpd, p_val_etpd, samples_etpd] = permute_Stats(sample_ET, sample_PD, 'cohen_d', alpha, n_permu, 0);
        (rs_etpd, p_etpd)=ranksums(sample_ET, sample_PD);
        out_df=out_df.append(
        dict(zip(stats_cols, [k,'ETNC',test_stat_etnc, p_val_etnc, rs_etnc, p_etnc, method_name])), ignore_index=True);
        out_df=out_df.append(
        dict(zip(stats_cols, [k,'PDNC',test_stat_pdnc, p_val_pdnc, rs_pdnc, p_pdnc, method_name])), ignore_index=True);
        out_df=out_df.append(
        dict(zip(stats_cols, [k,'ETPD',test_stat_etpd, p_val_etpd, rs_etpd, p_etpd, method_name])), ignore_index=True);
    return out_df 

def cohen_d(d1, d2):
    # Cohen's d for independent samples with different sample sizes
    import numpy as np
    from math import sqrt
    d1 =np.array(d1); d2 =np.array(d2);
    n1, n2 = len(d1), len(d2) # calculate the size of samples
    s1, s2 = np.var(d1, ddof=1), np.var(d2, ddof=1) # calculate the variance of the samples
    s = sqrt(((n1 - 1) * s1 + (n2 - 1) * s2) / (n1 + n2 - 2)) # calculate the pooled standard deviation
    u1, u2 = np.mean(d1), np.mean(d2) # calculate the means of the samples
    d_coh_val = (u1 - u2) / s; # calculate the effect size
    #print('Cohens d: %.3f' % d_coh_val)
    return d_coh_val

def permute_Stats(sample1, sample2, measure, alpha, reps, is_plot):
    import numpy as np
    np.random.seed(115)
    n1, n2 = map(len, (sample1, sample2));
    data = np.concatenate([sample1, sample2])
    ps = np.array([np.random.permutation(n1+n2) for i in range(reps)])
    xp = data[ps[:, :n1]]; yp = data[ps[:, n1:]]
    if measure == 'cohen_d':
        test_stat = cohen_d(sample1, sample2);
        samples = np.array([cohen_d(k, v) for k,v in zip(xp, yp)]);
    p_val = 2*np.sum(samples >= np.abs(test_stat))/reps;
    #print(measure+' : %.6f' % test_stat, ", p-value = %.6f " % p_val)
    if is_plot == 1:
        import matplotlib.pyplot as  plt
        fig = plt.figure()
        plt.hist(samples, 25, histtype='step')
        plt.axvline(test_stat, c='r')
        plt.axvline(np.percentile(samples, alpha/2), linestyle='--',c='r')
        plt.axvline(np.percentile(samples, 100-alpha/2), linestyle='--',c='r')
    return [test_stat, p_val, samples]

def reformat_df(df, group_name, es_name):
    import statsmodels.stats as sts
    method_name=df['method'].unique();
    voi_name=df[df.method=='covariate']['voi'].unique();
    es_list=[]; p_list=[]; p_multi_list=[];
    for x in method_name:
        es_list_= list(df[(df['group']==group_name)&(df['method']==x)][es_name[0]]);
        p_list_ = list(df[(df['group']==group_name)&(df['method']==x)][es_name[1]]);
        p_multi_list_=sts.multitest.multipletests(p_list_, alpha=alpha/100,
                                                  method='fdr_bh', is_sorted=False, returnsorted=False)[1];
        es_list.append(es_list_); p_list.append(p_list_); p_multi_list.append(p_multi_list_);
    return es_list, p_list, p_multi_list, voi_name, method_name
# reference codes
def _check_srm_params(srm_components, srm_atlas, trains_align, trains_decode):
    """
    * Limit number of components depending on data size
    * Reindex srm_atlas from 1 when masked atlas is not fullsize and some
        labels are not present.
    """
    import nibabel as nib
    if srm_atlas is not None and type(srm_atlas) != nib.nifti1.Nifti1Image:
        n_atlas = len(np.unique(srm_atlas))
        if not n_atlas - 1 == max(srm_atlas):
            i = 1
            for lab in np.unique(srm_atlas):
                srm_atlas[srm_atlas == lab] = i
                i += 1
    else:
        n_atlas = srm_components

    srm_components_ = np.min([srm_components, load_img(
        trains_align[0][0]).shape[-1], load_img(trains_decode[0][0]).shape[-1], n_atlas - 1])

    return srm_components_, srm_atlas

def fetch_resample_basc(mask, scale="444"):
    from nilearn.datasets import fetch_atlas_basc_multiscale_2015
    from nilearn.image import resample_to_img
    basc = fetch_atlas_basc_multiscale_2015()['scale{}'.format(scale)]
    resampled_basc = resample_to_img(basc, mask, interpolation='nearest')
    return resampled_basc