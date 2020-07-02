% This creates a .txt file with commands line to lauch FIRST LEVEL analysis.
% It contains one row per run, per task, per subject
% It is used to lauch batch analysis from the terminal

% Once the lauchn files are created, use Candy submit Host to launch job.
%  launch -s "/PATH/lvl1_launch.txt" -j schonberlab -p NUMOFCORES

%%
clear

%% Details

% Model
modelID = 'model001';

% Which participants do we run?
participants = [0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0449 0450 0452 0453 0454];
      
% participants = [0309 0311 0402 0403 0406 0407 0408 ...
%           0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
%           0421 0422 0428 0429 0430 0431 0432 ...
%           0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
%           0445 0446 0447 0449 0450 0452 0453 0454];

% Which task?
task_names = {'fLoc'};

% Which runs?
runs = [1 2 3 4];

%% Create file

launchFileName = ['/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/fLoc_' modelID '_scripts/launch_files/lvl1_launch.txt'];

% Open file to write
    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file


%% Write to file

for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))];
    
    for task_ind = 1:length(task_names)
        TASKNAME=task_names{task_ind};
        
        for run_ind=runs
            RUNNUM=['0' num2str(runs(run_ind))];

            fprintf(fid,'%s\n',['feat /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/fLoc_' modelID '_scripts/fsfs/lvl1/design_sub-' SUBNUM '_task-' TASKNAME '_run-' RUNNUM '.fsf']);
        end %run
    end%task
end%sub

fid=fclose(fid);
