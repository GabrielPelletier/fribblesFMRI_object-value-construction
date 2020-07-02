
% Set those parameters
model_id = 'model013';
cope_lev_1 = 16; % Which LEVEL-1 cope do you want to analyse.
cope_lev_2 = 1;

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% set paths
main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';
group_analysis_path = [main_path 'group/model/' model_id '/'];
percent_signal_change_path = [group_analysis_path 'ROI_percent_signal_change/'];

%% 
subjects = [309 311 402 403 406 407 408 410 411 ...
                412 413 414 415 417 418 419 421 422 428 429 ...
                430 431 432 433 434 435 436 437 438 439 440 ...
                441 444 445 446 447 449 450 452 453 454];
            
regions_of_interest = {'LOC'; 'FFA'; 'PPA'; 'PRC'; 'HIP'};

% For each (level-1) COPE, determine the Contrast Fix Factor
num_of_copes_lev1 = 16;
contrast_names_lev1 = {''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''};
contrast_fix_lev1 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1];
num_of_copes_lev2 = 1;
contrast_names_lev2 = {'mean'};
contrast_fix_lev2 = 1;

baseline_2_max = 0.5872;
% hight with double gamma HRF - 1-s stim =  0.2088
% hight with double gamma HRF - 2-s stim =  0.4075
% hight with double gamma HRF - 3-s stim =  0.5872


%% Convert copes to percent signal change
    
    % Figure out the correct Scale Factor
    % scale factor = 100 * (baseline-to-max range lvl-1 * baseline-to-max range lvl-2) / contrast fix
    scale_factor = (100 * baseline_2_max ^ 2) / (contrast_fix_lev1(cope_lev_1) * contrast_fix_lev2(cope_lev_2));
    mkdir(percent_signal_change_path);
    per_signal_change_mat = nan([length(subjects), length(regions_of_interest)]);
 %   h = waitbar(0,'Converting to percent signal change');
   
 % Convert the entire level-2 COPE image to Percent Signal Change for each subject
    for i = 1 : length(subjects)
        sub_name = sprintf('sub-0%i',subjects(i));
        subject_path = [main_path, sub_name '/'];
        lev_2_path = sprintf('%smodel/%s/task-fribBids.gfeat/cope%i.feat', subject_path, model_id, cope_lev_1);
        lev_2_cope_img = sprintf('%s/stats/cope%i.nii.gz', lev_2_path, cope_lev_2);
        lev_2_mean_func= ([lev_2_path,'/mean_func.nii.gz']);
        per_signal_change_img = [percent_signal_change_path, sub_name, '_lvl1-cope' num2str(cope_lev_1) '_lvl2-cope' num2str(cope_lev_2)];
        
        %%% Do the clalculation. This will output an image of %
        % change 'per_signal_change_img'
        % Use the level-2 cope image, and the level-2 mean_func image as
        % reference.
        system(['fslmaths ',lev_2_cope_img,' -mul ',num2str(scale_factor),' -div ',lev_2_mean_func,' ',per_signal_change_img]);
        %waitbar(i/length(subjects),h)
        
        % Loop ROIs (or clusters) and get the MEAN Percent Change within each
        % ROI (or cluster) for this subject
        for roi = 1 : length(regions_of_interest)
            roi_mask = [subject_path sub_name '_roi-' regions_of_interest{roi} '_space-standard_desc-mask.nii.gz'];
            
            %%% Use fslstats -M (mean function)
            % fslstats image_with_values -k mask_image -M (or -m?)
            [~,mean_change_roi] = system(['fslstats ', per_signal_change_img, ' -k ',roi_mask,' -m ']);
            per_signal_change_mat(i, roi) = str2double(mean_change_roi); % remove the last nan output;
            
        end
    end
    
 %close(h)
 
% Save resutls
ROI_percent_change = array2table([subjects', per_signal_change_mat], 'VariableNames', ['subject_id'; regions_of_interest])
save([percent_signal_change_path 'lvl1-cope' num2str(cope_lev_1) '_per_signal_change.mat'], 'ROI_percent_change');
    
  