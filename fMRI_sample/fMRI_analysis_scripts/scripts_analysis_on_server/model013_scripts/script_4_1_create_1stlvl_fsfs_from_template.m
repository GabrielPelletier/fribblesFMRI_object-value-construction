%%

% This script takes the template that we created from the scripted output
% of the Feat GUI first level analysis, and changes the relevant files and 
% folder names for each participant number and each run number.

% It creates the design_..._.fsf files for each run of each task of each
% participants.

%% details
%clear


% Which participants do we run?
participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];



% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);


main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';


%% What is the model indentifier?
modelID = 'model013';

%% Task(s)
% Change this depending on the task you are building the .fsf files for.
tasknames = {'fribBids'};

%% Run(s)
whichRuns = [1 2 3 4];

%%
%! delete previous files
for sub_ind = 1:length(participants)
    SUBNUM=['0' num2str(participants(sub_ind))]
    
    for task_ind = 1: length(tasknames)
        TASKNAME = tasknames{task_ind}
        
        for run_ind = whichRuns
            RUNNUM=['0' num2str(run_ind)]
            
            % This is to get the number of TRs for a specific runs.
            %[status,info] = system(['/share/apps/fsl/bin/fslinfo ' main_path 'sub-' SUBNUM '/sub-' SUBNUM '_task-' TASKNAME '_run-0'  num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold.nii.gz']);
            
            % RUN LEVEL-1 after prep WITH FMAP
            [status,info] = system(['fslinfo ' main_path 'sub-' SUBNUM '/sub-' SUBNUM '_task-' TASKNAME '_run-0'  num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold.nii.gz']);            
            
            % RUN LEVEL-1 after prep WITHOUT FMAP
            %[status,info] = system(['fslinfo ' main_path 'sub-' SUBNUM '/sub-' SUBNUM '_task-' TASKNAME '_run-0'  num2str(run_ind) '_space-MNI152NLin2009cAsym_desc-fmriprep_brain_bold_nofmap.nii.gz']);
            
            TEMP=strsplit(info);
            NPTS=TEMP{1,10};
            
            fsf_out_dir = [main_path,'scripts/',modelID,'_scripts/fsfs/lvl1/'];
            
            fsf_name=['design_sub-',SUBNUM,'_task-',TASKNAME,'_run-',RUNNUM,'.fsf'];
            
            % RUN LEVEL-1 after prep WITH FMAP
            template_in = fopen([main_path,'scripts/' modelID '_scripts/lvl1_task-',TASKNAME,'_template.fsf']);
            
            % RUN LEVEL-1 after prep WITHOUT FMAP
            %template_in = fopen([main_path,'scripts/' modelID '_scripts/lvl1_task-',TASKNAME,'_template_noFMAP.fsf']);
            
            % Create folder if does not exist
             if ~exist(fsf_out_dir,'dir') 
                 mkdir(fsf_out_dir); 
             end    
             
            fsf_out = fopen([fsf_out_dir,fsf_name],'w');
                
            while ~feof(template_in)
                s = fgetl(template_in);
                s = strrep(s, 'SUBNUM', SUBNUM);
                s = strrep(s, 'RUNNUM', RUNNUM);
                s = strrep(s, 'MODELID', modelID);
                s = strrep(s, 'NPTS', NPTS);
                s = strrep(s, 'TASKNAME', tasknames{task_ind});

                fprintf(fsf_out,'%s\n',s);
            end
            template_in=fclose(template_in);
            fsf_out=fclose(fsf_out);
        end %run
    end %task
end%sub