%% 

% Calculate mean RT across ALL SUBJECT and ALL TRIALS
% (valid participants)
%% 

data_path = '/export2/DATA/FRIB_FMRI/fmri_sample/behavior/fribBids_bidding/';

subs = sample_exclusions;

runs = [1 2 3 4];

group_rt = [];

for s = subs
    
    subID = ['sub-0' num2str(s)];
    sub_rt = [];
    
    for r = runs
        sub_run_data = tdfread([data_path subID '/' num2str(s) '_fmri_RatingTask_Run' num2str(r) '_Compact.txt']);
        sub_rt = [sub_rt; sub_run_data.RatingRT];
    end
    
    %figure
    %scatter(sub_rating_error(:,1), sub_rating_error(:,3));
    
    group_rt = [group_rt; sub_rt];
    
    % Replace time-out by max RT = 3s
    group_rt(group_rt < 0) = 3000;
end

mean_rt = mean(group_rt)/1000
