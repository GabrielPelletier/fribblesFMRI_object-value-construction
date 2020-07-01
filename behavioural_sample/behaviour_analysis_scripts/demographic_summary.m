%% 
% script to gather demographoc data from fribbles_fMRI data
%

%%

data_path = 'C:\Users\Labuser\Desktop\GabrielP\fribbles_fmri\behavioral_sample/outputs/';

%% Which-subject(s)

% All
all_subs = [23,24,25,26,27,28,29,30,101,102,103,104,105,106,107,108,109,110,...
         111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,201,...
         202, 203, 204, 205, 206, 207, 208, 209];
     
% Excluding those with poor accuracy
exclusions = [26, 29, 104, 117, 124, 209, 110, 204, 106];

% exlusion because of No EyeTracking Data
%exclusions = [exclusions, 102, 107, 108];

% Remove them
[c,out_ind] = intersect(all_subs, exclusions);
subs = all_subs;
subs(out_ind) = [];


group_gender = {};
group_age = [];
for s = 1:length(subs)
    subID = num2str(subs(s));
    
    load([data_path subID '/subInfo_' subID '.mat']);

    group_gender(end+1) = {subInfo.Gender};
    group_age(end+1) = str2double(subInfo.Age);

end

mean_age = mean(group_age)
min_age = min(group_age)
max_age = max(group_age)

num_females = sum(strcmp(group_gender, 'Female'))
num_males = sum(strcmp(group_gender, 'Male'))