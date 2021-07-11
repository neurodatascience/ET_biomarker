# Shell scripts for preprocessing:
1. Conversion with heudiconv 0.8.0 from dicom to nii (BIDS)
* ```heudiconv_run1.sh``` submit ```heudiconv_run1.slurm```to cluster and create the related folders; 

```./heudiconv_run1.sh dataset_name heuristic_file```
* * ```heudiconv_run1.slurm``` is the working horse for the first screening ran on each computing node;
* ```heudiconv_run2.sh``` submit ```heudiconv_run2.slurm```to cluster and create the related folders; 
* * ```heudiconv_run2.slurm``` is the working horse for the conversion ran on each computing node;
2. Preprocessing of the structure and functional images with fMRIPrep 20.2.0;
