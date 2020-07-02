% This creates a .txt file with commands line to lauch FIRST LEVEL analysis.
% It contains one row per run, per task, per subject
% It is used to lauch batch analysis from the terminal

%% Details
clear

% What is the model indentifier?
modelID = 'model005';
        
% Which participants do we run?
participants = [454];

% Which task?
task_names = {'fribBids'};


launchfFileDir = ['/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/launch_files/'];
% Create folder if does not exist
if ~exist(launchfFileDir,'dir') mkdir(launchfFileDir); end  

launchFileName = [launchfFileDir 'lvl2_launch.txt'];

% Open file to write
    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file

%%
%! delete previous files
for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))];
    
    for task_ind = 1:length(task_names)
        TASKNAME=task_names{task_ind};

            fprintf(fid,'%s\n',['feat /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/fsfs/lvl2/design_sub-' SUBNUM '_task-' TASKNAME '.fsf']);
    end%task
end%sub

fid=fclose(fid);
