restoredefaultpath
clc; clear; close all force;

base_path = fullfile('C:\Users\Vincent\Desktop\work_dir');
out_path = fullfile(base_path, 'output'); addpath(out_path);
sub_list_file = fullfile(out_path, 'subjects.list'); %  subjects_suit.list
et_data_path = fullfile(base_path,'ET_fmriprep_anat_20.2.0','fmriprep'); addpath(et_data_path); 
pd_data_path = fullfile(base_path,'PD_fmriprep_anat_20.2.0','fmriprep'); addpath(pd_data_path); 
nc_data_path = fullfile(base_path,'NC_fmriprep_anat_20.2.0','fmriprep'); addpath(nc_data_path); 
output_path  = fullfile(out_path, 'res_SUIT'); addpath(output_path);

spm_path = fullfile(out_path, 'm_tools', 'spm12'); addpath(spm_path);
atlas_path = fullfile(out_path, 'm_tools', 'atlasPackage', 'atlasesMNI'); addpath(atlas_path);
%% constants
atlas_MDTB10=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/MDTB_10Regions.nii');
atlas_SUIT=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/Lobules-SUIT.nii');

atlas='SUIT'; % atlas='SUIT';
switch atlas
    case 'MDTB', curr_atlas=atlas_MDTB10; curr_atlas_str='iw_MDTB_10Regions_u_a_';
    otherwise, curr_atlas = atlas_SUIT; curr_atlas_str='iw_Lobules-SUIT_u_a_';
end
Vatlas=spm_vol(curr_atlas);X=spm_read_vols(Vatlas); num_lobules = max(X(:));
data=tdfread(sub_list_file,'\t'); data.n_sub=length(data.age); data.lobules={};
roi_tab = NaN(data.n_sub, num_lobules);

%% sub list, unzip all nii.gz to .nii
data.t1_in={}; data.nii_out={}; data.t1_name={}; 
for i_ = 1:data.n_sub
    %disp([num2str(i_),' ,unziping ' data.id(i_,:)]);
    if data.diagnosis(i_,:)=='PD'
        sub_dir = fullfile(pd_data_path, data.id(i_,:), 'ses-1','anat');
    elseif data.diagnosis(i_,:)=='ET'
        sub_dir = fullfile(et_data_path, data.id(i_,:), 'ses-1','anat');
    elseif data.diagnosis(i_,:)=='NC'
        sub_dir = fullfile(nc_data_path, data.id(i_,:), 'ses-1','anat');
    else
        disp('new type: ',  data.diagnosis(i_,:))
    end
    if strcmp(data.id(i_,:),'sub-0109') | strcmp(data.id(i_,:),'sub-0129') | ...
            strcmp(data.id(i_,:),'sub-1000') | strcmp(data.id(i_,:),'sub-0134')| strcmp(data.id(i_,:),'sub-0073') | ...
            strcmp(data.id(i_,:),'sub-0085') 
        t1_name = [data.id(i_,:) '_ses-1_desc-preproc_T1w.nii.gz'];
    else
        t1_name = [data.id(i_,:) '_ses-1_run-1_desc-preproc_T1w.nii.gz'];
    end
    data.t1_name{end+1}=t1_name(1:end-7);
    data.t1_in{end+1}=fullfile(sub_dir, t1_name); data.nii_out{end+1}=fullfile(output_path, t1_name(1:end-3));
    %gunzip(t1_name, output_path); % unzip nii.gz -> .nii
end

%% initialize spm
spm fmri
data.roi={}; data.mask={}; data.roi_sum={};
data.gm={}; data.wm={}; data.aff={}; data.deform={}; 
data.nii_suit={};
% normalization
for i_ = 1:data.n_sub
    tic
    disp(['isolateing + normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.id(i_,:)]);
    image_str = data.t1_name{i_}; image_file = data.nii_out{i_}; 
    data.gm{end+1}=[image_str,'_seg1.nii'];  data.wm{end+1}=[image_str,'_seg2.nii']; data.mask{end+1}=['c_', image_str,'_pcereb.nii'];
    data.aff{end+1} = ['Affine_', image_str,'_seg1.mat']; data.deform{end+1} = ['u_a_', image_str,'_seg1.nii'];
    data.roi_sum{end+1}=fullfile( output_path, [image_str, '_roi.txt']);
    %suit_isolate_seg({image_file}); % segmentation: cerebelum isolation
    % normalize to SUIT space, generate affine and deformation field.
    job_n.subjND(i_).gray={fullfile(output_path,data.gm{i_})}; 
    job_n.subjND(i_).white={ fullfile(output_path,data.wm{i_})};
    job_n.subjND(i_).isolation={fullfile(output_path,data.mask{i_})}; 
    toc
end
%suit_normalize_dartel(job_n) % map subject space -> SUIT space

% Rerun segmentation and normalization for origin problem subjects:
% Run1: ['sub-0004','sub-0030','sub-0035','sub-0098','sub-0125','sub-0132','sub-0081', 'sub-0119','sub-0122',...
%    'sub-0134','sub-0140','sub-0141','sub-0142','sub-0143','sub-1012','sub-1230']
% Run2: err_sub=['sub-0004','sub-1450','sub-1500', 'sub-1920', 'sub-2400', 'sub-3700', 'sub-3900', 'sub-0041', 'sub-0102', 'sub-0108'];
%atlas='SUIT';
% Run3: err_sub=['sub-0041'];
% Run4
err_sub=['sub-1500'];
err_ind=[];
k=1;
for i_ = 1:data.n_sub
    if contains(err_sub,data.id(i_,:))
        err_ind(end+1)=i_;
        tic
        disp([num2str(i_),'  i  ------  k  ',int2str(k)])
        suit_isolate_seg({data.nii_out{i_}},'maskp', 100); % segmentation: cerebelum isolation
        disp(['normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.id(i_,:)]);
        %normalize to SUIT space, generate affine and deformation field.
        aajob_err.subjND(k).gray={fullfile(output_path,data.gm{i_})}; 
        job_err.subjND(k).white={ fullfile(output_path,data.wm{i_})};
        job_err.subjND(k).isolation={fullfile(output_path,data.mask{i_})}; 
        k=k+1;
        toc
    end
end
suit_normalize_dartel(job_err) % map subject space -> SUIT space
i_=err_ind(1);
disp(['registering to atlas ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.id(i_,:)]);
job_s.Affine={fullfile(output_path,data.aff{i_})};
job_s.flowfield={fullfile(output_path,data.deform{i_})};
job_s.resample={curr_atlas};
job_s.ref={fullfile(output_path, data.gm{i_})};
suit_reslice_dartel_inv(job_s); % registration from atlas to individual
    
% fix single subject normalization: sub-002
% for i_=1:length(err_ind)
%     job_norm1.subjND(1).gray={fullfile(output_path,data.gm{i_})}; 
%     job_norm1.subjND(1).white={ fullfile(output_path,data.wm{i_})};
%     job_norm1.subjND(1).isolation={fullfile(output_path,data.mask{i_})}; 
%     suit_normalize_dartel(job_norm1)
% end
%% DBM and atlas to individual.
% for i_ = 1:data.n_sub
%     %disp(['applying normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.id(i_,:)]);
%     data.nii_suit{end+1}=fullfile(output_path,['wd',data.gm{i_}]);
%     %% DBM: sub2atlas, run for whole group after this loop.
%     job_a.subj(i_).affineTr={fullfile(output_path,data.aff{i_})};
%     job_a.subj(i_).flowfield={fullfile(output_path,data.deform{i_})};
%     job_a.subj(i_).resample={fullfile(output_path,data.gm{i_})}; 
%     job_a.subj(i_).jactransf=1;
%     job_a.subj(i_).mask={fullfile(output_path,data.mask{i_})};
% end
%suit_reslice_dartel(job_a)

%% register atlas to individual can calculate vol size
for i_ = 1:data.n_sub
    disp(['registering to atlas ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.id(i_,:)]);
    job_s.Affine={fullfile(output_path,data.aff{i_})};
    job_s.flowfield={fullfile(output_path,data.deform{i_})};
    job_s.resample={curr_atlas};
    job_s.ref={fullfile(output_path, data.gm{i_})};
    %tic
    suit_reslice_dartel_inv(job_s); % registration from atlas to individual
    %toc
    V=spm_vol(fullfile(output_path, [curr_atlas_str, data.gm{i_}]));
    X=spm_read_vols(V);
    lobule_vol_=zeros(num_lobules,1);
    for i_lob=1:num_lobules
        lobule_vol_(i_lob) = length(find(X==i_lob));
    end
    roi_tab(i_,:)=lobule_vol_;
    data.lobules{end+1}=lobule_vol_;
end

switch atlas
    case 'MDTB', csvwrite(fullfile(output_path, 'res', 'res_MDTB10.csv'),roi_tab);
    otherwise,   csvwrite(fullfile(output_path, 'res', 'res_SUIT34.csv'),roi_tab);
end

%% test code
%suit_reslice_inv(curr_atlas,fullfile(output_path,data.aff{i_}))

%% old code
% summarize volumes (no idea what we need this function for)
% suit_ROI_summarize(data.nii_suit,'atlas', atlas_MDTB10);
% suit_ROI_summarize(data.nii_suit,'atlas', atlas_SUIT);