%% Gabriel Pelletier, March 2018
% To analysis EyeTracking data from Bids phase of
% fribbles_fMRI experiment.

% This function build a heatmap of fixation duration for each subject and
% each condition.


%%
function DurationHeatmap_subject(subjectNumber, Condition, minClip)

% Where is the Data?
dataPath = '/Users/ExpRoom2/Desktop/GabrielP_Fribbles/Fribbles_fMRI/analysisScripts_1mar/Data';

%% Load subject data

% %For coding purposes
% subjectNumber = '26';
% Condition = 'Summation';
% minClip = 0;

%% Load files
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


%% Parameters for HeatMap

% Screen Size that was used during Testing
screenXsize = subInfo.windowSize(3) - subInfo.windowSize(1);
screenYsize = subInfo.windowSize(4) - subInfo.windowSize(2);
% Get Stimulus size and position that were used
stimRect = subInfo.stimPositionBids;

% Define size of Bins for duration calculation
xBin = 20; %pixels
yBin = 20;
% Declare zeros Matrix of (X res/Bin width) rows by (Y res/Bin height) Col
nRows = screenYsize/yBin;
nCols = screenXsize/xBin;

% Set the duration matrix to 0 all around to begin
allDurMatrix = zeros(nRows,nCols);
durationMatrix = zeros(nRows,nCols);

%% What condition will be plotted ?
% Depends on Condition
if strcmp(Condition,'Conjunction')
condTrial = find(strcmp(ratingData(:,6),'conj'))';
stim = ratingData{condTrial(1),4};
elseif strcmp(Condition,'Summation')
condTrial = find(strcmp(ratingData(:,6),'summ'))';
stim = ratingData{condTrial(1),4};
end
plotStimuli = imread([dataPath,'/Stimuli/',stim]);

%%
% Then for each bin (defined by the [i,j] of the Zeros Matrix)
% Define a coordinate square (i-1)*binWith, (j-1)*binHeight, 1*binWith,
% j*binHeight.
% Then loop trought all the fixations.
% If x.y of fix within search bin then add the duration of that fix to the
% value inside the i,j cell of the Time Matrix.

for j = 1 : size(durationMatrix,1)
    for i = 1 : size(durationMatrix,2)
       
        searchBin = [(i-1)*xBin, (j-1)*yBin, i*xBin, j*yBin];
   
        for k = condTrial
            if isempty(eyeData.TrialFix{1,k})
                continue
            else
                for kk = size(eyeData.TrialFix{1,k},2)
                    fixX = eyeData.TrialFix{1,k}(2,kk); % X coordinate of this fixation
                    fixY = eyeData.TrialFix{1,k}(3,kk); % Y coordinate of this fixation
                    % If coordinate are within the Bin then add the duration
                    % of the fixation to the total of this bin.
                    if fixX >= searchBin(1) && fixY >= searchBin(2) && fixX < searchBin(3) && fixY < searchBin(4)
                      durationMatrix(j,i) = durationMatrix(j,i) + eyeData.TrialFix{1,k}(4,kk);
                    end
                end
            end
        end
        
    end
end

allDurMatrix = allDurMatrix + durationMatrix;


%% Plot stuff

figure
% fribble stimulus
image([stimRect(1), stimRect(3)],[stimRect(2), stimRect(4)], plotStimuli);

hold on

% Smooth heatmap
figData = allDurMatrix;
%// Define integer grid of coordinates for the above data
[X,Y] = meshgrid(1:size(figData,2), 1:size(figData,1));
%// Define a finer grid of points
[X2,Y2] = meshgrid(1:(1/xBin):size(figData,2), 1:(1/yBin):size(figData,1));
%// Interpolate the data and show the output
outData = interp2(X, Y, figData, X2, Y2, 'linear');
outData(outData == 0) = NaN;

% The clims minimum affects the treshold at which value sill appeat white 
% in the heatmap (if not defined, only the cells with 0 will appear white).
maxi = max(outData(:));
clims = [minClip,maxi];
him = imagesc(outData,clims);

% Makes it so that all the cells of value 0 (or the minimum set by clim)
% appear white.
mycolormap = [ones(1,3); jet(30)];
colormap(mycolormap);
% Makes it transparent so we can see the image diplayed underneath.
set(him,'AlphaData',0.4);
xlim([0 screenXsize]);
ylim([0 screenYsize]);

end % end function