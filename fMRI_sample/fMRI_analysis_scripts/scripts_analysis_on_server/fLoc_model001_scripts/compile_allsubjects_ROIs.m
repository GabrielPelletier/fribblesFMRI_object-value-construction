%% 
% Loop through all subjects and group their fLoc contast derived ROIs
% in a common folder so they can all be copied somewhere else easily.

%%

% Which participants do we run?
participants = [0309 0311 0402 0403 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0449 0450 0452 0453 0454];
      
%participants = [0309];
      

main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/fLoc/';

for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    %    LOC ROI 
    copyfile([main_path '/sub-' SUBNUM '/sub-' SUBNUM '_desc-LOC_mask.nii.gz'], [main_path 'group_rois/sub-' SUBNUM '_desc-LOC_mask.nii.gz']);
    %    FFA ROI 
    copyfile([main_path '/sub-' SUBNUM '/sub-' SUBNUM '_desc-FFA_mask.nii.gz'], [main_path 'group_rois/sub-' SUBNUM '_desc-FFA_mask.nii.gz']);
    %    PPA ROI 
    copyfile([main_path '/sub-' SUBNUM '/sub-' SUBNUM '_desc-PPA_mask.nii.gz'], [main_path 'group_rois/sub-' SUBNUM '_desc-PPA_mask.nii.gz']);    
end
