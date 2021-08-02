#!/bin/bash
echo "this script requires minc-tools";
echo "input dir: $1";
echo "output dir: $1";
for i in $1/*.mnc; do mnc2nii -short -nii $i; done
for i in $1/*.nii; do gzip $i; done
