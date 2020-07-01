%% Gabriel Pelletie, January 2018

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Built to take-in EyeTracking data from the Edf2mat converter script, and
% Behavioral data in Matlab matrices (ratingData.mat) that are the output
% of the AA_RatingTask_Slider.m
%
% Need Subject Output Data file (subject's folder name is subject number)
% subjectNum_eyeData.mat exctracted with Edf2Mat script should be added
% in the same folder.


subjectNumber = 115;
numRuns = 1;


%% Load Data
dataPath = '/Users/ExpRoom1/Desktop/GabrielP/analysisScripts_4mar/Data';
dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];



for rr = 1 : numRuns

    
    
%% Extract EyeTracking data from edf file
convertNextract(subjectNumber, dataFolder, [dataFolder,num2str(subjectNumber),'_run',num2str(rr),'.edf'], rr);
% Load it
eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData_run',num2str(rr),'.mat'];
load(eyeDataFile);
load([dataFolder,num2str(subjectNumber),'_subRunInfo_',num2str(rr),'.mat']);

% Concatenate Rating data from all Runs
%numRuns = subInfo.numRuns;

ratingDataFull = {};
for i = 1:numRuns
    behavFile = [dataFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(i),'.mat'];
    load(behavFile);
    ratingDataFull = [ratingDataFull; ratingData];
end
ratingData = ratingDataFull;
% Get rid of Rating Scale trias
scaleTrials = find(strcmp(ratingData(:,4),'bid'));
ratingData(scaleTrials, :) = [];
trialNum = size(ratingData,1);

% Rename itiFix triggers that follows scale so it is not found as a iti
% following an image stimuli.
for i = 1:length(eyeData.triggers.type)
    if strcmp(eyeData.triggers.type{i},'RatingScaleOnset') && strcmp(eyeData.triggers.type{i+1},'itiFix')
        eyeData.triggers.type{i+1} = 'itiFixScale';
    end
end
windowOfInterest = {'StimulusOnset','itiFix'}; % We will be lookng for these triggers.



%% Get Stimulus Presentation time windows (1 per trial)
stimOnsetInd = find(strcmp(eyeData.triggers.type,windowOfInterest{1}));
stimOffsetInd = find(strcmp(eyeData.triggers.type,windowOfInterest{2}));
stimTimeWindow = [eyeData.triggers.time(stimOnsetInd);eyeData.triggers.time(stimOffsetInd)];
% Duration of Stimulus presentation in ms (already known)
stimTimeWindow(3,:) = stimTimeWindow(2,:)-stimTimeWindow(1,:);
eyeData.TimeOfInterest = stimTimeWindow;


%% Redirect each fixation (within Time windows of interest) to its trial

% > <; Right now it only takes into account fixations that are entirely
% within the timeWindows (reject fix if it ends after StimOffset, which it
% should not do)

eyeData.TrialFix = cell(1,size(eyeData.TimeOfInterest,2));

for f = 1:size(eyeData.FixInfo.start,2)% loop through all fixations
    for t = 1:size(eyeData.TimeOfInterest,2) % loop trials
        if eyeData.FixInfo.start(1,f) >= eyeData.TimeOfInterest(1,t) && eyeData.FixInfo.end(1,f) <= eyeData.TimeOfInterest(2,t)
            eyeData.TrialFix{t}(end+1) = f; % The fixation 'f' belongs to the trial 't'.
        end
    end
end



%% Use Fixations identification to retrieve fix position/duration
for t = 1:size(eyeData.TrialFix,2)
    
    for f = 1:size(eyeData.TrialFix{1,t},2)
        fixID = eyeData.TrialFix{1,t}(1,f); % Fixation ID (eg. 145th fix from start of dataFile)
        eyeData.TrialFix{1,t}(2,f) = eyeData.FixInfo.posX(fixID);
        eyeData.TrialFix{1,t}(3,f) = eyeData.FixInfo.posY(fixID);
        eyeData.TrialFix{1,t}(4,f) = eyeData.FixInfo.duration(fixID);
    end
    
end

save(eyeDataFile,'eyeData');

end

% %% Plots
% 
% % Screen size that was used to present stimuli
% screenXsize = subRunInfo.windowSize(3) - subRunInfo.windowSize(1);
% screenYsize = subRunInfo.windowSize(4) - subRunInfo.windowSize(2);
% % Get Stimulus size and position that were used
% stimRect = subRunInfo.stimPositionBids;
% 
% 
% % Scatter plot, all Trial per condition
%     % Find Indexes for each Stimulus Set
%     indSet1 = find(contains(ratingData(:,4),'Fa2'));
%     indSet2 = find(contains(ratingData(:,4),'Fa3'));
%     
%     xSet1 = []; % Will concatenate all fixs' Xcoord in a single Matrix
%     xSet2 = []; % Will concatenate all fixs' Xcoord in a single Matrix
%     ySet1 = [];
%     ySet2 = [];
%     
%     for t = 1:size(eyeData.TrialFix,2)
%         
%         if isempty(eyeData.TrialFix{1,t})
%             continue
%         elseif any(t == indSet1)
%            xSet1 = [xSet1, eyeData.TrialFix{1,t}(2,:)];
%            ySet1 = [ySet1, eyeData.TrialFix{1,t}(3,:)];
%         elseif any(t == indSet2)
%            xSet2 = [xSet2 , eyeData.TrialFix{1,t}(2,:)];
%            ySet2 = [ySet2, eyeData.TrialFix{1,t}(3,:)];            
%         end
%     end
%     
%     figure % Plot set 1 Trials
%     stim = ratingData{indSet1(1),4};
%     TrialIm = imread([dataPath,'/Stimuli/',stim]);
%     im1 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
%     im1.AlphaData = 0.7;
%     hold on
%     scatter(xSet1,ySet1);
%     xlim([0 screenXsize])
%     ylim([0 screenYsize])
%     
%     figure % Plot Set2 Trials
%     stim = ratingData{indSet2(1),4};
%     TrialIm = imread([dataPath,'/Stimuli/',stim]);
%     im2 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
%     im2.AlphaData = 0.7;
%     hold on
%     scatter(xSet2,ySet2);
%     xlim([0 screenXsize])
%     ylim([0 screenYsize])
% 
