%function main_ppi_fribbles(seed_roi_suffix)

% This function creates the ppi regressors for all participants
% and runs of the fribBids task (fribbles_fMRI experiment).

% Input argument seed_roi_suffix gument is the suffix of the seed rois filenames. Default is
% 'sphere8_mul_brain_mask.nii.gz'
%
% Created by Rotem Botvinik Nezer on January 2018
% based on codes from Jeanette Mumford
%
% Adapted by Gabriel Pelletier in June 2019
% for analysis of the fribbles_fMRI experiment


%% Details
tic

% Which subject to run
participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];
      
num_participants = length(participants);

% How many run (normally = 4)
num_runs = 4;

% ppi model ID
modelID = 'model014';

% Which model (prior to ppi) do we use?
prior_ppi_modelID = 'model013';


% Paths
main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';
% Path of the seed ROI.nii.gz files
%ppi_path = [main_path '/' ...];
% spm path
spm5_path = '/share/apps/spm/spm5';
addpath(spm5_path);
% ppi codes path
addpath(['/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '-ppi_scripts']);
% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);


%seed_rois = {'mOFC' 'lOFC'};
seed_rois = {'model013_cope6_vmpfc'};
num_seed_rois = length(seed_rois);

%% 
for participant_ind = 1:num_participants % Loop through subjects
    participant_num = participants(participant_ind);
    participant_num_str = ['0' num2str(participant_num)];
    participant_str = ['sub-' participant_num_str];
    fprintf('Participant: %s \n', participant_str);
    
        for run_ind = 1:num_runs % Loop through task runs
            fprintf('Run: %s \n', num2str(run_ind));

            for seed_ind = 1:num_seed_rois % Loop through seed ROIs (one per PPI model)
                seed_roi_name = seed_rois{seed_ind};
                fprintf('Seed ROI: %s \n', seed_roi_name);
                path_for_txt_file = [main_path '/' participant_str '/model/' modelID '-ppi-' seed_roi_name '/onsets/task-fribBids_run-0' num2str(run_ind)];
                if ~isdir(path_for_txt_file)
                    mkdir(path_for_txt_file);
                end
                % text file that will contain the seed ROI timeseries
                time_series_txt_full_filename = [path_for_txt_file '/' seed_roi_name '_mean_ts.txt'];
                % The seed ROI mask image
               mask_img = [main_path '/ROI_standard_masks/vmpfc_model013_cope6_thresh_zstat1_3.1'];
               %mask_img = [main_path '/' participant_str '/' participant_str '_roi-' seed_roi_name '_space-standard_desc-mask.nii.gz'];
                % BOLD file for this run for this subject
                input_bold = [main_path '/' participant_str '/' participant_str '_task-fribBids_run-0' num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold.nii.gz'];
                % calculate and save mean time-series to txt file
                disp('Creating meants...');
                    % Command
                    system(['fslmeants -i ' input_bold ' -m ' mask_img ' -o ' time_series_txt_full_filename]);
                
                % Feat directory of GLM PRIOR to ppi)
                featdir = [main_path '/' participant_str '/model/' prior_ppi_modelID '/task-fribBids_run-0' num2str(run_ind) '.feat'];
               
                %% create ppi regressors
                % fsl_ppi.m script Deconvolves the seed BOLD time-series

                
                %%% regressor for CONJ condition(unmodulated by value)
                contrast_conj = [0 0 0 0 1 0 0 0 0 0 0]; % ConRate (UNMODULATED), = RatingScale Configural trials
                % put 1 in the 4th input for fsl_ppi to see the plots- only
                % if you run a few otherwise you'll get MANY figures...
                disp('Creating regressor CONJ ...');
                [PPI_conj, design_conj] = fsl_ppi(featdir, time_series_txt_full_filename, contrast_conj, 0);                
                %These are already convolved, so use 1 column format with *NO* HRF
                %convolution in FSL.
                ppi_conj=PPI_conj.ppi;
                % save the regressors
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_ConRate.txt'], 'ppi_conj', '-ascii')
                
                %%% regressor for SUMM condition (unmodulated by value)
                contrast_summ = [0 0 0 0 0 0 1 0 0 0 0]; % SumRate (UNMODULATED) = RatingScale Summation/Elemental Trials
                disp('Creating regressor SUMM ...');
                [PPI_summ, design_summ] = fsl_ppi(featdir, time_series_txt_full_filename,contrast_summ, 0);
                %These are already convolved, so use 1 column format with *NO* HRF
                %convolution in FSL.
                ppi_summ=PPI_summ.ppi;
                % save the regressors
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_SumRate.txt'], 'ppi_summ', '-ascii')

            end
            disp(['Done with run ' num2str(run_ind)]);
        end
    disp(['Done with ' participant_str]);
end

time_it_took = toc;
disp(['All done in ' num2str(time_it_took) 'secs']);

%end % End of function, if you want to run this as a function.
