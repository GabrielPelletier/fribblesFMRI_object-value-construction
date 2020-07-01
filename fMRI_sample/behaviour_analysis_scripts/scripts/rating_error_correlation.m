%%

% Scripts to figure out whether the rating error is correlated with the
% rating itself.

%%

subs = sample_exclusions;
runs = [1 2 3 4];

data_path = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/behav_eye_data/fribBids_bidding/';

group_rating_error = [];
group_corr_stats = [];

for s = subs
    
    subID = ['sub-0' num2str(s)];
    sub_rating_error = [];
    
    for r = runs
        sub_run_data = tdfread([data_path subID '/' num2str(s) '_fmri_RatingTask_Run' num2str(r) '_Compact.txt']);
        run_rating_error = abs(sub_run_data.Rating - sub_run_data.StimulusValue);
        run_rating_error = [sub_run_data.StimulusValue sub_run_data.Rating run_rating_error];  
        sub_rating_error = [sub_rating_error; run_rating_error];
    end
    
    %figure
    %scatter(sub_rating_error(:,1), sub_rating_error(:,3));
    
    group_rating_error = [group_rating_error; sub_rating_error];
    [rho,pval] = corr(sub_rating_error(:,1), sub_rating_error(:,3));
    group_corr_stats = [group_corr_stats; [pval rho]];
end

    %figure
    scatter(group_rating_error(:,1), group_rating_error(:,3));
    [rho,pval] = corr(group_rating_error(:,1), group_rating_error(:,3));
    