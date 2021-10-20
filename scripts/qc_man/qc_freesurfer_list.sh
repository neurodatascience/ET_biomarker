#!/bin/bash
DATA_DIR=(${@:1:1})
SUB_list=(${@:2:1})

#DATA_DIR=${HOME}/scratch/ET_fmriprep_anat_20.2.0/freesurfer-6.0.1/
OLD_SUBJECTS_DIR=$SUBJECTS_DIR;
SUBJECTS_DIR=$DATA_DIR
OPACITY=0.6

#-v $SUBJECTS_DIR/sub-$SUBJ/mri/T2.mgz
#-v $SUBJECTS_DIR/sub-$SUBJ/mri/aparc.DKTatlas+aseg.mgz:colormap=lut:opacity=0.4

n_sub=$(wc -l < $SUB_list)
echo $n_sub
for (( i_sub=1; i_sub<=${n_sub}; i_sub++ ))
do
echo $i_sub
SUB_STR=$(sed -n "${i_sub}p" ${SUB_list})
echo ${SUB_STR}
freeview -v $SUBJECTS_DIR/$SUB_STR/mri/T1.mgz -v $SUBJECTS_DIR/$SUB_STR/mri/aparc.a2009s+aseg.mgz:colormap=lut:opacity=0.4 
done


