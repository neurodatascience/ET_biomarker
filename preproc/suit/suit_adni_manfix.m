restoredefaultpath
clc; clear; close all force;

data_name='ADNI';
base_path = fullfile('C:\Users\Vincent\Desktop\scratch');
out_path = fullfile(base_path, 'output'); addpath(out_path);
codes_dir =  fullfile(base_path, 'ET_biomarker', 'tab_data');
sub_list_file = fullfile(codes_dir, [data_name,'_subjects.list']); %  read in: subjects_suit.list
MDTB_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_MDTB10.csv']); %  Output: res_PPMI_MDTB10.csv
SUIT_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_SUIT34.csv']); %  Output: subjects_suit.list

data_path = fullfile(base_path,[data_name,'_fmriprep_anat_20.2.0_T1s']); addpath(data_path); 
output_path  = fullfile(out_path, [data_name,'_SUIT_res']); addpath(output_path);

%pre-installed software: SPM12 and the SUIT atlas
spm_path = fullfile(out_path, 'm_tools', 'spm12'); addpath(spm_path);
atlas_path = fullfile(out_path, 'm_tools', 'atlasPackage', 'atlasesMNI'); addpath(atlas_path);
%% selection of altas, atlas='SUIT' or atlas='SUIT';
atlas_MDTB10=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/MDTB_10Regions.nii');
atlas_SUIT=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/Lobules-SUIT.nii');
atlas='MDTB';
switch atlas
    case 'MDTB', curr_atlas=atlas_MDTB10; curr_atlas_str='iw_MDTB_10Regions_u_a_';
    otherwise,   curr_atlas=atlas_SUIT;   curr_atlas_str='iw_Lobules-SUIT_u_a_';
end
roi_tab = NaN(data.n_sub, num_lobules);

%
Vatlas=spm_vol(curr_atlas);X=spm_read_vols(Vatlas); num_lobules = max(X(:));
data=tdfread(sub_list_file,'\t'); data.n_sub=length(data.participant_id); data.lobules={};
%% unzip all nii.gz to .nii for all subjects
data.t1_in={}; data.nii_out={}; data.t1_name={}; data.roi={}; data.mask={}; data.roi_sum={};
data.gm={}; data.wm={}; data.aff={}; data.deform={}; data.nii_suit={}; data.norm_pass={}; data.seg_pass={};

for i_ = 1:data.n_sub
    % prepare file names and folders
    t1_name = [data.participant_id(i_,:) '_run-1_desc-preproc_T1w.nii.gz'];
    data.t1_name{end+1}=t1_name(1:end-7);
    data.t1_in{end+1}=fullfile(data_path, t1_name); data.nii_out{end+1}=fullfile(output_path, t1_name(1:end-3));
    image_str = data.t1_name{i_}; image_file = data.nii_out{i_}; 
    data.gm{end+1}=[image_str,'_seg1.nii'];  data.wm{end+1}=[image_str,'_seg2.nii']; data.mask{end+1}=['c_', image_str,'_pcereb.nii'];
    data.aff{end+1} = ['Affine_', image_str,'_seg1.mat']; data.deform{end+1} = ['u_a_', image_str,'_seg1.nii'];
    data.roi_sum{end+1}=fullfile( output_path, [image_str, '_roi.txt']);
    % execution: unzip nii.gz -> .nii
    gunzip(fullfile(data_path, t1_name), output_path); 
end

%% initialize spm
spm fmri
%% debuger for normalization 
sub_str='sub-032S1169';
for tmp_i = 1:data.n_sub
    if data.participant_id(tmp_i,:)==sub_str
        disp([num2str(tmp_i), ':', sub_str])
        target_index=tmp_i+1;
        start_index=target_index+1;
    end
end
% target_index=75; start_index=target_index+1;
disp(['Err for:', num2str(target_index)])
data.participant_id(target_index,:)
disp(['Start with: ', num2str(start_index)])
data.participant_id(start_index,:)
%% bug report during Normalization
% data.participant_id(275,:) 
% index=10, sub-003S4081 reporting problem, skipped. x
% index=11, sub-003S4119 reporting problem, skipped. x
% index=14, sub-003S4441 reporting problem, skipped. x
% index=20, sub-005S0553 reporting problem, skipped. x -
% index=27, sub-007S1206 reporting problem, skipped. x
% index=28, sub-007S1222 reporting problem, skipped. x
% index=40, sub-013S4579 reporting problem, skipped. x
% index=46, sub-014S4577 reporting problem, skipped. x
% index=50, sub-016S4638 reporting problem, skipped. x
% index=54, sub-018S0055 reporting problem, skipped. x
% index=62, sub-021S4254 reporting problem, skipped. x
% index=65, sub-021S4421 reporting problem, skipped. x
% index=67, sub-022S0096 reporting problem, skipped. x -
% index=70, sub-023S0031 reporting problem, skipped. x
% index=78, sub-024S4084 reporting problem, skipped. x
% index=80, sub-027S0074 reporting problem, skipped. x
% index=88, sub-029S4652 reporting problem, skipped. x
% index=95, sub-032S0677 reporting problem, skipped. x
% index=96, sub-032S1169 reporting problem, skipped. x  
% index=99, sub-032S4429 reporting problem, skipped. x need matrix
% index=101, sub-033S0734 reporting problem, skipped. x
% index=104, sub-033S0923 reporting problem, skipped. x
% index=106, sub-033S1098 reporting problem, skipped. x
% index=129, sub-051S1123 reporting problem, skipped. x
% index=132, sub-067S0056 reporting problem, skipped. x
% index=133, sub-067S0059 reporting problem, skipped. x
% index=134, sub-067S0257 reporting problem, skipped. x
% index=156, sub-094S4460 reporting problem, skipped. x
% index=164, sub-098S4050 reporting problem, skipped. x
% index=167, sub-099S0352 reporting problem, skipped. x
% index=180, sub-126S0680 reporting problem, skipped. x
% index=181, sub-127S0259 reporting problem, skipped. x 
% index=192, sub-128S0545 reporting problem, skipped. x
% index=197, sub-128S4607 reporting problem, skipped. x
% index=202, sub-131S0123 reporting problem, skipped. x
% index=212, sub-141S0717 reporting problem, skipped. x 
% index=215, sub-941S1195 reporting problem, skipped. x
% index=216, sub-941S1202 reporting problem, skipped. x
% index=228, sub-005S0602 reporting problem, skipped. x 
% index=231, sub-010S0420 reporting problem, skipped. x
% index=232, sub-010S4345 reporting problem, skipped. x
% index=245, sub-014S4080 reporting problem, skipped. x
% index=265, sub-052S0951 reporting problem, skipped. x
% index=272, sub-082S4208 reporting problem, skipped. x
% index=273, sub-082S4224 reporting problem, skipped. x
% index=274, sub-082S4339 reporting problem, skipped. x
% index=275, sub-082S4428 reporting problem, skipped. x
% index=280, sub-109S4499 reporting problem, skipped. x
% index=290, sub-116S4855 reporting problem, skipped. x
% index=300, sub-131S0123 reporting problem, skipped. #
% index=301, sub-135S4446 reporting problem, skipped. x

%201 298 sub-130S0969; 202/300 sub-131S0123
%% normalization
norm_start_point=10000;
clear job_n
for i_ = 1:data.n_sub
    %tic
    %disp(['isolateing + normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
    % segmentation: cerebelum isolation
    %suit_isolate_seg({data.nii_out{i_}}); 
    data.norm_pass{i_}=1;
    % normalize to SUIT space, generate affine and deformation field.
    if i_>= norm_start_point
        job_n.subjND(i_-norm_start_point+1).gray={fullfile(output_path,data.gm{i_})}; 
        job_n.subjND(i_-norm_start_point+1).white={ fullfile(output_path,data.wm{i_})};
        job_n.subjND(i_-norm_start_point+1).isolation={fullfile(output_path,data.mask{i_})};
    end
    %toc
end
% map subject space -> SUIT space
%suit_normalize_dartel(job_n) 

%% Reg failure subjects
adni_norm_err_sub_index = [10, 11, 14, 20, 27, 28, 40, 46, 50, 54, 62, 65,67, 70, 78, 80, 88, 95, 96, 99, 101, 104, 106, 129, 132, 133, 134, 156, 164, 167, 180, 181, 192, 197, 202, 212, 215, 216, 228,231, 232, 245, 265, 272, 273, 274, 275, 280, 290, 301];
for i = 20:length(adni_norm_err_sub_index)
    disp(data.participant_id(adni_norm_err_sub_index(i),:)); % visual check
    data.norm_pass{adni_norm_err_sub_index(i)}= 0;
end

%% fix list of error subjects normalization
k=1;
clear job_err
for i_ = 1:data.n_sub
    if data.norm_pass{i_}==0
        data.participant_id(i_,:)
        %del_list
        tic
        delete(fullfile(output_path, data.gm{i_}), fullfile(output_path, data.wm{i_}))
        delete(fullfile(output_path, data.mask{i_}), fullfile(output_path, data.aff{i_}))
        delete(fullfile(output_path, data.deform{i_}), fullfile(output_path, ['a_', data.gm{i_}]), fullfile(output_path, ['a_', data.wm{i_}]))
        delete(fullfile(output_path, ['c_', data.t1_name{i_},'.nii']),fullfile(output_path, ['m', data.gm{i_}]),fullfile(output_path, ['m', data.wm{i_}]))
        delete(fullfile(output_path, ['iw_MDTB_10Regions_u_a_', data.gm{i_}]), fullfile(output_path, ['iw_Lobules-SUIT_u_a_', data.gm{i_}]))
        suit_isolate_seg({data.nii_out{i_}}); % segmentation: cerebelum isolation
        disp(['normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
        %normalize to SUIT space, generate affine and deformation field.
        job_err.subjND(k).gray={fullfile(output_path, data.gm{i_})}; 
        job_err.subjND(k).white={fullfile(output_path, data.wm{i_})};
        job_err.subjND(k).isolation={fullfile(output_path, data.mask{i_})}; 
        k=k+1;
        toc
    end
end
%map subject space -> SUIT space
suit_normalize_dartel(job_err)

%% reset norm_pass to 1
for i = 1:length(data.participant_id)
    %disp(data.participant_id(adni_norm_err_sub_index(i),:)); % visual check
    data.norm_pass{i}= 1;
end
% check
%% register atlas to indivparticipant_idual can calculate vol size
for i_ = 1:data.n_sub
    if data.norm_pass{i_}==1
        disp(['registering to atlas ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
        job_s.Affine={fullfile(output_path,data.aff{i_})};
        job_s.flowfield={fullfile(output_path,data.deform{i_})};
        job_s.resample={curr_atlas};
        job_s.ref={fullfile(output_path, data.gm{i_})};
        %tic
        suit_reslice_dartel_inv(job_s); % registration from atlas to indivparticipant_idual
        %toc
        data.seg_pass{i_}=1;
        V=spm_vol(fullfile(output_path, [curr_atlas_str, data.gm{i_}]));
        X=spm_read_vols(V);
        lobule_vol_=zeros(num_lobules,1);
        for i_lob=1:num_lobules
            lobule_vol_(i_lob) = length(find(X==i_lob));
        end
        roi_tab(i_,:)=lobule_vol_;
        data.lobules{end+1}=lobule_vol_;
    end
end
% 
%% segmentation warnings: (SUIT space)
% registering to atlas 29 in 310 :sub-007S4387
% registering to atlas 31 in 310 :sub-007S4516
% registering to atlas 82 in 310 :sub-029S0824
% registering to atlas 160 in 310 :sub-098S0896
% registering to atlas 169 in 310 :sub-099S4086
% registering to atlas 281 in 310 :sub-114S0166
% registering to atlas 302 in 310 :sub-135S4566
%Warning: Matrix is singular, close to singular or badly scaled. Results may be inaccurate. RCOND = NaN. 
%> In suit_reslice_dartel_inv (line 41)

switch atlas
    case 'MDTB', csvwrite(MDTB_tab_out_file, roi_tab);
    otherwise,   csvwrite(SUIT_tab_out_file, roi_tab);
end

%% test code
% summarize volumes (no participant_idea what we need this function for)
% suit_ROI_summarize(data.nii_suit,'atlas', atlas_MDTB10);
% suit_ROI_summarize(data.nii_suit,'atlas', atlas_SUIT);

%% DBM and atlas to indivparticipant_idual.
% for i_ = 1:data.n_sub
%     %disp(['applying normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
%     data.nii_suit{end+1}=fullfile(output_path,['wd',data.gm{i_}]);
%     %% DBM: sub2atlas, run for whole group after this loop.
%     job_a.subj(i_).affineTr={fullfile(output_path,data.aff{i_})};
%     job_a.subj(i_).flowfield={fullfile(output_path,data.deform{i_})};
%     job_a.subj(i_).resample={fullfile(output_path,data.gm{i_})}; 
%     job_a.subj(i_).jactransf=1;
%     job_a.subj(i_).mask={fullfile(output_path,data.mask{i_})};
% end
%suit_reslice_dartel(job_a)