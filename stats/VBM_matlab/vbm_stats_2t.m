% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\Vincent\Desktop\scratch\ET_biomarker\stats\VBM_matlab\vbm_stats_2t_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
