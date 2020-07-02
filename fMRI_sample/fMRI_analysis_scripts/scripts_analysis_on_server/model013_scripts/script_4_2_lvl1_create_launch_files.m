% This creates a .txt file with commands line to lauch FIRST LEVEL analysis.
% It contains one row per run, per task, per subject
% It is used to lauch batch analysis from the terminal

%%
%clear

% What is the model indentifier?
modelID = 'model013';

% Which participants do we run?
participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];

launchfFileDir = ['/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/launch_files'];
% Create folder if does not exist
if ~exist(launchfFileDir,'dir') mkdir(launchfFileDir); end  

launchFileName = [launchfFileDir '/lvl1_launch.txt'];

% Open file to write
    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file


% Which task?
task_names = {'fribBids'};

% Which runs?
runs = [1 2 3 4];

%%

%! delete previous files
for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))];
    
    for task_ind = 1:length(task_names)
        TASKNAME=task_names{task_ind};
        
        for run_ind=runs
            RUNNUM=['0' num2str(runs(run_ind))];

            fprintf(fid,'%s\n',['feat /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/fsfs/lvl1/design_sub-' SUBNUM '_task-' TASKNAME '_run-' RUNNUM '.fsf']);
        
        end %run
    end%task
end%sub

fid=fclose(fid);
