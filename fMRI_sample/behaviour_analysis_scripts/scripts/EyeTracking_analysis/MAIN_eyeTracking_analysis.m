% MAIN_eyeTracking_analysis
% fribbles-fMRI
%
% Gabriel Pelletier
% September 2019

%%

clear

% Where are the files?
main_path = 'C:\Users\Labuser\Desktop\GabrielP\fribbles_fmri\fmri_sample\behav_eye_data/';
bids_dataPath = [main_path 'fribBids_bidding/'];
train_dataPath = [main_path 'fribBids_training/'];

%% Which participants?
% Get all subjects from the data folders
sub_folders = fdir(bids_dataPath);

sub_ind = find(contains(sub_folders(:,1), 'sub-'));
all_subs = sub_folders(sub_ind, 1);
for i = 1:length(all_subs)
    subs(i) = str2num(all_subs{i}(6:8));
end

% Exclusions?
exclusions_behavior = [310 401 404 409 416 424 425 426 427 443 451];
exclusions_mri = [401 404 420 442];
exclusions_eyetracking = [309 311 403 414 415 422 425 445 449 450 452 453];
exclusions = [exclusions_behavior, exclusions_mri, exclusions_eyetracking];
[c,out_ind] = intersect(subs, exclusions);
subs(out_ind) = [];

% If you want to run specific subjects
%subs = [402];

% How many runs in the task (should be 4)
which_runs = [1 2 3 4]; 


%% Level-1 analyis; each run of each subject
[lvl1_derivatives] = level1_analysis (subs, which_runs, main_path);

[lvl1_derivatives_byValue] = level1_analysis_byValue (subs, which_runs, main_path);

%   % Create .csv in SPSS format
%create_spss_csv(lvl1_derivatives);

%% Level-2 analyis; average runs within subject
lvl2_derivatives = varfun(@mean, lvl1_derivatives, 'GroupingVariables', 'Subject_Num', 'InputVariables', ...
    {'TransPerTrial_conj', 'TransPerTrial_summ', 'NumFixPerTrial_conj', 'NumFixPerTrial_summ', 'AveFixDur_conj',...
    'AveFixDur_summ', 'Dur_conj_Att1', 'Dur_conj_Att2', 'Dur_conj_NoAtt', 'Dur_conj_Symm', 'Dur_summ_Att1',...
    'Dur_summ_Att2', 'Dur_summ_NoAtt', 'Dur_summ_Symm'});

lvl2_derivatives_byValue = varfun(@mean, lvl1_derivatives_byValue, 'GroupingVariables', 'Subject_Num', 'InputVariables', ...
    {'TransPerTrial_conj_ValueLevels1to6', 'TransPerTrial_summ_ValueLevels1to6', ... 
     'NumFixPerTrial_conj_ValueLevels1to6', 'NumFixPerTrial_summ_ValueLevels1to6', 'AveFixDur_conj_ValueLevels1to6',...
    'AveFixDur_summ_ValueLevels1to6'});

%% Groups analysis; Plots and Stats
%   % Simple group summary
plotEyeTracking_group(lvl2_derivatives);

%   % Group summary BY-VALUE 
%plotEyeTracking_group_byValue(lvl2_derivatives_byValue);

%% Plot Eye Tracking measures by Runs [1 to 4]
%plotEyeTracking_by_run(lvl1_derivatives);

%% Plot distributions for Number of Transitions and fix Durations
%
%plotTransitions_distribution(lvl2_derivatives);
