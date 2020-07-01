%% Gabriel Pelletie, March 2019

% MAIN sctip for 
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

clear

% Where are the files?
dataPath = ['../../data'];


% All 
all_subs = [23,24,25,26,27,28,29,30,101,102,103,104,105,106,107,108,109,110,...
         111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,201,...
         202,203,204,205,206,207,208,209];

% Exclusion because of behavior
exclusions = [26, 29, 104, 117, 124, 209];

% exlusion because of No EyeTracking Data
exclusions = [exclusions, 102, 107, 108];

% Remove them
[c,out_ind] = intersect(all_subs, exclusions);
subs = all_subs;
subs(out_ind) = [];


groupTrans_conj = [];
groupTrans_summ = [];
groupGazeDur_conj = [];
groupGazeDur_summ = [];
groupNumFix_conj = [];
groupNumFix_summ = []; 
groupDurFix_conj = [];
groupDurFix_summ = [];

% Loop through subjects
for subjectNumber = subs
    
    
%% Step 1: Get Behavior, EyeTracking and SubjectInfo data files
    dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];
    eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData.mat'];
    load(eyeDataFile); % Eye Tracking data file
    load([dataFolder,'subInfo_',num2str(subjectNumber),'.mat']); % Subject information data 
    
    % Behavior File (Bidding-rating)
    numRuns = 4; % How many runs (usually 4)
    ratingDataFull = {};
        for i = 1:numRuns
            behavFile = [dataFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(i),'.mat'];
            load(behavFile);
            ratingDataFull = [ratingDataFull; ratingData];
        end
    ratingData = ratingDataFull;
    % Get rid of Rating Scale trials, just get the Stimuli-Condition-Value
    scaleTrials = find(strcmp(ratingData(:,4),'bid'));
    ratingData(scaleTrials, :) = [];
    trialNum = size(ratingData,1);
    
    % Verify if TrialNumber matches between EyeTracking file and Behavior
    if trialNum ~= size(eyeData.TrialFix,2)
        error('Trial Number does not match between Behavior and EyeTracking Files!')
    end
    
    
%% Step 2: Define ROIs for each condition and attribute
    verifyROI = 0; %Set to 1 if you want to plot the ROIs on top of the images to see if they make sense.
    [conjROI, summROI] = defineROIs(dataPath, subInfo, verifyROI);
    
    
%% Step 3: Identify each fiation to the corresponding ROI
    [eyeData] = classify_fixationROI(eyeData, ratingData, conjROI, summROI);
    % eyeData.TrialFix now has a fifth row, with 1, 2 or 0 depending on if
    % the fixation falls within ROI 1, 2 or None of them.

    
%% Step 4: Get the total number of between-ROI transitions by condition
    [eyeData, trans_conj, trans_summ] = transitionROI(eyeData, ratingData);
    
    
%% Step 5: Get the amount of time spent in each ROI by trial, by condition
%  and calculate the Symmetrical Viewing Time Index
   [gazeDur_conj, gazeDur_summ] = gazeDuration_ROI(eyeData, ratingData);
    
   
%% Step 6: Get the Average Number of Fix/trial and aveage duration of fixations for each condition
   [numFix_conj, numFix_summ, durFix_conj, durFix_summ] = num_dur_Fixations(eyeData, ratingData);   
   
   
%% Average and Load data in matrices that will hold the subject-level means
   groupTrans_conj(end+1, 1) = mean(trans_conj(:,2));
   
   groupTrans_summ(end+1, 1) = mean(trans_summ(:,2));
   
   groupGazeDur_conj(end+1, 1) = mean(gazeDur_conj(:,2)); % ROI-1
   groupGazeDur_conj(end, 2) = mean(gazeDur_conj(:,3)); % ROI-2
   groupGazeDur_conj(end, 3) = mean(gazeDur_conj(:,4)); % No ROI
   groupGazeDur_conj(end, 4) = nanmean(gazeDur_conj(:,5)); % Symmetric viewing index
   
   groupGazeDur_summ(end+1, 1) = mean(gazeDur_summ(:,2)); % ROI-1
   groupGazeDur_summ(end, 2) = mean(gazeDur_summ(:,3)); % ROI-2
   groupGazeDur_summ(end, 3) = mean(gazeDur_summ(:,4)); % No ROI
   groupGazeDur_summ(end, 4) = nanmean(gazeDur_summ(:,5)); % Symmetric viewing index
   
   groupNumFix_conj (end+1,1) = mean(numFix_conj(:,2));
   
   groupNumFix_summ (end+1,1) = mean(numFix_summ(:,2));
   
   groupDurFix_conj (end+1,1) = mean(durFix_conj(:,2));
   
   groupDurFix_summ (end+1,1) = mean(durFix_summ(:,2));
   
   
   %% Plot individual subject Scatter plot of all fixations with ROIS overlay
    % Always put conjROI first, then summROI (as inputs).
   %fix_scatter_plots (dataPath, subjectNumber, numRuns, conjROI, summROI);
   
 end

%% Make a table with the Group Data
subjectID = subs';
groupEyeData = table(subjectID, groupTrans_conj, groupTrans_summ, groupNumFix_conj, groupNumFix_summ, groupDurFix_conj, groupDurFix_summ);
groupEyeData.Dur_conj_Att1 = groupGazeDur_conj(:,1);
groupEyeData.Dur_conj_Att2 = groupGazeDur_conj(:,2);
groupEyeData.Dur_conj_NoAtt = groupGazeDur_conj(:,3);
groupEyeData.Dur_conj_Symm = groupGazeDur_conj(:,4);
groupEyeData.Dur_summ_Att1 = groupGazeDur_summ(:,1);
groupEyeData.Dur_summ_Att2 = groupGazeDur_summ(:,2);
groupEyeData.Dur_summ_NoAtt = groupGazeDur_summ(:,3);
groupEyeData.Dur_summ_Symm = groupGazeDur_summ(:,4);


%% Plot data
plotEyeTracking_group(groupEyeData)

