%% details

clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

% What is the model indentifier?
modelID = 'model005';

% Which contrasts?
copes = [1 3 4 5 7 8 9 10];

%%
launchfFileDir = ['/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/launch_files'];
% Create folder if does not exist
if ~exist(launchfFileDir,'dir') mkdir(launchfFileDir); end  

launchFileName = [launchfFileDir '/lvl3_launch.txt'];

% Open file to write
    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file
    
%! delete previous files
for cope_ind = 1:length(copes)
    COPENUM = num2str(copes(cope_ind));
    
            fprintf(fid,'%s\n',['feat /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/' modelID '_scripts/fsfs/lvl3/group_design_task-fribBids_cope' COPENUM '.fsf']);

end%copes

fid=fclose(fid);    