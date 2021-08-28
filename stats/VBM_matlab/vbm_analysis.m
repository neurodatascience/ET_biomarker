% This script does VBM based on T1w MRIs using the SPM batch
% By Qing Wang (Vincent)
%__________________________________________________________________________
restoredefaultpath
clc; clear; close all force;
% basic path
data_name='PPMI';
base_path = fullfile('C:\Users\Vincent\Desktop\scratch');
out_path = fullfile(base_path, 'output'); addpath(out_path);
codes_dir =  fullfile(base_path, 'ET_biomarker', 'tab_data');
% softwares and tools: SPM12
spm_path = fullfile(out_path, 'm_tools', 'spm12'); addpath(spm_path);

%% study path
sub_list_file = fullfile(codes_dir, [data_name,'_subjects.list']); %  read in: subjects_suit.list
%data input and output
data_path = fullfile(base_path,[data_name,'_fmriprep_anat_20.2.0_T1w']); addpath(data_path); 
output_path  = fullfile(out_path, [data_name,'_VBM_res']); addpath(output_path);

% Parameters
N0      = Inf;                % Inf uses all images
dir_img = '/pth/to/niis';     % data directory (N0 niftis in this directory will be selected)
dir_res = '/pth/to/results';  % results directory
fwhm    = 8;                 % amount of smoothing

%% start software
spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm... = ...;

spm_jobman('run',matlabbatch);

-------------------------


sex1=ones(height(sex),1);
for i_=1:height(sex)
    if sex{i_,1}=='F'
        sex1(i_)=0;
    end
end


spm fmri
% Age and sex are covariates, as we here do not have these values, we just 
% pick some random numbers. When specifying them, ensure that they are in
% the same order as the input files read on line 24.

% read age and sex
sex = rand(N0,1);
age = rand(N0,1);

%% 1. Unified segmentation
% Normalises+segments the input images, which will be written prefixed 
% mwc[1-3]* (modulated warped GM, WM and CSF) in the same folder as the 
% input images.
files = spm_select('FPList',dir_img,'^.*\.nii$');
files = files(1:min(N0,size(files,1)),:);
N     = size(files,1);

% Ensure correct number of covariates
sex = sex(1:N);
age = age(1:N);

matlabbatch = {};
matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(files);
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,2'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/home/mbrud/Code/matlab/spm/trunk/tpm/TPM.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];                                                                                                                             
spm_jobman('run',matlabbatch);

%% 2. Compute total intercranial volume (TIV)
% Corrects for brain volume in statistical testing.
files_mwc    = cell(3,1);
files_mwc{1} = spm_select('FPList',dir_t1w,'^mwc1.*\.nii$'); files_mwc{1} = files_mwc{1}(1:N,:);
files_mwc{2} = spm_select('FPList',dir_t1w,'^mwc2.*\.nii$'); files_mwc{2} = files_mwc{2}(1:N,:);
files_mwc{3} = spm_select('FPList',dir_t1w,'^mwc3.*\.nii$'); files_mwc{3} = files_mwc{3}(1:N,:);
tiv = zeros(N,1);
vx = 1.5;  % SPM atlas has this voxel size (isotropic)
for n=1:N
    tiv_n = 0;
    for k=1:numel(files_mwc)
        Nii = nifti(files_mwc{k}(n,:));
        tiv_n = tiv_n + sum(Nii.dat(:) > 0.5);
    end
    tiv(n) = vx^3*tiv_n;
end

%% 3. Smooth normalised segmentations
files = spm_select('FPList',dir_t1w,'^mwc1.*\.nii$');
files = files(1:N,:);

matlabbatch = {};
matlabbatch{1}.spm.spatial.smooth.data = cellstr(files);
matlabbatch{1}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run',matlabbatch);

%% 4. Define statistical model
files = spm_select('FPList',dir_t1w,'^smwc1.*\.nii$');
files = files(1:N,:);

matlabbatch = {};
matlabbatch{1}.spm.stats.factorial_design.dir = {dir_res};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = cellstr(files);
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = sex;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'Sex';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).iCC = 5;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).c = age;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).cname = 'Age';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).iCC = 5;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = tiv;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm_jobman('run',matlabbatch);

%% 5. Fit model
matlabbatch = {};
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(dir_res,'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch);

%%  another example: 
%=================================================================
%     SPM First-level analysis for preprocessed data by fmriprep
%=================================================================
%     Based on SPM12
%
%     Writen by Shengdong Chen, ACRLAB, 2019/6/10
%=================================================================

%% Inputdirs
BIDSdir = 'E:\BIDS\testSPM1st\fmriprep'; % root inputdir for sublist
taskid='run1';
numScans=410;  %The number of scans/TRs per run
disacqs = 0;   %The number of scans you later discard during preprocessing
numScans = numScans-disacqs;
TR = 1.5;     % Repetition time, in seconds
unit='secs'; % onset times in secs (seconds) or scans (TRs)

%% Outputdirs
outputdir='E:\BIDS\testSPM1st\firstlevel' ;  % root outputdir for sublist
sublist=dir(fullfile(BIDSdir,'sub*'));
isFile   = [sublist.isdir];
sublist = {sublist(isFile).name};
spm_mkdir(outputdir,char(sublist)); % for >R2016b, use B = string(A) 

%% Loop for sublist
spm('Defaults','fMRI'); %Initialise SPM fmri
spm_jobman('initcfg');  %Initialise SPM batch mode

for i=1 :length(sublist)
    
    %% Inputdirs and files (Default)
    sub_inputdir=fullfile(BIDSdir,sublist{i},'func');
    func=[sub_inputdir,filesep,sublist{i},'_task-',taskid,'_space-MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold.nii.gz'];
    func_nii=[sub_inputdir,filesep,sublist{i},'_task-',taskid,'_space-MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold.nii'];
    if ~exist(func_nii,'file'), gunzip(func) 
    end
    %filter=['*',taskid,'_space-MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold\.nii*'];
   
    %% Output dirs where you save SPM.mat
    subdir=fullfile(outputdir,sublist{i});

	%% Basic parameters
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = unit; % 'secs' or 'scans'
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    
    %% Load input files for task specilized (e.g, run1)
    %------------------------------------------------------------------
    %run1_scans = spm_select('ExtFPList',sub_inputdir,filter,1:numScans); 
    run1_scans = spm_select('Expand',func_nii);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(run1_scans);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    
    % Multicondition file
    multicondition_file=[fullfile(outputdir,'multicondition'),filesep,sublist{i},'-',taskid,'.mat'];
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {multicondition_file}; % e.g., subinput_dir/sub01-run1.mat
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
   
    % Confounds file
    confounds=spm_load([sub_inputdir,filesep,sublist{i},'_task-',taskid,'_desc-confounds_regressors.tsv'])  ; % e.g., subinput_dir/sub01_task-run1_desc*.tsv
    confounds_matrix=[confounds.a_comp_cor_00,confounds.a_comp_cor_01,confounds.a_comp_cor_02,confounds.a_comp_cor_03, confounds.a_comp_cor_04,confounds.a_comp_cor_05];
    confounds_name=[sub_inputdir,filesep,sublist{i},'_task-',taskid,'_acomcorr.txt'];
    if ~exist(confounds_name,'file'), dlmwrite(confounds_name,confounds_matrix) % e.g., sub-01_task-run1_acomcorr.txt
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {confounds_name};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128; % High-pass filter (hpf) without using consine
    
    %% Model  (Default)
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    %% Model estimation (Default)
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    
    %% Contrasts
    % Default
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep;
    matlabbatch{3}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
    matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
    
    % Set contrasts of interest. For example, if you want to get the effects of negative emotion arousal,
    % you can define the contrast watch_negative VS. watch_neutral by inputing a vector [1 -1].
    % Condition1=beta1=face  Condition2=beta2=think
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'face';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'both'; %'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'think';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
	%% Run matlabbatch jobs
    spm_jobman('run',matlabbatch);

end