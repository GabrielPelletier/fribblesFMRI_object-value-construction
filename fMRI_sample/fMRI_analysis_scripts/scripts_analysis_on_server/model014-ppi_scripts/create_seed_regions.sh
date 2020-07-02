#!/bin/sh

ppi_path=/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model002/ppi_seed_regions
cd $ppi_path

create_seed_rois()
{
echo creating seed region mask
echo $region_name session $session cope $cope_level1 $cope_level2 $cope_level3 cluster $cluster_num
for size_sphere in 6 8
do
    echo sphere size $size_sphere
    input_img=/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model001/group/responsetosnacks/${session}/cope${cope_level1}.gfeat/cope${cope_level2}.feat/cluster_mask_zstat${cope_level3}.nii.gz
    output_img=/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model002/ppi_seed_regions/${region_name}.nii.gz
    fslmaths ${input_img} -thr ${cluster_num} -uthr ${cluster_num} -bin ${output_img}

    echo creating a sphere around peak activation
    echo peak activation entered manually: ${peak_activation_mni_coordinates}
    echo peak activation from the gfeat directory:
    cat /export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model001/group/responsetosnacks/${session}/cope${cope_level1}.gfeat/cope${cope_level2}.feat/lmax_zstat${cope_level3}_std.txt
    echo peak activation voxel location: ${peak_activation_voxel_location}
    standard_path=/share/apps/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
    fslmaths ${standard_path} -roi ${peak_activation_voxel_location} 0 1 roi_img_${region_name}.nii.gz
    fslmaths roi_img_${region_name}.nii.gz -kernel sphere ${size_sphere} -fmean -bin ${region_name}_sphere${size_sphere}_mni_dim.nii.gz
    # this is in mni voxel dimensions. Convert to our voxel dimensions:
    flirt -in ${region_name}_sphere${size_sphere}_mni_dim.nii.gz -ref ${input_img} -applyxfm -usesqform -out ${region_name}_sphere${size_sphere}_native_dim.nii.gz
    fslmaths ${region_name}_sphere${size_sphere}_native_dim.nii.gz -thr 0.5 -bin ${region_name}_sphere${size_sphere}_native_dim.nii.gz
    # multiply the sphere and the cluster mask to have only voxels within the activation
    fslmaths ${region_name}_sphere${size_sphere}_native_dim.nii.gz -mul ${output_img} ${region_name}_sphere${size_sphere}_mul_cluster_mask.nii.gz
 
    # multiply the sphere and the brain mask to have only voxels within the activation
    fslmaths ${region_name}_sphere${size_sphere}_native_dim.nii.gz -mul brain_mask_native_voxel_dim.nii.gz ${region_name}_sphere${size_sphere}_mul_brain_mask.nii.gz
done
}

# convert the mni brain mask to our voxel dimensions
flirt -in /share/apps/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -ref ${input_img} -applyxfm -usesqform -out brain_mask_native_voxel_dim.nii.gz
fslmaths brain_mask_native_voxel_dim.nii.gz -thr 0.5 -bin brain_mask_native_voxel_dim.nii.gz

region_name='left_temporal_occipital_after'
# taken from after minus before, all go minus nogo, flame 3.1
session=after_before
cope_level1=17
cope_level2=1
cope_level3=1
cluster_num=2
peak_activation_mni_coordinates="-44 1 -60 1 -13 1"
#peak_activation_voxel_location="26 1 36 1 26 1" # our fmri voxel dimensions
peak_activation_voxel_location="67 1 33 1 29 1" # mni voxel dimensions

create_seed_rois

region_name='right_occipital'
#region_name='right_temporal_occipital_or_lateral_occipital'
# taken from after minus before, HV go minus nogo, flame 2.3
session=after_before
cope_level1=18_zthresh23
cope_level2=1
cope_level3=1
cluster_num=1
peak_activation_mni_coordinates="38 1 -62 1 -18 1"
#peak_activation_voxel_location="67 1 35 1 24 1" # our fmri voxel dimensions
peak_activation_voxel_location="26 1 32 1 27 1" # mni voxel dimensions
create_seed_rois

region_name='left_ofc'
# taken from after minus before, all go minus nogo, flame 3.1
session=after_before
cope_level1=17
cope_level2=1
cope_level3=1
cluster_num=1
peak_activation_mni_coordinates="-38 1 44 1 -15.5 1"
#peak_activation_voxel_location="29 1 88 1 25 1" # our fmri voxel dimensions
peak_activation_voxel_location="64 1 85 1 28 1" # mni voxel dimensions
create_seed_rois

region_name='vmpfc'
# taken from after minus before, only all Go, flame 3.1
session=after_before
cope_level1=23
cope_level2=1
cope_level3=1
cluster_num=1
peak_activation_mni_coordinates="-4 1 50 1 -18 1"
#peak_activation_voxel_location="46 1 91 1 24 1" # our fmri voxel dimensions
peak_activation_voxel_location="47 1 88 1 27 1" # mni voxel dimensions
create_seed_rois

region_name='left_lateral_occipital_cortex'
# taken from after minus before, LV go minus nogo, flame 3.1
session=after_before
cope_level1=19
cope_level2=1
cope_level3=1
cluster_num=1
peak_activation_mni_coordinates="-48 1 -72 1 37 1"
#peak_activation_voxel_location="24 1 30 1 46 1" # our fmri voxel dimensions
peak_activation_voxel_location="69 1 27 1 54 1" # mni voxel dimensions
create_seed_rois

region_name='left_temporal_occipital_followup'
# taken from followup, all go minus nogo, flame 2.3
session=followup_before
cope_level1=17_zthresh23
cope_level2=3
cope_level3=1
cluster_num=1
peak_activation_mni_coordinates="-48 1 -50 1 -13 1"
peak_activation_voxel_location="24 1 41 1 26 1" # our fmri voxel dimensions
peak_activation_voxel_location="69 1 38 1 29 1" # mni voxel dimensions
create_seed_rois
