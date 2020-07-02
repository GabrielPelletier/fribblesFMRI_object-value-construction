% Copy Data from local machine to Dropbox


function send_data_to_dropbox(subjectNumber, dataPath)


%% Find Dropbox Path
dbpath = dropboxPath;
full_dbpath = [dbpath 'experimentsOutput/gabriel/fribbles_data_2019/fribBids_bidding/' subjectNumber];


%%

fileList = dir(dataPath);


% Create folder with subject_number and move all the subject file into it.

if isdir([dataPath subjectNumber]) == 1 % if already exists
    newfolder = [dataPath subjectNumber '_new'];
    mkdir(newfolder);
elseif isdir([dataPath subjectNumber]) == 0    
    newfolder = [dataPath subjectNumber];
    mkdir(newfolder);
end

for f = 1:length(fileList) 
    if ~isempty(strfind(fileList(f).name, subjectNumber))
        movefile([dataPath fileList(f).name], newfolder);
    end
end
    

% Move the subject folder to dropbox
copyfile(newfolder, full_dbpath);


end
