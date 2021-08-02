#!/bin/bash
echo "this script requires minc-tools";
echo "input dir: $1";
echo "output dir: $1";
for i in $1/*.nii*; do nii2mnc -short $i `echo $i | cut -d "." -f1`.mnc; done
#for i in $1/*.nii*; do echo `echo $i | cut -d "." -f1`.mnc; done
