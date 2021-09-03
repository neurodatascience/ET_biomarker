restoredefaultpath
clc; clear; close all force;

data_name='PPMI';
base_path = fullfile('C:\Users\Vincent\Desktop\scratch');
out_path = fullfile(base_path, 'output'); addpath(out_path);
codes_dir =  fullfile(base_path, 'ET_biomarker', 'tab_data');
sub_list_file = fullfile(codes_dir, [data_name,'_subjects.list']); %  read in: subjects_suit.list
MDTB_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_MDTB10.csv']); %  Output: res_PPMI_MDTB10.csv
SUIT_tab_out_file = fullfile(codes_dir, ['res_',data_name,'_SUIT34.csv']); %  Output: subjects_suit.list

data_path = fullfile(base_path,[data_name,'_fmriprep_anat_20.2.0_T1w']); addpath(data_path); 
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
    otherwise, curr_atlas = atlas_SUIT; curr_atlas_str='iw_Lobules-SUIT_u_a_';
end
% Create tables to store results.
Vatlas=spm_vol(curr_atlas);X=spm_read_vols(Vatlas); num_lobules = max(X(:));
data=tdfread(sub_list_file,'\t'); data.n_sub=length(data.participant_id); data.lobules={};
roi_tab = NaN(data.n_sub, num_lobules);

%% unzip all nii.gz to .nii for all subjects
% create file directories
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
    %% unzip nii.gz -> .nii
    %gunzip(t1_name, output_path); 
end

%% initialize spm
spm fmri
%% debuger for normalization in run1
% sub_str='sub-3544';
% for tmp_i = 1:data.n_sub
%     if data.participant_id(tmp_i,:)==sub_str
%         disp([num2str(tmp_i), ':', sub_str])
%         target_index=tmp_i+1;
%         start_index=target_index+1;
%     end
% end
% % target_index=75; start_index=target_index+1;
% disp(['Err for:', num2str(target_index)])
% data.participant_id(target_index,:)
% disp(['Start with: ', num2str(start_index)])
% data.participant_id(start_index,:)

%% normalization run1
% norm_start_point=1;
% for i_ = 1:data.n_sub
%     %tic
%     %disp(['isolateing + normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
%     % segmentation: cerebelum isolation
%     %suit_isolate_seg({image_file});
%     data.norm_pass{i_}=1;
%     % normalize to SUIT space, generate affine and deformation field.
%     if i_>= norm_start_point
%         job_n.subjND(i_-norm_start_point+1).gray={fullfile(output_path,data.gm{i_})}; 
%         job_n.subjND(i_-norm_start_point+1).white={ fullfile(output_path,data.wm{i_})};
%         job_n.subjND(i_-norm_start_point+1).isolation={fullfile(output_path,data.mask{i_})};
%     end
%     %toc
% end
% map subject space -> SUIT space
%suit_normalize_dartel(job_n) 

%% Failure subjects based on normalization errors RUN1
norm_err_sub_index_r1 = [10,26,27,28,29,31,46,63,64,65,66,67,69,75,76,99,101,102,111];
% index=28, 'sub-3271' reporting problem, skipped.
% index=29, 'sub-3274' reporting problem, skipped.
% index=31, 'sub-3277' reporting problem, skipped.
% index=46, 'sub-3368' reporting problem, skipped.
% index=63, 'sub-3551' reporting problem, skipped.
% index=64, 'sub-3554' reporting problem, skipped.
% index=65, 'sub-3555' reporting problem, skipped.
% index=66, 'sub-3563' reporting problem, skipped.
% index=67, 'sub-3565' reporting problem, skipped.
% index=69, 'sub-3570' reporting problem, skipped.
% index=75, 'sub-3613' reporting problem, skipped.
% index=76, 'sub-3614' reporting problem, skipped.
% index=99, 'sub-3812' reporting problem, skipped.
% index=101, 'sub-3816' reporting problem, skipped.
% index=102, 'sub-3817' reporting problem, skipped.
% index=111, 'sub-4004' reporting problem, skipped.
% index=62, 'sub-3544' not converted, error in converting from dicom to BIDS.

%% Failure subjects based on too small value errors: RUN2
% norm_err_sub_ind_r2 = [10,26,27,28,29,31,46,63,64,65,66,67,69,75,76,99,101,102,111];
% norm_err_sub_r2 = {'sub-3000', 'sub-3029', 'sub-3115', 'sub-3151', 'sub-3156', 'sub-3157', ...
%     'sub-3160', 'sub-3165', 'sub-3169', 'sub-3171', 'sub-3172', 'sub-3188', ...
%     'sub-3257', 'sub-3260', 'sub-3276', 'sub-3301', 'sub-3310', 'sub-3316', ...
%     'sub-3318', 'sub-3350', 'sub-3351', 'sub-3355', 'sub-3357', 'sub-3362', ...
%     'sub-3369', 'sub-3370', 'sub-3389', 'sub-3569', 'sub-3571', 'sub-3600', ...
%     'sub-3610', 'sub-3611', 'sub-3615', 'sub-3620', 'sub-3624', 'sub-3627', ...
%     'sub-3635', 'sub-3637', 'sub-3756', 'sub-4018', 'sub-4032'};
% norm_err_sub_ind_r2=[];
% % sub_str='sub-3544';
% for tmp_j_ =1:length(norm_err_sub_r2)
%     for tmp_i = 1:data.n_sub
%         if data.participant_id(tmp_i,:)==norm_err_sub_r2{tmp_j_}
%             norm_err_sub_ind_r2(end+1)=tmp_i;
%         end
%      end
%  end
% norm_err_sub_ind_r2
% %% assign flag values for norm_err_sub_ind_r2 rerun subjects
norm_err_sub_ind_r2=[1]
for i_ = 1:data.n_sub; data.norm_pass{i_}=1; end;
for i = 1:length(norm_err_sub_ind_r2); data.norm_pass{norm_err_sub_ind_r2(i)}= 0; end;
% data.norm_pass{62}=0;
%% fix list of error subjects normalization
k=1
for i_ = 1:data.n_sub
    if data.norm_pass{i_}==0
        data.participant_id(i_,:)
        %del_list
        tic
        delete(fullfile(output_path, data.gm{i_}), fullfile(output_path, data.wm{i_}))
        delete(fullfile(output_path, data.mask{i_}), fullfile(output_path, data.aff{i_}))
        delete(fullfile(output_path, data.deform{i_}), fullfile(output_path, ['a_', data.gm{i_}]),fullfile(output_path, ['a_', data.wm{i_}]))
        delete(fullfile(output_path, ['c_', data.t1_name{i_},'.nii']),fullfile(output_path, ['m', data.gm{i_}]),fullfile(output_path, ['m', data.wm{i_}]))
        delete(fullfile(output_path, ['iw_MDTB_10Regions_u_a_', data.gm{i_}]), fullfile(output_path, ['iw_Lobules-SUIT_u_a_', data.gm{i_}]))
        suit_isolate_seg({data.nii_out{i_}}); % segmentation: cerebelum isolation
        disp(['normalization ', num2str(i_),' in ', num2str(data.n_sub), ' :', data.participant_id(i_,:)]);
        %normalize to SUIT space, generate affine and deformation field.
        job_err.subjND(k).gray={fullfile(output_path,data.gm{i_})}; 
        job_err.subjND(k).white={ fullfile(output_path,data.wm{i_})};
        job_err.subjND(k).isolation={fullfile(output_path,data.mask{i_})}; 
        k=k+1;
        toc
    end
end
%map subject space -> SUIT space
suit_normalize_dartel(job_err)

%% fix single subject normalization 
% i_err = 27;
% suit_isolate_seg({data.nii_out{i_err}}); % segmentation: cerebelum isolation
% job_err.subjND(1).gray={fullfile(output_path,data.gm{i_err})}; 
% job_err.subjND(1).white={ fullfile(output_path,data.wm{i_err})};
% job_err.subjND(1).isolation={fullfile(output_path,data.mask{i_err})}; 
% suit_normalize_dartel(job_err)

%% Refresh subject failure flags after correction.
%% all subject suit seg fixed:
for i_ = 1:data.n_sub; data.norm_pass{i_}=1; end;
norm_err_sub_index_r2 = [62]; % sub-3544 has no data.
for i = 1:length(norm_err_sub_index_r2); data.norm_pass{norm_err_sub_index_r2(i)}= 0; end;

%% Register atlas to participant_id to calculate vol size
for i_ = 1:data.n_sub
    if data.norm_pass{i_}==1
        %i_=66
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


%% save results
switch atlas
    case 'MDTB', csvwrite(MDTB_tab_out_file, roi_tab);
    otherwise,   csvwrite(SUIT_tab_out_file, roi_tab);
end

%% test code
% summarize volumes (no participant_idea what we need this function for)
%suit_ROI_summarize(data.nii_suit,'atlas', atlas_MDTB10);
% suit_ROI_summarize(data.nii_suit,'atlas', atlas_SUIT);

%% 
aff_mat = load(fullfile(output_path,'Affine_sub-3624_run-1_desc-preproc_T1w_seg1.mat'));
img_mat = spm_vol(fullfile(output_path,'sub-3624_run-1_desc-preproc_T1w_seg1.nii'));
M=spm_imatrix(aff_mat.Affine);
reg_imgg_mat=spm_get_space(img_mat, M*img_mat.mat);


