%% 
% Tranform fmriprep-standard space (in whihch ALL the analyses are done)
% Into MNI152 space (to overlapp with MNI FLSEYES template correctly).
%%



%% Details 
clear

% Set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

%%

REFimage = '/share/apps/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz';

%INPUTimage = [main_path '/ROI_standard_masks/' atlas_ROI_mask_name]; % The Atlas ROI image to resample (transform)
OUTPUTimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];

% Do transform
system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);
% Re-binarize image
% system(['fslmaths ' OUTPUTimage ' -thr 0.5 -bin ' OUTPUTimage]);