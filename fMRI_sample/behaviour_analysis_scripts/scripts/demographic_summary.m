%% 
% script to gather demographoc data from fribbles_fMRI data
%

%%

% Get the sub nums from the sample and exclusions script
subs = sample_exclusions;

data_path = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/behav_eye_data/fribBids_training/';

group_gender = {};
group_age = [];
for s = subs

    subID = ['sub-0' num2str(s)];
    load([data_path subID '/subInfo_' num2str(s) '.mat']);

    group_gender(end+1) = {subInfo.Gender};
    group_age(end+1) = str2double(subInfo.Age);

end

mean_age = mean(group_age)
min_age = min(group_age)
max_age = max(group_age)

num_females = sum(strcmp(group_gender, 'Female'))
num_males = sum(strcmp(group_gender, 'Male'))