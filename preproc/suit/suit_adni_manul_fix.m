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
atlas='SUIT'; %MDTB
switch atlas
    case 'MDTB', curr_atlas=atlas_MDTB10; curr_atlas_str='iw_MDTB_10Regions_u_a_';
    otherwise,   curr_atlas=atlas_SUIT;   curr_atlas_str='iw_Lobules-SUIT_u_a_';
end

%
Vatlas=spm_vol(curr_atlas);X=spm_read_vols(Vatlas); num_lobules = max(X(:));
data=tdfread(sub_list_file,'\t'); data.n_sub=length(data.participant_id); data.lobules={};
roi_tab = NaN(data.n_sub, num_lobules);
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
end

%% initialize spm
spm fmri
%% normalization errors in R1: 141 in total:
norm_err_sub_r1={'sub-002S4262', 'sub-002S4264', 'sub-002S4270', 'sub-003S0981', 'sub-003S4081', 'sub-003S4288', 'sub-003S4350', 'sub-003S4441', 'sub-003S4555', 'sub-003S4644', 'sub-005S0610', 'sub-006S4150', 'sub-006S4357', 'sub-006S4449', 'sub-006S4485', 'sub-007S1206', 'sub-009S4337', 'sub-009S4612', 'sub-010S4345', 'sub-010S4442', 'sub-011S0021', 'sub-011S4075', 'sub-011S4105', 'sub-011S4120', 'sub-011S4222', 'sub-013S4579', 'sub-013S4580', 'sub-013S4731', 'sub-014S0519', 'sub-014S0520', 'sub-014S4080', 'sub-014S4093', 'sub-014S4401', 'sub-014S4576', 'sub-014S4577', 'sub-016S0359', 'sub-016S4097', 'sub-016S4121', 'sub-016S4638', 'sub-016S4688', 'sub-016S4951', 'sub-018S4400', 'sub-019S4835', 'sub-021S4421', 'sub-022S0096', 'sub-022S4173', 'sub-022S4196', 'sub-022S4320', 'sub-023S0058', 'sub-023S1190', 'sub-023S4448', 'sub-024S4084', 'sub-024S4158', 'sub-027S0120', 'sub-029S4279', 'sub-029S4384', 'sub-029S4385', 'sub-029S4585', 'sub-031S0618', 'sub-031S4021', 'sub-031S4218', 'sub-031S4474', 'sub-031S4496', 'sub-032S0479', 'sub-032S0677', 'sub-032S1169', 'sub-032S4277', 'sub-032S4429', 'sub-033S0741', 'sub-033S1016', 'sub-036S4389', 'sub-036S4878', 'sub-037S0303', 'sub-037S0467', 'sub-037S4028', 'sub-037S4071', 'sub-037S4308', 'sub-037S4410', 'sub-041S4037', 'sub-041S4060', 'sub-041S4083', 'sub-041S4200', 'sub-041S4427', 'sub-041S4509', 'sub-051S1123', 'sub-067S0056', 'sub-067S0059', 'sub-067S0257', 'sub-068S0210', 'sub-068S4340', 'sub-068S4424', 'sub-070S5040', 'sub-072S0315', 'sub-072S4103', 'sub-072S4391', 'sub-073S0089', 'sub-073S0311', 'sub-073S4155', 'sub-073S4382', 'sub-073S4393', 'sub-073S4552', 'sub-073S4559', 'sub-073S4795', 'sub-073S5023', 'sub-082S1256', 'sub-082S4090', 'sub-082S4224', 'sub-094S4503', 'sub-098S0171', 'sub-098S0896', 'sub-098S4018', 'sub-098S4506', 'sub-099S0352', 'sub-099S4076', 'sub-100S4469', 'sub-100S5246', 'sub-114S0416', 'sub-116S0382', 'sub-116S1232', 'sub-123S0106', 'sub-127S0259', 'sub-127S4148', 'sub-127S4645', 'sub-128S0545', 'sub-128S0863', 'sub-128S1242', 'sub-128S4586', 'sub-128S4609', 'sub-131S0123', 'sub-131S0441', 'sub-135S4446', 'sub-135S4598', 'sub-136S4726', 'sub-136S4727', 'sub-137S4482', 'sub-137S4587', 'sub-137S4632', 'sub-141S0767', 'sub-153S4139', 'sub-941S1195', 'sub-941S1202'};
norm_err_sub_ind_r1=zeros(1,length(norm_err_sub_r1));
for i_sub =1:length(norm_err_sub_r1)
    sub_str=norm_err_sub_r1{i_sub};
    for tmp_i = 1:data.n_sub
        if data.participant_id(tmp_i,:)==sub_str;
            disp([num2str(tmp_i), ': ', sub_str])
            norm_err_sub_ind_r1(i_sub)=tmp_i;
        end
    end
end

% Setting up rerun labels
for i_ = 1:data.n_sub; data.norm_pass{i_}=1; end
for i = 1:length(norm_err_sub_ind_r1); data.norm_pass{norm_err_sub_ind_r1(i)}= 0; end %put flag for error subject in R2
% fix list of error subjects normalization R2
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
        data.norm_pass{i_}= 1; %Refresh subject failure flags after correction.
        toc
    end
end
%map subject space -> SUIT space
suit_normalize_dartel(job_err)

%% reset norm_pass to 1 to do segmentation for all subjects
% for i = 1:length(data.participant_id)
%     %disp(data.participant_id(adni_norm_err_sub_index(i),:)); % visual check
%     data.norm_pass{i}= 1;
% end

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