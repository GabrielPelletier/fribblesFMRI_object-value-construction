%CREATE_BOLD_BRvAIN
% this script creates brain images (skull stripped) from the preproc and
% brainmask images there are the output of fmriprep (version 1.3.0.post2)
%
% subjects, sessions and tasks should include the 'sub-' or 'ses-' or
% 'task-' string, and be a cell (unless they are empty for all
% subjects/sessions/tasks)

%clear all

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

output_path =   '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';
fmriprep_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/fmriprep';

%% Which Subjects to RUN ?
% If you want to process ALL subjets inside the fMRIPrep Path
% subjects = dir([fmriprep_path '/sub-*']);
% dirs = [subjects.isdir];
% subjects = {subjects(dirs).name}; % note that the strings will contain the 'sub-'

% If you want a specific list of subjects 
participants = [435 436 437 438 439 440 441 442 443 444 445 446 447 448 449 450 451 452 453 454];

%% Which Task?
tasks = {'fribBids','fLoc'};
number_of_runs_per_task=[4,4];


%%
for sub_ind = 1:length(participants)
    subject_name = ['sub-0' num2str(participants(sub_ind))];
        for task_ind = 1:length(tasks)
            curr_fmriprep_dir = [fmriprep_path '/' subject_name   '/func'];
            % Different output directory depending on task
            if strcmp(tasks{task_ind}, 'fLoc') 
                curr_output_dir = [output_path '/fLoc/' subject_name '/' ];
            elseif strcmp(tasks{task_ind}, 'fribBids')
                curr_output_dir = [output_path '/' subject_name '/' ];
            end
            
            if ~isdir(curr_output_dir)
                mkdir(curr_output_dir);
            end   
            
            for run_ind = 1:number_of_runs_per_task(task_ind)
                preproc_file = [curr_fmriprep_dir '/' subject_name '_task-'   tasks{task_ind} '_run-0' num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
                brainmask_file = [curr_fmriprep_dir '/' subject_name '_task-'   tasks{task_ind} '_run-0' num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz'];
                
                % With FMAP
                output_file = [curr_output_dir '/' subject_name '_task-'   tasks{task_ind} '_run-0' num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold.nii.gz'];
                    
                % NO FMAP
                %output_file = [curr_output_dir '/' subject_name '_task-'   tasks{task_ind} '_run-0' num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold_nofmap.nii.gz'];
                
                try
                    system(['fslmaths ' preproc_file ' -mul ' brainmask_file ' ' output_file]);
                    fprintf(['finished ' subject_name ' '  ' ' tasks{task_ind} ' run 0' num2str(run_ind) '\n']);
                catch
                    system(['fslmaths ' preproc_file ' -mul ' brainmask_file ' ' output_file]);
                    fprintf(['finished ' subject_name ' '  ' ' tasks{task_ind} ' run 0' num2str(run_ind) '\n']);
                     warning(['could not calculate bold brain image for ' subject_name  ' ' tasks{task_ind}]);
                    continue;
                end
            end
        end
end