#!/bin/bash
DATA_DIR=(${@:1:1})
SUBJ=(${@:2:1})
echo ${SUBJ}

#DATA_DIR=${HOME}/scratch/QC/MAGET_MNI_QC
OLD_SUBJECTS_DIR=$SUBJECTS_DIR;
SUBJECTS_DIR=$DATA_DIR
OPACITY=0.2

itksnap -g $SUBJECTS_DIR/nii/sub-${SUBJ}_run-1_desc-preproc_T1w.nii  -s $SUBJECTS_DIR/nii/sub-${SUBJ}_run-1_desc-masked_preproc_T1w_labels.nii.gz --scale 1

SUBJECTS_DIR=$OLD_SUBJECTS_DIR
