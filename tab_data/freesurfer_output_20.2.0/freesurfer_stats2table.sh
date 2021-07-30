#!/bin/bash
DATA_NAME=(${@:1:1})
export SUBJECTS_DIR=${HOME}/scratch/${DATA_NAME}_fmriprep_anat_20.2.0/freesurfer-6.0.1
P_CWD=$PWD
OUT_DIR=${P_CWD}/${DATA_NAME}

if [ -d ${OUT_DIR} ];then
  rm -rf ${OUT_DIR}
  echo "freesurfer table out dir already exists!"
fi
mkdir -p ${OUT_DIR}

echo "This bash script will create table from ?.stats files generated by freesurfer."
echo "Use case: $ ./freesurfer_stats2table.sh DATA_NAME"
echo "The folder and tab files will be gerenetaed in the current directory."
echo "Written by Vincent"
echo "ORIGAMA Lab, MNI, McGill University"
echo "Please check the number of output files, it should be 34 in total."
echo "Created on 23th/Oct./2020, updated on 28th/July/2021\n"

echo Gathering ${DATA_NAME} freesurfer results, from $FS_SUBJECTS_DIR...
export FREESURFER_HOME=/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR
SUB_LIST=$(ls -d sub-*)

asegstats2table --subjects $SUB_LIST --meas volume --skip --statsfile wmparc.stats --all-segs --tablefile ${OUT_DIR}/wmparc_stats.txt
asegstats2table --subjects $SUB_LIST --meas volume --skip --tablefile ${OUT_DIR}/aseg_stats.txt
#ind space
aparcstats2table --subjects $SUB_LIST --hemi lh --meas volume --skip --tablefile ${OUT_DIR}/aparc_volume_lh.txt
aparcstats2table --subjects $SUB_LIST --hemi lh --meas thickness --skip --tablefile ${OUT_DIR}/aparc_thickness_lh.txt
aparcstats2table --subjects $SUB_LIST --hemi lh --meas area --skip --tablefile ${OUT_DIR}/aparc_area_lh.txt
aparcstats2table --subjects $SUB_LIST --hemi lh --meas meancurv --skip --tablefile ${OUT_DIR}/aparc_meancurv_lh.txt
aparcstats2table --subjects $SUB_LIST --hemi rh --meas volume --skip --tablefile ${OUT_DIR}/aparc_volume_rh.txt
aparcstats2table --subjects $SUB_LIST --hemi rh --meas thickness --skip --tablefile ${OUT_DIR}/aparc_thickness_rh.txt
aparcstats2table --subjects $SUB_LIST --hemi rh --meas area --skip --tablefile ${OUT_DIR}/aparc_area_rh.txt
aparcstats2table --subjects $SUB_LIST --hemi rh --meas meancurv --skip --tablefile ${OUT_DIR}/aparc_meancurv_rh.txt
# parc a2009s
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.a2009s --meas volume --skip -t ${OUT_DIR}/lh.a2009s.volume.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.a2009s --meas thickness --skip -t ${OUT_DIR}/lh.a2009s.thickness.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.a2009s --meas area --skip -t ${OUT_DIR}/lh.a2009s.area.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.a2009s --meas meancurv --skip -t ${OUT_DIR}/lh.a2009s.meancurv.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.a2009s --meas volume --skip -t ${OUT_DIR}/rh.a2009s.volume.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.a2009s --meas thickness --skip -t ${OUT_DIR}/rh.a2009s.thickness.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.a2009s --meas area --skip -t ${OUT_DIR}/rh.a2009s.area.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.a2009s --meas meancurv --skip -t ${OUT_DIR}/rh.a2009s.meancurv.txt
# DKTatlas
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.DKTatlas --meas volume --skip -t ${OUT_DIR}/lh.DKTatlas.volume.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.DKTatlas --meas thickness --skip -t ${OUT_DIR}/lh.DKTatlas.thickness.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.DKTatlas --meas area --skip -t ${OUT_DIR}/lh.DKTatlas.area.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc aparc.DKTatlas --meas meancurv --skip -t ${OUT_DIR}/lh.DKTatlas.meancurv.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.DKTatlas --meas volume --skip -t ${OUT_DIR}/rh.DKTatlas.volume.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.DKTatlas --meas thickness --skip -t ${OUT_DIR}/rh.DKTatlas.thickness.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.DKTatlas --meas area --skip -t ${OUT_DIR}/rh.DKTatlas.area.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc aparc.DKTatlas --meas meancurv --skip -t ${OUT_DIR}/rh.DKTatlas.meancurv.txt
# parc BA_exvivo
aparcstats2table --hemi lh --subjects $SUB_LIST --parc BA_exvivo --meas volume --skip -t ${OUT_DIR}/lh.BA_exvivo.volume.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc BA_exvivo --meas thickness --skip -t ${OUT_DIR}/lh.BA_exvivo.thickness.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc BA_exvivo --meas area --skip -t ${OUT_DIR}/lh.BA_exvivo.area.txt
aparcstats2table --hemi lh --subjects $SUB_LIST --parc BA_exvivo --meas meancurv --skip -t ${OUT_DIR}/lh.BA_exvivo.meancurv.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc BA_exvivo --meas volume --skip -t ${OUT_DIR}/rh.BA_exvivo.volume.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc BA_exvivo --meas thickness --skip -t ${OUT_DIR}/rh.BA_exvivo.thickness.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc BA_exvivo --meas area --skip -t ${OUT_DIR}/rh.BA_exvivo.area.txt
aparcstats2table --hemi rh --subjects $SUB_LIST --parc BA_exvivo --meas meancurv --skip -t ${OUT_DIR}/rh.BA_exvivo.meancurv.txt
cd $P_CWD
