%% Gabriel Pelletie, January 2018

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Built to take-in EyeTracking data from the Edf2mat converter script, and
% Behavioral data in Matlab matrices (ratingData.mat) that are the output
% of fribbles bids (rating) task.
%
% Need Subject Output Data file (subject's folder name is subject number)
% subjectNum_eyeData.mat exctracted with Edf2Mat script should be added
% in the same folder.

function EyeTra_extraction_fribfMRI_behav(dataPath, subjectNumber, numRuns)

%numRuns = 4;

%% Load Data
%dataPath = '/Users/ExpRoom1/Desktop/GabrielP/analysisScripts_4mar/Data';
dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];

%% Extract EyeTracking data from edf file

convertNextract(subjectNumber, dataFolder, [dataFolder,num2str(subjectNumber),'_rate.edf']);

% Load it
eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData.mat'];
load(eyeDataFile);
load([dataFolder,'subInfo_',num2str(subjectNumber),'.mat']);


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


save([dataFolder,num2str(subjectNumber),'_eyeData.mat'],'eyeData');

end