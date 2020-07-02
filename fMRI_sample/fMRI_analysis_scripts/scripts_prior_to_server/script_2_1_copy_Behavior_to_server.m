%% Function uses the Unix -scp command to copy folders from
% the local machine to the server for data analysis.

%%
% Which participants to send to the server?
participants_to_copy = [448];


tasks = {'fribBids_bidding', 'fribBids_training', 'fLoc'};

commandwindow

localPath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/behav_eye_data/';
serverPath = '/export2/DATA/FRIB_FMRI/fmri_sample/behavior/';

for task_ind = 1:length(tasks)
    task_id = tasks{task_ind};
    destination = [serverPath task_id '/'];
    
    folders_to_copy = [''];
    for subject_ind = 1:length(participants_to_copy)
        sub_id = ['sub-0' num2str(participants_to_copy(subject_ind))];
        
        folders_to_copy = [folders_to_copy localPath task_id '/' sub_id ' '];


    end

        fprintf(['\nscp -r ' folders_to_copy ' gabriel@boost.tau.ac.il:' destination '\n']);
        system(['scp -r ' folders_to_copy ' gabriel@boost.tau.ac.il:' destination])
        
end