restoredefaultpath
clc; clear; close all force;

data_name='ADNI';
base_path = fullfile('C:\Users\Vincent\Desktop\scratch');
out_path = fullfile(base_path, 'output'); addpath(out_path);
codes_dir =  fullfile(base_path, 'ET_biomarker', 'tab_data');
sub_list_file = fullfile(codes_dir, [data_name,'_subjects.list']); %  read in: subjects_suit.list
MDTB_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_MDTB10.csv']); %  Output: res_PPMI_MDTB10.csv
SUIT_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_SUIT34.csv']); %  Output: subjects_suit.list

data_path = fullfile(base_path,[data_name,'_fmriprep_anat_20.2.0_T1w']); addpath(data_path); 
output_path  = fullfile(out_path, [data_name,'_SUIT_res']); addpath(output_path);

%pre-installed software
spm_path = fullfile(out_path, 'm_tools', 'spm12'); addpath(spm_path);
atlas_path = fullfile(out_path, 'm_tools', 'atlasPackage', 'atlasesMNI'); addpath(atlas_path);
%% constants
atlas_MDTB10=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/MDTB_10Regions.nii');
atlas_SUIT=fullfile(spm_path, 'toolbox/suit/atlasesSUIT/Lobules-SUIT.nii');

%atlas='SUIT'; % atlas='SUIT';
atlas='MDTB';
switch atlas
    case 'MDTB', curr_atlas=atlas_MDTB10; curr_atlas_str='iw_MDTB_10Regions_u_a_';
    otherwise,   curr_atlas=atlas_SUIT;   curr_atlas_str='iw_Lobules-SUIT_u_a_';
end

Vatlas=spm_vol(curr_atlas);X=spm_read_vols(Vatlas); num_lobules = max(X(:));
data=tdfread(sub_list_file,'\t'); data.n_sub=length(data.participant_id); data.lobules={};
roi_tab = NaN(data.n_sub, num_lobules);

%% sub list, unzip all nii.gz to .nii
data.t1_in={}; data.nii_out={}; data.t1_name={}; data.roi={}; data.mask={}; data.roi_sum={};
data.gm={}; data.wm={}; data.aff={}; data.deform={}; data.nii_suit={}; data.norm_pass={}; data.seg_pass={};
for i_ = 1:data.n_sub
    t1_name = [data.participant_id(i_,:) '_run-1_desc-preproc_T1w.nii.gz'];
    data.t1_name{end+1}=t1_name(1:end-7);
    data.t1_in{end+1}=fullfile(data_path, t1_name); data.nii_out{end+1}=fullfile(output_path, t1_name(1:end-3));
    image_str = data.t1_name{i_}; image_file = data.nii_out{i_}; 
    data.gm{end+1}=[image_str,'_seg1.nii'];  data.wm{end+1}=[image_str,'_seg2.nii']; data.mask{end+1}=['c_', image_str,'_pcereb.nii'];
    data.aff{end+1} = ['Affine_', image_str,'_seg1.mat']; data.deform{end+1} = ['u_a_', image_str,'_seg1.nii'];
    data.roi_sum{end+1}=fullfile( output_path, [image_str, '_roi.txt']);
    %gunzip(t1_name, output_path); % unzip nii.gz -> .nii
end

%% initialize spm
spm fmri
% normalization
% debuger for normalization 
sub_str='sub-022S0096';
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
% index=4, sub-003S4119 reporting problem, skipped.
% index=7, sub-005S0553 reporting problem, skipped.
% index=21, sub-016S4638 reporting problem, skipped.
% index=22, sub-018S0055 reporting problem, skipped.
% index=25, sub-021S4254 reporting problem, skipped.
% index=27, sub-021S4421 reporting problem, skipped.
% index=30, sub-022S0096 reporting problem, skipped.
% index=31, sub-022S0130 reporting problem, skipped.
% index=32, sub-022S0130 reporting problem, skipped.
% index=33, sub-022S0130 reporting problem, skipped.
% index=37, sub-029S4290 reporting problem, skipped.
% index=43, sub-032S4348 reporting problem, skipped.
% index=50, sub-033S1098 reporting problem, skipped.
% index=53, sub-035S4464 reporting problem, skipped.
% index=66, sub-067S0257 reporting problem, skipped.
% index=76, sub-094S4460 reporting problem, skipped.
% index=81, sub-098S4506 reporting problem, skipped.
% index=87, sub-127S0259 reporting problem, skipped.
% index=100, sub-131S0123 reporting problem, skipped.
% index=101, sub-xxx reporting problem, skipped.
% index=105, sub-137S0301 reporting problem, skipped.
% index=106, sub-137S0301 reporting problem, skipped.

%130S0969

ppmi_norm_err_sub_index = [4,7,21,22,25,27,29,30,31,32,33,37,43, 50, 53, 66,76, 81, 87,100, 101,105, 106 ];

norm_start_point=107;
clear job_n
for i_ = 1:data.n_sub
    tic
    %disp(['isolateing + normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
    %suit_isolate_seg({data.nii_out{i_}}); % segmentation: cerebelum isolation
    data.norm_pass{i_}=1;
    % normalize to SUIT space, generate affine and deformation field.
    if i_>= norm_start_point
        job_n.subjND(i_-norm_start_point+1).gray={fullfile(output_path,data.gm{i_})}; 
        job_n.subjND(i_-norm_start_point+1).white={ fullfile(output_path,data.wm{i_})};
        job_n.subjND(i_-norm_start_point+1).isolation={fullfile(output_path,data.mask{i_})};
    end
    %toc
end
%suit_normalize_dartel(job_n) % map subject space -> SUIT space

for i = 1:length(ppmi_norm_err_sub_index)
    %disp(data.participant_id(ppmi_norm_err_sub_index(i),:)); % visual check
    data.norm_pass{ppmi_norm_err_sub_index(i)}= 0;
end
disp(data.norm_pass) % visual check

%% rerun normalization error subjects
% err_ind=[];
% k=1;
% for i_ = 1:data.n_sub
%     if contains(err_sub,data.participant_id(i_,:))
%         err_ind(end+1)=i_;
%         tic
%         disp([num2str(i_),'  i  ------  k  ',int2str(k)])
%         suit_isolate_seg({data.nii_out{i_}},'maskp', 100); % segmentation: cerebelum isolation
%         disp(['normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_participant_id(i_,:)]);
%         %normalize to SUIT space, generate affine and deformation field.
%         aajob_err.subjND(k).gray={fullfile(output_path,data.gm{i_})}; 
%         job_err.subjND(k).white={ fullfile(output_path,data.wm{i_})};
%         job_err.subjND(k).isolation={fullfile(output_path,data.mask{i_})}; 
%         k=k+1;
%         toc
%     end
% end
% suit_normalize_dartel(job_err) % map subject space -> SUIT space
% i_=err_ind(1);
% disp(['registering to atlas ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_participant_id(i_,:)]);
% job_s.Affine={fullfile(output_path,data.aff{i_})};
% job_s.flowfield={fullfile(output_path,data.deform{i_})};
% job_s.resample={curr_atlas};
% job_s.ref={fullfile(output_path, data.gm{i_})};
% suit_reslice_dartel_inv(job_s); % registration from atlas to indivparticipant_idual
    
%fix single subject normalization: sub-002
% rerun_norm_err_sub_index =[38, 100];
% for i_ = 1:length(rerun_norm_err_sub_index)
%     i_data = rerun_norm_err_sub_index(i_);
%     disp(['Reruning: ', num2str(i_data), data.participant_id(i_data,:)])
%     job_norm1_err.subjND(i_).gray={fullfile(output_path,data.gm{i_data})}; 
%     job_norm1_err.subjND(i_).white={ fullfile(output_path,data.wm{i_data})};
%     job_norm1_err.subjND(i_).isolation={fullfile(output_path,data.mask{i_data})}; 
% end
% suit_normalize_dartel(job_norm1_err)
% Reruning: sub-3350: Warning: Matrix is singular, close to singular or badly scaled. Results may be inaccurate. RCOND = NaN. 
% Reruning: sub-3816: Error using file2mat File is smaller than the dimensions say it should be.
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
%% sub-099S4086 
% registering to atlas 48 in 110 :sub-033S0923
% registering to atlas 83 in 110 :sub-099S4086
%Warning: Matrix is singular, close to singular or badly scaled. Results may be inaccurate.
%RCOND = NaN. 
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