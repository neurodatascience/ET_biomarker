
spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm... = ...;

spm_jobman('run',matlabbatch);

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