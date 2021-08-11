#!/bin/bash
echo "this script requires freeesurfer module";
echo "subject dir: $1";
echo "output prefix: $2";

module load freesurfer/5.3.0

export SUBJECTS_DIR=$1
output_prefix=$2

cd $SUBJECTS_DIR
# create subject list
ls | grep sub-  > subject.list

echo "Measuring thickess over DKT atlas"
aparcstats2table --hemi lh --subjectsfile subject.list --skip --meas thickness --parc aparc.DKTatlas --tablefile $output_prefix.DKT_lh.csv
aparcstats2table --hemi rh --subjectsfile subject.list --skip --meas thickness --parc aparc.DKTatlas --tablefile $output_prefix.DKT_rh.csv

echo "Measuring thickess over Destrieux atlas"
aparcstats2table --hemi lh --subjectsfile subject.list --skip --meas thickness --parc aparc.a2009s --tablefile $output_prefix.Destrieux_lh.csv
aparcstats2table --hemi rh --subjectsfile subject.list --skip --meas thickness --parc aparc.a2009s --tablefile $output_prefix.Destrieux_rh.csv