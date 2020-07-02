% Copy Data from local machine to Dropbox


function send_data_to_dropbox(subjectNumber, dataPath)


%% Find Dropbox Path
dbpath = dropboxPath;
full_dbpath = [dbpath 'experimentsOutput/gabriel/fribbles_data_2019/'];


%%

fileList = dir(dataPath);

for f = 1:length(fileList) 
    if ~isempty(strfind(fileList(f).name, subjectNumber));
        sub_file_ind = f;
    end
end
    
if ~exist('sub_file_ind')
    fprintf('\nThere is no existing folder for sub-0%s\n', subjectNumber);
else
    from_folder = [dataPath fileList(sub_file_ind).name];
    status = copyfile(from_folder, [full_dbpath 'fribBids_training/' subjectNumber]);
end
   
    
    
end
