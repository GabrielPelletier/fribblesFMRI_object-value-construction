%% This is the main script to analyse subject-level data from

% ---- fribbles_fmri_behavioral ---- %

% Gabriel Pelletier, march 2018

% Select the phse of the experiment and the types or graph that you want
% the code to Output by indicating =0 or =1 for the items in the list 
% bellow.


%% Where is the Data ?
dataPath = ['../../behav_eye_data/fribBids_training'];


%% Which-subject(s)
%subs = [454];

% Get all subjects from the data folders
sub_folders = fdir(dataPath);

sub_ind = find(contains(sub_folders(:,1), 'sub-'));
all_subs = sub_folders(sub_ind, 1);
for i = 1:length(all_subs)
    subs(i) = str2num(all_subs{i}(6:8));
end

% Exclusions?
exclusions_behavior = [310 401 404 409 416 424 425 426 427 443 451];
exclusions_mri = [401 404 420 442];
extra = [454];
junk_unknown = [423];
exclusions = [exclusions_behavior, exclusions_mri, extra, junk_unknown];
[c,out_ind] = intersect(subs, exclusions);
subs(out_ind) = [];

%% What do you want to plot?

%%% Learning phase
learningPhase = 1; % If this first line is = 0 then nothing underneath will be plot.
numBlocksLearn = 5; % Number of learning blocks (normally 5)
        learningAccuracyRaw = 0;
        learningRtRaw = 0;
        learningRtMean = 0;
        learningAccuracyMeanBlock = 0;
        plot_learning_Acc_RT_byBlock_group = 0;
        
        plot_Probe_ratingsByByValue = 0;
        plot_Probe_meanAcc = 0;
        plot_Probe_meanRt = 0;
        plot_probe_group_data = 1;

%% Codes run down here depending on what was selected(1/0) up there.

%%% Learning phase

if learningPhase
    
    % plot individual subjects in subplots at the same time
    
    learningAnalysis_ratings(dataPath, subs, numBlocksLearn, learningAccuracyRaw, learningRtRaw, learningRtMean);
    
    [learning_accuByBlock_group, learning_RtByBlock_group] = learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocksLearn, learningAccuracyMeanBlock);
    
    probeAnalysis_meanAccuracy(dataPath, subs, plot_Probe_meanAcc, plot_probe_group_data)
    
    learningAnalysis_ratingProbe(dataPath, subs, 1, plot_Probe_ratingsByByValue);
    
    plot_learning_groupData_byBlock(learning_accuByBlock_group, learning_RtByBlock_group, plot_learning_Acc_RT_byBlock_group);
    
end


