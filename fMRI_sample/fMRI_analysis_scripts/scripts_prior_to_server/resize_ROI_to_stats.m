
 %% set FSL environment
 setenv('FSLDIR','/usr/local/fsl/bin/fsl');  % this to tell where FSL folder is
 setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
 setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin/fsl']);

addpath /usr/local/fsl/bin/

%%
main_path = '/Users/roni/Desktop/GabrielP/fribblesFMRI/ROIs_standard/';

ROINAME = 'vmpfc_mask_RESIZED';
%atlas_ROI_mask_name = ['AAL_' ROINAME '_bin_mask.nii.gz'];
%atlas_ROI_mask_name = 'HarOxf_LOC_sup_bil_prob.nii.nii.gz';
atlas_ROI_mask_name = 'vmpfc_mask.nii.nii.gz';

% The reference image of the right size.
REFimage = '/Users/roni/Desktop/GabrielP/fribblesFMRI/fmri_sample/group_model/model005/group_task-fribBids_cope1+.gfeat/bg_image.nii.gz'; 

% Tranform the Atlas' LOC ROI to fit the subject's registered stats image (dimensions and Voxel size)
INPUTimage = [main_path atlas_ROI_mask_name]; % The Atlas ROI image to resample (transform)
OUTPUTimage = [main_path ROINAME '.nii.gz'];
% Command
system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);
%system(['fslmaths ' OUTPUTimage ' -thr 30 -bin ' OUTPUTimage]); % Re-binarize it
