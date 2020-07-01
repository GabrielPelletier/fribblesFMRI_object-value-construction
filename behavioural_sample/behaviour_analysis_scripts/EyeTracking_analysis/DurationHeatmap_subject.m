%% Gabriel Pelletier, March 2018

% Last updtate: March 2019

% To analyze EyeTracking data from Bids phase of
% fribbles_fMRI experiment.

% This function build a heatmap of fixation duration for each subject and
% each condition.

%%

function DurationHeatmap_subject(dataPath, subjectNumber)


%% Load data files
dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];
eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData.mat'];
load(eyeDataFile);
load([dataFolder,'subInfo_',num2str(subjectNumber),'.mat']);

%% Concatenate Behavioral Rating data from all Runs
numRuns = subInfo.numRunsBid;

ratingDataFull = {};
for i = 1:numRuns
    behavFile = [dataFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(i),'.mat'];
    load(behavFile);
    ratingDataFull = [ratingDataFull; ratingData];
end

ratingData = ratingDataFull;
% Get rid of Rating Scale trials
scaleTrials = find(strcmp(ratingData(:,4),'bid'));
ratingData(scaleTrials, :) = [];
trialNum = size(ratingData,1);

% Rename itiFix triggers that follows scale so it is not found as an iti
% following an image stimuli.
for i = 1:length(eyeData.triggers.type)
    if strcmp(eyeData.triggers.type{i},'RatingScaleOnset') && strcmp(eyeData.triggers.type{i+1},'itiFix')
        eyeData.triggers.type{i+1} = 'itiFixScale';
    end
end

windowOfInterest = {'StimulusOnset','itiFix'}; % We will be looking for these triggers.

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


% Screen Size that was used during Testing
screenXsize = subInfo.windowSize(3) - subInfo.windowSize(1);
screenYsize = subInfo.windowSize(4) - subInfo.windowSize(2);
% Get Stimulus size and position that were used
stimRect = subInfo.stimPositionBids;


%% Find trials and the example stimulus to plot for the two conditions

conjTrials = find(strcmp(ratingData(:,6),'conj'))';
conjStim = ratingData{conjTrials(1),4};

summTrials = find(strcmp(ratingData(:,6),'summ'))';
summStim = ratingData{summTrials(1),4};

ConjStimulus = imread([dataPath,'/Stimuli/',conjStim]);
SummStimulus = imread([dataPath,'/Stimuli/',summStim]);



%% heatmap CONJUNCTION

% minClip - Threshold, in ms, for minimum values to plot. E.g. if set to 50,
%         only locations with more than 50ms total fixation time will
%         be colored, anything bellow will be set to 0 (white/transparent).
minClip = 100;
% Define size of Bins for duration calculation
xBin = 20; %pixels
yBin = 20;

trialFlag = conjTrials;

myTitle = 'Fixation Duration Heatmap - Configural (Conjunction)';
do_heatmap(eyeData, xBin, yBin, ConjStimulus, stimRect, trialFlag, minClip, screenXsize, screenYsize, myTitle);



%% heatmap SUMMATION

% Define size of Bins for duration calculation (should be the same as
% defined above)
%xBin = 20; %pixels
%yBin = 20;

trialFlag = summTrials;

myTitle = 'Fixation Duration Heatmap - Elemental (summation)';
do_heatmap(eyeData, xBin, yBin, SummStimulus, stimRect, trialFlag, minClip, screenXsize, screenYsize, myTitle);



end % end function