%% Function uses the Unix -scp command to copy folders from
% the local machine to the server for data analysis.

%%
% Which participants to send to the server?
participants_to_copy = [447];

commandwindow

for subject_ind = 1:length(participants_to_copy)
    sub_id = ['0' num2str(participants_to_copy(subject_ind))];
    
    % Copy the participant's BIDS folder to the server for further analysis.
    % You will be asked for your Password in matlab's Command Window
    folder_to_copy = ['/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/BIDS/sub-' sub_id, '/'];
    destination = '/export2/DATA/FRIB_FMRI/fmri_sample/BIDS/'; % Server location

    fprintf(['\nscp -r ' folder_to_copy ' gabriel@boost.tau.ac.il:' destination '\n']);
    system(['scp -r ' folder_to_copy ' gabriel@boost.tau.ac.il:' destination])

end