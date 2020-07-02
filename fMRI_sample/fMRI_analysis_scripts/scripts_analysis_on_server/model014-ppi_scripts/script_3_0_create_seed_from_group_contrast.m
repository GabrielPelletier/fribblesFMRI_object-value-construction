%% script_3_0_create_vmpfc_from_group_contrast
%
% From model013, use the [ConRateValue > SumRateValue] vmPFC cluster from group 
% analysis to create the vmPFC seed. 
%
%
%%
clear




main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';


% Set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% nifti file containing the results from the contrast from which you want
% to build your ROI
contrast_nifti = [main_path 'group/model/model013/n42_3.1_vmPFC/group_task-fribBids_cope6.gfeat/cope1.feat/thresh_zstat1.nii.gz'];

% Output image path and name
out_roi_image = [main_path 'ROI_standard_masks/vmpfc_model013_cope6_thresh_zstat1_3.1'];

% fsl command
system(['fslmaths ' contrast_nifti ' -thr 3.1 -bin ' out_roi_image]);
