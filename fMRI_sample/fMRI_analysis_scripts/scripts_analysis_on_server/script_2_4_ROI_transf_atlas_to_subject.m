%%
% For ROI analysis;
% 
% Tranform the various Atlas-derived ROIs to fit the voxel size and 
% dimensions of the subjects' brains after they were registered to standard 
% space.
%
% Depending on the ROIs, different steps are done: The probabilistic ROI
% masks are Binarized according to a certain threshold that should be
% carefully selected.
%
% These ROIs were defined for analysis of the fribbles_fMRI experiment.
% Gabriel Pelletier, April 2019
%

%% Details 
clear

% Set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';

% Which participants do we run?
participants = [0309 0311 0402 0403 0406 0407 0408 0410 0411 ...
                0412 0413 0414 0415 0417 0418 0419 0421 0422 0428 0429 ...
                0430 0431 0432 0433 0434 0435 0436 0437 0438 0439 0440 ...
                0441 0444 0445 0446 0447 0449 0450 0452 0453 0454];
            
% 0405 and 0448 are excluded from ROI analysis because fLoc data was not
% colelcted due to lack of time.
            
% Which ROI(s)?
rois = {'PRC' 'lOFC' 'vmpfc' 'LOC' 'FFA' 'PPA' 'HIP'};

% Do you want to Create the PRC binary mask with a specific threshold? Set
% to 0 if it was already done to the desired threshold. If set to 0, you
% have to hard-code the threshold value in the PRC_file_name.nii.gz used in
% the transformation step.
do_PRC_bin_thresh = 0;


%% For perirhinal cortex ROI
% need to binarize with a specific THRESHOLD (unless it was already done) 
if do_PRC_bin_thresh
    % Binarise probabilistic ROI (Carefuly select threshold)
    % Select thesrhold: it depends on how many subjects were used to create the probaiblistic maps (6/17 > 35% prob)
    thresh = '6';
    ROI_prob_mask_name = 'currbio07_PRC_prob_mask.nii.gz'; % The probabilistic PRC map
    INPUTimage = [main_path '/ROI_standard_masks/' ROI_prob_mask_name];
    OUTPUTimage = [main_path '/ROI_standard_masks/currbio07_PRC_bin_mask_thresh-' thresh '.nii.gz'];    
    % Command
    system(['fslmaths ' INPUTimage ' -thr ' thresh ' -bin ' OUTPUTimage]); 
end
                

%%
for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    % Image that will be used to transform the ROIs (one func run. All the
    % stats images will be in this same space. 
    REFimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_task-fribBids_run-01_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold.nii'];
    
    for roi_ind = 1:length(rois)
    ROINAME = rois{roi_ind}

        switch ROINAME
            case{'vmpfc'} % For vmpfc ROI mask (from T Schonberg lab) 
                atlas_ROI_mask_name = 'vmpfc_mask2.nii.gz';          
                % Tranform the Atlas ROI to fit the subject's registered stats image (dimensions and Voxel size)
                INPUTimage = [main_path '/ROI_standard_masks/' atlas_ROI_mask_name]; % The Atlas ROI image to resample (transform)
                OUTPUTimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
                % Command
                system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);
                system(['fslmaths ' OUTPUTimage ' -thr 0.5 -bin ' OUTPUTimage]); % Re-binarize it
                
            case{'lOFC' 'mOFC'} % For OFC ROI masks (both binary, both in AAL atlas)
                atlas_ROI_mask_name = ['AAL_' ROINAME '_bin_mask.nii.gz'];          
                % Tranform the Atlas ROI to fit the subject's registered stats image (dimensions and Voxel size)
                INPUTimage = [main_path '/ROI_standard_masks/' atlas_ROI_mask_name]; % The Atlas ROI image to resample (transform)
                OUTPUTimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
                % Command
                system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);
                system(['fslmaths ' OUTPUTimage ' -thr 0.5 -bin ' OUTPUTimage]); % Re-binarize it 
                
            case {'PRC'} % For perirhinal cortex ROI 
                thresh = '6';
                atlas_ROI_mask_name = ['currbio07_PRC_bin_mask_thresh-' thresh '.nii.gz'];
                % Tranform the Atlas ROI to fit the subject's registered stats image
                INPUTimage = [main_path '/ROI_standard_masks/' atlas_ROI_mask_name];
                OUTPUTimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
                % Commands
                system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);% Does the transform                 
                system(['fslmaths ' OUTPUTimage ' -thr 0.5 -bin ' OUTPUTimage]); % Re-binarize it
                
            case {'HIP'}
                atlas_ROI_mask_name = ['harvardoxford_HippocampusBilat_thr25_bin.nii.gz'];
                % Tranform the Atlas ROI to fit the subject's registered stats image
                INPUTimage = [main_path '/ROI_standard_masks/' atlas_ROI_mask_name];
                OUTPUTimage = [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
                % Commands
                system(['flirt -in ' INPUTimage ' -ref ' REFimage ' -applyxfm -usesqform -out ' OUTPUTimage]);% Does the transform                 
                system(['fslmaths ' OUTPUTimage ' -thr 0.5 -bin ' OUTPUTimage]); % Re-binarize it
            
            case {'LOC' 'FFA' 'PPA'} % For all functionnal localizer derived ROIS (fLoc)
                % don't do anything but copy the file in same location and
                % same name format as the other ROIs.(with the fribBids
                % derivatives)
                copyfile([main_path '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-' ROINAME '_mask.nii.gz'], [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz']);
                copyfile([main_path '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-' ROINAME '_mask.nii.gz'], [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz']);
                copyfile([main_path '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-' ROINAME '_mask.nii.gz'], [main_path '/sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz']);
                
        end % switch    
    end % rois
end % subs






