% Retrieve Data From Dropbox

clear

%% Which participants
participants = [448];

%%Paths
dbpath = dropboxPath;
full_dbpath = [dbpath 'experimentsOutput/gabriel/fribbles_data_2019/'];
destpath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/behav_eye_data/';


%%
for sub_ind = 1:length(participants)
    subName = num2str(participants(sub_ind))    
    
    % fLoc
    fileList = dir([full_dbpath 'fLoc/']);   
    for f = 1:length(fileList) 
        if contains(fileList(f).name, subName)
            sub_file_ind = f;
        end
    end
    if ~exist('sub_file_ind')
        fprintf('\nThere is no existing folder for task-fLoc for sub-0%s\n', subName);
    else
        in_folder = [full_dbpath 'fLoc/' fileList(sub_file_ind).name];
        fprintf('\nMoving fLoc data...\n');
        status = movefile(in_folder, [destpath 'fLoc/'])
        status = movefile([destpath 'fLoc/' fileList(sub_file_ind).name], [destpath 'fLoc/sub-0' subName]) % Rename it to fit BIDS
        clear sub_file_ind;
    end     
    
    
    
    % fribBids TRAINING
    fileList = dir([full_dbpath 'fribBids_training/']);   
    for f = 1:length(fileList) 
        if contains(fileList(f).name, subName)
            sub_file_ind = f;
        end
    end
    if ~exist('sub_file_ind')
        fprintf('\nThere is no existing folder for task-fribBids_training for sub-0%s\n', subName);
    else
        in_folder = [full_dbpath 'fribBids_training/' fileList(sub_file_ind).name];
        fprintf('\nMoving fribBids_training data...\n');
        status = movefile(in_folder, [destpath 'fribBids_training/'])
        status = movefile([destpath 'fribBids_training/' fileList(sub_file_ind).name], [destpath 'fribBids_training/sub-0' subName]) % Rename it to fit BIDS
        clear sub_file_ind;
    end

    
    
    % fribBids BIDDING
    fileList = dir([full_dbpath 'fribBids_bidding/']);   
    for f = 1:length(fileList) 
        if contains(fileList(f).name, subName)
            sub_file_ind = f;
        end
    end
    if ~exist('sub_file_ind')
        fprintf('\nThere is no existing folder for task-fribBids_bidding for sub-0%s\n', subName);
    else
        in_folder = [full_dbpath 'fribBids_bidding/' fileList(sub_file_ind).name];
        fprintf('\nMoving fribBids_bidding data...\n');
        status = movefile(in_folder, [destpath 'fribBids_bidding/'])
        status = movefile([destpath 'fribBids_bidding/' fileList(sub_file_ind).name], [destpath 'fribBids_bidding/sub-0' subName]) % Rename it to fit BIDS
        clear sub_file_ind;
    end

end
