# Author: Nikhil Bhagwat
# Date: 1 Aug 2021
# This script will take preprocessed brains from fmriprep and mask them. 

import nibabel as nib
import glob
import os
import sys
import argparse

sys.path.append('../')
from lib.io_utils import get_masked_image


def main():

    # argparse
    parser = argparse.ArgumentParser(description='Script to mask fmriprep procesed brains with corresponding masks')

    parser.add_argument('--img_dir', dest='img_dir', help='input dir or images')
    parser.add_argument('--mask_dir', help="pmask_dir", default='input dir of masks')
    parser.add_argument('--masked_img_dir', dest='masked_img_dir', help='output dir to save masked images')

    args = parser.parse_args()

    img_dir = args.img_dir
    mask_dir = args.mask_dir
    masked_img_dir = args.masked_img_dir

    img_paths = os.listdir(img_dir)
    print('Number of subjects in {}: {}'.format(img_dir, len(img_paths)))

    for img_path in img_paths:
        sub_name = img_path.rsplit('-',1)[0]
        print('Subject name: {}'.format(sub_name))
        img_path = img_dir + sub_name + '-preproc_T1w.nii.gz'
        mask_path = mask_dir + sub_name + '-brain_mask.nii.gz' 
        masked_img_path = masked_img_dir + sub_name + '-masked_preproc_T1w.nii.gz'

        get_masked_image(img_path, mask_path, masked_img_path)

if __name__=='__main__':
   main()