#!/bin/bash
DATA_DIR=(${@:1:1})
SUBJ=(${@:2:1})
echo ${SUBJ}

#DATA_DIR=${HOME}/scratch/ET_fmriprep_anat_20.2.0/freesurfer-6.0.1/
OLD_SUBJECTS_DIR=$SUBJECTS_DIR;
SUBJECTS_DIR=$DATA_DIR
OPACITY=0.6

freeview -v $SUBJECTS_DIR/sub-$SUBJ/mri/T1.mgz -v $SUBJECTS_DIR/sub-$SUBJ/mri/aparc.a2009s+aseg.mgz:colormap=lut:opacity=0.4 
#-v $SUBJECTS_DIR/sub-$SUBJ/mri/T2.mgz
#-v $SUBJECTS_DIR/sub-$SUBJ/mri/aparc.DKTatlas+aseg.mgz:colormap=lut:opacity=0.4

SUBJECTS_DIR=$OLD_SUBJECTS_DIR
