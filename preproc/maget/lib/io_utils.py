import nibabel as nib
import glob
import os

def get_masked_image(img_path, mask_path, masked_img_path):
    ''' Applies brain binary mask to nii.gz image'''

    # load main image
    zmap = nib.load(img_path)
    img_data = zmap.get_data()

    # load anothor image to mask
    mask = nib.load(mask_path)
    mask_data = mask.get_data()

    # do masking 
    masked_img_data = mask_data * img_data

    #save the new file out  
    masked_img = nib.Nifti1Image(masked_img_data, header=zmap.header, affine=zmap.affine)
    nib.save(masked_img, masked_img_path)  