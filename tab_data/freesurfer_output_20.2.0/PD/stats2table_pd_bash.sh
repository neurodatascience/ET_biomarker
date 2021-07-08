#!/bin/bash
path=`dirname $0`
cd $path
echo "This bash script will create table from ?.stats files"
echo "Written by Vincent"
echo "MNI, McGill University"
echo "Please check the number of output files, it should be 34 in total."
echo "23/10/2020\n"



export FREESURFER_HOME=/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=$PWD
# put PD subjects here
list="sub-0002 sub-0004 sub-0005 sub-0006 sub-0008 sub-0009 sub-0012 sub-0014 sub-0015 sub-0021 sub-0022 sub-0023 sub-0024 sub-0025 sub-0026 sub-0027 sub-0028 sub-0029 sub-0030 sub-0031 sub-0034 sub-0035 sub-0037 sub-0038 sub-0040 sub-0047 sub-0051 sub-0052 sub-0068 sub-0075 sub-0076 sub-0094 sub-0096 sub-0098 sub-0109 sub-0111 sub-0118 sub-0125 sub-0129 sub-0132 sub-0136 sub-1000 sub-1020"

asegstats2table --subjects $list --meas volume --skip --statsfile wmparc.stats --all-segs --tablefile wmparc_stats.txt
asegstats2table --subjects $list --meas volume --skip --tablefile aseg_stats.txt
#ind space
aparcstats2table --subjects $list --hemi lh --meas volume --skip --tablefile aparc_volume_lh.txt
aparcstats2table --subjects $list --hemi lh --meas thickness --skip --tablefile aparc_thickness_lh.txt
aparcstats2table --subjects $list --hemi lh --meas area --skip --tablefile aparc_area_lh.txt
aparcstats2table --subjects $list --hemi lh --meas meancurv --skip --tablefile aparc_meancurv_lh.txt
aparcstats2table --subjects $list --hemi rh --meas volume --skip --tablefile aparc_volume_rh.txt
aparcstats2table --subjects $list --hemi rh --meas thickness --skip --tablefile aparc_thickness_rh.txt
aparcstats2table --subjects $list --hemi rh --meas area --skip --tablefile aparc_area_rh.txt
aparcstats2table --subjects $list --hemi rh --meas meancurv --skip --tablefile aparc_meancurv_rh.txt
# parc a2009s
aparcstats2table --hemi lh --subjects $list --parc aparc.a2009s --meas volume --skip -t lh.a2009s.volume.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.a2009s --meas thickness --skip -t lh.a2009s.thickness.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.a2009s --meas area --skip -t lh.a2009s.area.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.a2009s --meas meancurv --skip -t lh.a2009s.meancurv.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.a2009s --meas volume --skip -t rh.a2009s.volume.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.a2009s --meas thickness --skip -t rh.a2009s.thickness.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.a2009s --meas area --skip -t rh.a2009s.area.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.a2009s --meas meancurv --skip -t rh.a2009s.meancurv.txt
# DKTatlas
aparcstats2table --hemi lh --subjects $list --parc aparc.DKTatlas --meas volume --skip -t lh.DKTatlas.volume.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.DKTatlas --meas thickness --skip -t lh.DKTatlas.thickness.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.DKTatlas --meas area --skip -t lh.DKTatlas.area.txt
aparcstats2table --hemi lh --subjects $list --parc aparc.DKTatlas --meas meancurv --skip -t lh.DKTatlas.meancurv.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.DKTatlas --meas volume --skip -t rh.DKTatlas.volume.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.DKTatlas --meas thickness --skip -t rh.DKTatlas.thickness.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.DKTatlas --meas area --skip -t rh.DKTatlas.area.txt
aparcstats2table --hemi rh --subjects $list --parc aparc.DKTatlas --meas meancurv --skip -t rh.DKTatlas.meancurv.txt
# parc BA_exvivo
aparcstats2table --hemi lh --subjects $list --parc BA_exvivo --meas volume --skip -t lh.BA_exvivo.volume.txt
aparcstats2table --hemi lh --subjects $list --parc BA_exvivo --meas thickness --skip -t lh.BA_exvivo.thickness.txt
aparcstats2table --hemi lh --subjects $list --parc BA_exvivo --meas area --skip -t lh.BA_exvivo.area.txt
aparcstats2table --hemi lh --subjects $list --parc BA_exvivo --meas meancurv --skip -t lh.BA_exvivo.meancurv.txt
aparcstats2table --hemi rh --subjects $list --parc BA_exvivo --meas volume --skip -t rh.BA_exvivo.volume.txt
aparcstats2table --hemi rh --subjects $list --parc BA_exvivo --meas thickness --skip -t rh.BA_exvivo.thickness.txt
aparcstats2table --hemi rh --subjects $list --parc BA_exvivo --meas area --skip -t rh.BA_exvivo.area.txt
aparcstats2table --hemi rh --subjects $list --parc BA_exvivo --meas meancurv --skip -t rh.BA_exvivo.meancurv.txt
