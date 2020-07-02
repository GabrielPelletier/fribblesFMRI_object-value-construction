% Parameters needed to run this script:
clear all
%========================================
main_output_path ='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';
main_input_path ='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/fmriprep';
%========================================

%% Which Subjects to RUN ?
% If you want a specific list of subjects 
participants = [435 436 437 438 439 440 441 442 443 444 445 446 447 448 449 450 451 452 453 454];

% If you want to process ALL subjets inside the fMRIPrep Path
% subjects = dir([main_input_path '/sub-*']);
% dirs = [subjects.isdir];
% subjects = {subjects(dirs).name}; % note that the strings will contain the 'sub-'

%% Description
%create_motion_confounds_files_after_fmriprep_v2
% created on August 2017 by rotem Botvinik Nezer
% edited on October 2018
% this function creates confound txt files in fsl format, based on the
% confounds.tsv created by fmriprep (version 1.1.4) and the parameters we decided to use.
% the output is txt file named confounds with the following columns (no
% titles):
% std dvars, six aCompCor, FramewiseDisplacement, six motion parameters (translation and rotation each in 3 directions) +
% their squared and temporal derivatives (Friston24).
% in addition, there an additional column for each volume that should be
% extracted due to FD>fd_threshold (default value for fd threshold is 0.9).
% this function also returns as output the number of "thrown" volumes for
% each subject (based on the fd value and threshold) to the num_bad_volumes
% variable
%
% if specific subjects / sessions / tasks are specified, only them
% will be calculated. Else, the default is all subjects, sessions, tasks
% and runs. If you want all subjects/tasks/sessions you can put an empty value in the
% relevant variable
% subjects, sessions and tasks should include the 'sub-' or 'ses-' or
% 'task-' string, and be a cell (unless they are empty for all
% subjects/sessions/tasks)

% Modified to adapt it for the FileNames and Confound variables of
% version 1.3.0.post2 of FMRIPrep.
% Gabriel Pelletier, April 2019

%% This might be useful if you want to run this script as a function
% if nargin < 2
%     main_output_path = '/export/home/DATA/schonberglab/NARPS/NARPS_MRI/analysis/derivatives';
%     if nargin < 1
%         main_input_path = '/export/home/DATA/schonberglab/NoBackup/NARPS_BIDSfromTACC/ds001205/derivatives/fmriprep';
%     end
% end
% 
% if nargin < 5 || isempty(tasks)
%     tasks = {'task-MGT','task-restingState'};
% end
%
% if nargin < 5 || isempty(sessions)
%     sessions = {'ses-01'};
% end
%
% if nargin < 4 || isempty(subjects)
%     subjects = dir([main_input_path '/sub-*']);
%     dirs = [subjects.isdir];
%     subjects = {subjects(dirs).name};
%     % note that the strings will contain the 'sub-'
% end
% 
% if nargin < 3
%     fd_threshold = 0.9;
% end
%%

tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% % Parameters needed to run this script:
% %========================================
% main_output_path ='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';
% main_input_path ='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/fmriprep';
% %========================================

% % Which Subjects to RUN ?
% % If you want to process ALL subjets inside the fMRIPrep Path
% % subjects = dir([main_input_path '/sub-*']);
% % dirs = [subjects.isdir];
% % subjects = {subjects(dirs).name}; % note that the strings will contain the 'sub-'
% 
% % If you want a specific list of subjects 
% subjects = {'sub-0301'}; % Should be strings containing the 'sub-0'

%%
%========================================
tasks = {'fribBids','fLoc'};
number_of_runs_per_task=[4,4];

%========================================
fd_threshold = 0.9;
%========================================

% define table headings
task_run_index=cell(1,sum(number_of_runs_per_task));

ind=1;
for task_ind = 1:length(tasks)
    for run_ind = 1:number_of_runs_per_task(task_ind)
        task_run_index{ind}=[tasks{task_ind},'_run-0',num2str(run_ind)];
        ind=ind+1;
    end
end

num_bad_volumes=cell(1+length(participants),1+length(task_run_index));
num_bad_volumes(1,:) = {'sub',task_run_index{:}};
num_bad_volumes(2:end,1) = num2cell(participants');

%% Loop through Subejcts, Tasks and Runs
for sub_ind = 1:length(participants)
    subject_name = ['sub-0' num2str(participants(sub_ind))];
    for task_ind = 1:length(tasks)
        runs = 1:number_of_runs_per_task(task_ind);
        % Different output directory depending on task   
        if strcmp(tasks{task_ind}, 'fLoc') 
            curr_output_dir = [main_output_path '/fLoc/' subject_name '/' ];
            col_ind_for_bad_vols=6;  
        elseif strcmp(tasks{task_ind}, 'fribBids')
            curr_output_dir = [main_output_path '/' subject_name '/' ];
            col_ind_for_bad_vols=2;  
        end
          
        for run_ind = 1:length(runs) 
            curr_input_dir = [main_input_path '/' subject_name '/func'];
            %curr_output_dir = [main_output_path '/' subject_name '/'];
            old_filename = [subject_name '_task-' tasks{task_ind} '_run-0' num2str(runs(run_ind)) '_desc-confounds_regressors.tsv'];
            
        % WITH FMAP
            %new_filename = [subject_name '_task-' tasks{task_ind} '_run-0' num2str(runs(run_ind)) '_desc-confounds_regressors_v2.tsv'];
        % NO FMAP                
            new_filename = [subject_name '_task-' tasks{task_ind} '_run-0' num2str(runs(run_ind)) '_desc-confounds_regressors_v2_nofmap.tsv'];            
            
            input_filename = [curr_input_dir '/' old_filename];
            output_filename = [curr_output_dir new_filename];
            % read confounds file
            try
                confounds = tdfread(input_filename);
            catch
                warning(['could not open confounds file for ' subject_name  ' ' tasks{task_ind}]);
                continue;
            end
            fprintf(['read confounds file of ' subject_name  ' ' tasks{task_ind} ' run 0' num2str(runs(run_ind)) ' in ' num2str(toc) '\n']);
            % create new confounds array
            new_confounds(:,1) = cellstr(confounds.std_dvars);
            new_confounds(:,2) = cellstr(confounds.framewise_displacement);
            new_confounds(1,1:2) = {'0'};
            new_confounds(:,1:2) = cellfun(@str2num,new_confounds(:,1:2),'UniformOutput',0);
            new_confounds(:,3) = num2cell(confounds.a_comp_cor_00);
            new_confounds(:,4) = num2cell(confounds.a_comp_cor_01);
            new_confounds(:,5) = num2cell(confounds.a_comp_cor_02);
            new_confounds(:,6) = num2cell(confounds.a_comp_cor_03);
            new_confounds(:,7) = num2cell(confounds.a_comp_cor_04);
            new_confounds(:,8) = num2cell(confounds.a_comp_cor_05);
            new_confounds(:,9) = num2cell(confounds.trans_x);
            new_confounds(:,10) = num2cell(confounds.trans_y);
            new_confounds(:,11) = num2cell(confounds.trans_z);
            new_confounds(:,12) = num2cell(confounds.rot_x);
            new_confounds(:,13) = num2cell(confounds.rot_y);
            new_confounds(:,14) = num2cell(confounds.rot_z);
            new_confounds(:,15) = num2cell((confounds.trans_x).^2);
            new_confounds(:,16) = num2cell((confounds.trans_y).^2);
            new_confounds(:,17) = num2cell((confounds.trans_z).^2);
            new_confounds(:,18) = num2cell((confounds.rot_x).^2);
            new_confounds(:,19) = num2cell((confounds.rot_y).^2);
            new_confounds(:,20) = num2cell((confounds.rot_z).^2);
            derivatives_motion_regressors = [diff(confounds.trans_x), diff(confounds.trans_y), diff(confounds.trans_z), diff(confounds.rot_x), diff(confounds.rot_y), diff(confounds.rot_z)];
            derivatives_motion_regressors = [zeros(1,6); derivatives_motion_regressors];
            new_confounds(:,21:26) = num2cell(derivatives_motion_regressors);
            new_confounds(:,27:32) = num2cell(derivatives_motion_regressors.^2);
            
            FD = cell2mat(new_confounds(:,2));
            bad_vols = FD>fd_threshold;
            num_bad_vols = sum(bad_vols);
            num_bad_volumes{sub_ind+1,col_ind_for_bad_vols} = num_bad_vols;
            col_ind_for_bad_vols=col_ind_for_bad_vols+1;
            if num_bad_vols == 0
                fprintf('no bad volumes, based on fd threshld %f\n',fd_threshold);
            else
                fprintf('found %d bad volumes with fd > %.2f\n', num_bad_vols,fd_threshold);
                bad_vols_loc = find(bad_vols);
                for vol_ind = 1:length(bad_vols_loc)
                    new_confounds(:,end+1) = {0};
                    new_confounds(bad_vols_loc(vol_ind),end) = {1};
                end
            end
            
            % save output confounds file
            dlmwrite(output_filename,new_confounds,'delimiter','\t');
            
            fprintf(['finished ' subject_name ' ' tasks{task_ind} ' run 0' num2str(runs(run_ind)) ' in ' num2str(toc) '\n\n']);
            clear confounds new_confounds;
        end %Run
    end %Task
end %Subject


%end % end function


