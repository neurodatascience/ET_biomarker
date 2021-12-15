%-----------------------------------------------------------------------
% Job saved on 15-Dec-2021 09:57:23 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
restoredefaultpath
clc; clear; close all force;
% basic directory
base_dir = fullfile('C:\Users\Vincent\Desktop\scratch');
out_dir = fullfile(base_dir, 'output'); addpath(out_dir);
spm_dir = fullfile(out_dir, 'm_tools', 'spm12'); addpath(spm_dir);
% codes and data
image_dir = fullfile(base_dir, 'Augmented_VBM'); addpath(image_dir);
codes_dir =  fullfile(base_dir, 'ET_biomarker', 'stats', 'VBM_matlab'); addpath(codes_dir);
covariate_dir = fullfile(base_dir, 'ET_biomarker', 'tab_data'); addpath(covariate_dir);
vbm_out_dir = fullfile(out_dir, 'vbm_aug_cohort'); addpath(vbm_out_dir);
% files
covariate_file = 'matched_subjectList_vbm.csv';
cerebellum_mask_img = fullfile(spm_dir, 'toolbox', 'suit', 'templates', 'maskMNI.nii,1');
SPM_MAT_FILE = fullfile(vbm_out_dir, 'SPM.mat');

% read subjects/covariates and write the 
data=tdfread(covariate_file, ','); n_sub=length(data.subject);
cat_groups = categorical(cellstr(data.group)); categories(cat_groups);
cnt_cat=countcats(cat_groups);n_et = cnt_cat(1); n_nc = cnt_cat(2); 

%data_tab = struct2table(data); 
% new colomnes 
data.t1={}; data.t1_file={};  data.sex_int = {}; 
data.is_mni={}; data.is_ppmi={}; data.is_adni={}; 
et_images = {};  nc_images = {};
for i_ = 1:n_sub
    subj_str = data.subject(i_,:);
    subj_str = subj_str(~isspace(subj_str));
    data.t1{end+1,1} = [subj_str '_run-1_space-MNI152NLin2009cAsym_res-2_desc-preproc_brain.nii,1'];
    data.t1_file{end+1,1}=fullfile(image_dir, data.t1{end});
    % get ET and NC images
    if data.group(i_,:)=='ET'
        et_images{end+1,1} = data.t1_file{i_, :};
    elseif data.group(i_,:)=='NC'
        nc_images{end+1,1}= data.t1_file{i_, :};
    end
    % create int varible for sex
    if data.sex(i_,:)=='M'
        data.sex_int{end+1,1} = 1;
    elseif data.sex(i_,:)=='F'
        data.sex_int{end+1,1} = 0;
    end
    % create int varible for cohort mni
    if data.cohort(i_,:)=='MNI '
        data.is_mni{end+1,1}=1;
    else
        data.is_mni{end+1,1}=0;
    end
    % create int varible for cohort ppmi
    if data.cohort(i_,:)=='PPMI'
        data.is_ppmi{end+1,1}=1;
    else
        data.is_ppmi{end+1,1}=0;
    end
    % create int varible for cohort adni
    if data.cohort(i_,:)=='ADNI'
        data.is_adni{end+1,1}=1;
    else
        data.is_adni{end+1,1}=0;
    end
end

% init SPM 
spm('Defaults','fMRI'); %Initialise SPM fmri
spm_jobman('initcfg');  %Initialise SPM batch mode

%% configure batch job
% defaut working directory
matlabbatch{1}.spm.stats.factorial_design.dir = {vbm_out_dir};

%% configure 2-sample t-test
% samples:
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = et_images;
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = nc_images;
% statistical models
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
%covariates:
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%% covariate age:
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = data.age;
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 5;
%% covariate sex:
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = cell2mat(data.sex_int);
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'sex';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 5;
%% covariate eTIV:
matlabbatch{1}.spm.stats.factorial_design.cov(3).c = data.eTIV;
matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'eTIV';
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 5;
%% covariate cohort_mni:
matlabbatch{1}.spm.stats.factorial_design.cov(4).c = cell2mat(data.is_mni);
matlabbatch{1}.spm.stats.factorial_design.cov(4).cname = 'mni';
matlabbatch{1}.spm.stats.factorial_design.cov(4).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(4).iCC = 5;
%% covariate cohort_ppmi:
matlabbatch{1}.spm.stats.factorial_design.cov(5).c = cell2mat(data.is_ppmi) ;
matlabbatch{1}.spm.stats.factorial_design.cov(5).cname = 'ppmi';
matlabbatch{1}.spm.stats.factorial_design.cov(5).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(5).iCC = 5;
%% covariate cohort_adni:
matlabbatch{1}.spm.stats.factorial_design.cov(6).c = cell2mat(data.is_adni);
matlabbatch{1}.spm.stats.factorial_design.cov(6).cname = 'adni';
matlabbatch{1}.spm.stats.factorial_design.cov(6).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(6).iCC = 5;
% other configs: no masking or thresholding, no global calculation or
% normalization.
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
% model estimation, methods classic
matlabbatch{2}.spm.stats.fmri_est.spmmat = {SPM_MAT_FILE};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
% Contrast configuration: T contrast NC-ET
matlabbatch{3}.spm.stats.con.spmmat = {SPM_MAT_FILE};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '-ET+NC';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
% Results report: maksing with suit cerebellum mask, FDR@0.05
matlabbatch{4}.spm.stats.results.spmmat = {SPM_MAT_FILE};
matlabbatch{4}.spm.stats.results.conspec.titlestr = 'Comparing ET and NC in the augmented cohort';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'FDR';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.image.name = {cerebellum_mask_img};
matlabbatch{4}.spm.stats.results.conspec.mask.image.mtype = 0;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;

%run
spm_jobman('run', matlabbatch);% tbd 