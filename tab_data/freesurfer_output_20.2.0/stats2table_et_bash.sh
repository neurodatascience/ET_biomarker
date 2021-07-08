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
list="sub-0016 sub-0061 sub-0081 sub-0119 sub-0122 sub-0134 sub-0139 sub-0140 sub-0141 sub-0142 sub-0143 sub-0145 sub-0146 sub-0147 sub-0178 sub-1012 sub-1120 sub-1160 sub-1230 sub-1310 sub-1340 sub-1450 sub-1500 sub-1690 sub-1890 sub-1920 sub-2400 sub-3600 sub-3700 sub-3900 sub-4200 sub-4300 sub-4700 sub-5700 sub-7000 sub-7400 sub-7800 sub-8000"

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
