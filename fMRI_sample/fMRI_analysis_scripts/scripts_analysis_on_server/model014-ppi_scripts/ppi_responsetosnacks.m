function ppi_responsetosnacks(participants_study, sessions, seed_roi_suffix)
% this function creates the ppi regressors for all participants, sessions
% and runs of the response to snacks task
% if you want just some of the paricipants, input the numbers as first
% argument as a vector. I you want all- input nothing or an empty vector []
% as the first input argument.
% If you want just some of the sessions, input it as second argument as a
% cell array. For all sessions input nothing or an empty cell ({}) in the second argument.
% 3rd input argument is the suffix of the seed rois filenames. Default is
% 'sphere8_mul_brain_mask.nii.gz'
%
% was created by Rotem Botvinik Nezer on January 2018
% basd on codes from Jeanette Mumford

tic

% add spm path
spm5_path = '/share/apps/spm/spm5';
addpath(spm5_path);

% add ppi codes path
addpath('/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/codes/ppi');

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

ppi_path = '/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model002/ppi_seed_regions';
main_path = '/export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives';
if nargin < 1 || isempty(participants_study)
    participants_study = [102:108, 110:121, 123:128, 130:135, 137:141];
end

if nargin < 2 || isempty(sessions)
   sessions = {'before','after','followup'}; 
end

if nargin < 3
   seed_roi_suffix = 'sphere8_mul_brain_mask.nii.gz'; 
end

participants_study_followup = [103:108, 110:111, 113:116, 118:120, 123:128, 132:135, 138, 140];
num_participants = length(participants_study);
num_runs = 2;

num_sessions = length(sessions);
seed_rois = dir([ppi_path '/*_' seed_roi_suffix]);
num_seed_rois = length(seed_rois);

for participant_ind = 1:num_participants
    participant_num = participants_study(participant_ind);
    participant_num_str = num2str(participant_num);
    participant_num_str = ['0' participant_num_str(2:3)];
    participant_str = ['sub-study' participant_num_str];
    disp(participant_str);
    for session_ind = 1:num_sessions
        session = sessions{session_ind};
        session_str = ['ses-' session];
        if strcmp(session, 'followup') && ~ismember(participant_num,participants_study_followup)
            continue;
        end
        disp(session_str);
        for run_ind = 1:num_runs
            disp(num2str(run_ind));
            for seed_ind = 1:num_seed_rois
                seed_roi_filename = seed_rois(seed_ind).name;
                seed_roi_name = seed_roi_filename(1:end-30);
                disp(seed_roi_name);
                path_for_txt_file = [main_path '/' participant_str '/' session_str '/model/model002/onsets/' session_str '_task-responsetosnacks_run-0' num2str(run_ind)];
                if ~isdir(path_for_txt_file)
                    mkdir(path_for_txt_file);
                end
                time_series_txt_full_filename = [path_for_txt_file '/' seed_roi_name '_mean_ts.txt'];
                mask_img = [ppi_path '/' seed_roi_filename];
                input_img = [main_path '/' participant_str '/' session_str '/' participant_str '_' session_str '_task-responsetosnacks_run-0' num2str(run_ind) '_bold_space-MNI152NLin2009cAsym_preproc_brain.nii.gz'];
                disp('creating meants');
                % calculate and save mean time-series to txt file
                system(['fslmeants -i ' input_img ' -m ' mask_img ' -o ' time_series_txt_full_filename]);
                
                % define feat dir (of GLM prior to ppi)
                featdir = [main_path '/' participant_str '/' session_str '/model/model001/' participant_str '_' session_str '_task-responsetosnacks_run-0' num2str(run_ind) '.feat'];
                
                %% create ppi regressors for all go vs. nogo items
                contrast_all_go = [1 0 1 0 0 0 0 0 0 0 0 0 0]; % all go items
                contrast_all_nogo = [0 1 0 1 0 0 0 0 0 0 0 0 0]; % all nogo items (in probe)
                % put 1 in the 4th input for fsl_ppi to see the plots- only
                % if you run a few otherwise you'll get MANY figures...
                disp(['creating regressor all_go']);
                [PPI_all_go,design1_all_go] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_all_go,0);
                disp(['creating regressor all_nogo']);
                [PPI_all_nogo,design2_all_nogo] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_all_nogo,0);
                
                %These are already convolved, so use 1 column format with *NO* HRF
                %convolution in FSL.
                ppi_all_go=PPI_all_go.ppi;
                ppi_all_nogo=PPI_all_nogo.ppi;
                
                % save the regressors
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_all_go.txt'], 'ppi_all_go', '-ascii')
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_all_nogo.txt'], 'ppi_all_nogo', '-ascii')
                
                %% create ppi regressors for HV go vs. nogo items
                contrast_HV_go = [1 0 0 0 0 0 0 0 0 0 0 0 0]; % HV go items
                contrast_HV_nogo = [0 1 0 0 0 0 0 0 0 0 0 0 0]; % HV nogo items (in probe)
                disp(['creating regressor HV_go']);
                [PPI_HV_go,design_HV_go] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_HV_go,0);
                disp(['creating regressor HV_nogo']);
                [PPI_HV_nogo,design_HV_nogo] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_HV_nogo,0);

                %These are already convolved, so use 1 column format with *NO* HRF
                %convolution in FSL.
                ppi_HV_go=PPI_HV_go.ppi;
                ppi_HV_nogo=PPI_HV_nogo.ppi;
                
                % save the regressors
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_HV_go.txt'], 'ppi_HV_go', '-ascii')
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_HV_nogo.txt'], 'ppi_HV_nogo', '-ascii')
                
                %% create ppi regressors for LV go vs. nogo items
                contrast_LV_go = [0 0 1 0 0 0 0 0 0 0 0 0 0]; % LV go items
                contrast_LV_nogo = [0 0 0 1 0 0 0 0 0 0 0 0 0]; % LV nogo items (in probe)
                disp(['creating regressor LV_go']);
                [PPI_LV_go,design_LV_go] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_LV_go,0);
                disp(['creating regressor LV_nogo']);
                [PPI_LV_nogo,design_LV_nogo] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_LV_nogo,0);
                
                %These are already convolved, so use 1 column format with *NO* HRF
                %convolution in FSL.
                ppi_LV_go=PPI_LV_go.ppi;
                ppi_LV_nogo=PPI_LV_nogo.ppi;
                
                % save the regressors
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_LV_go.txt'], 'ppi_LV_go', '-ascii')
                save([path_for_txt_file '/ppi_regressor_' seed_roi_name '_LV_nogo.txt'], 'ppi_LV_nogo', '-ascii')
                disp(['done with ' seed_roi_name]);
            end
            disp(['done with run ' num2str(run_ind)]);
        end
        disp(['done with ' session_str]);
    end
    disp(['done with ' participant_str]);
end

time_it_took = toc;
disp(['done in ' num2str(time_it_took) 'secs']);

end

