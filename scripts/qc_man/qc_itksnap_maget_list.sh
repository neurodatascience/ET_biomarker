#!/bin/bash
DATA_DIR=(${@:1:1})
SUB_list=(${@:2:1})

#DATA_DIR=${HOME}/scratch/QC/MAGET_MNI_QC
OLD_SUBJECTS_DIR=$SUBJECTS_DIR;
SUBJECTS_DIR=$DATA_DIR
OPACITY=0.5


n_sub=$(wc -l < $SUB_list)
echo $n_sub
for (( i_sub=1; i_sub<=${n_sub}; i_sub++ ))
do
echo $i_sub
SUB_STR=$(sed -n "${i_sub}p" ${SUB_list})
echo ${SUB_STR}
itksnap -g $SUBJECTS_DIR/nii/${SUB_STR}_run-1_desc-preproc_T1w.nii  -s $SUBJECTS_DIR/nii/${SUB_STR}_run-1_desc-masked_preproc_T1w_labels.nii.gz --scale 1
done

