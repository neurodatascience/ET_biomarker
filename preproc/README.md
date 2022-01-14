# The procedure of preprocessing ROI based measures;

1. Read and organize the freesurfer results together with SUIT results;
    1.1 preproc1-1_ADNI-PPMI_freesurfer-SUIT.ipynb
    1.2 preproc1-2_MNI_freesurfer-SUIT.ipynb
2. Adding QC information and creat new columns for latter analysis;
    preproc2_QC.ipynb
3. Matching ET with pooled NC subjects from MNI/PPMI/ADNI NCs.
    preproc3_cohort-matching.ipynb
4. Adding MAGeT results;
    preproc4_Augmented-Cohort_MAGeT.ipynb