%% Gabriel Pelletie, January 2018

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Built to take-in EyeTracking data from the Edf2mat converter script, and
% Behavioral data in Matlab matrices (ratingData.mat) that are the output
% of the AA_RatingTask_Slider.m

% Need Subject Output Data file (subject's folder name is subject number)
% subjectNum_eyeData.mat exctracted with Edf2Mat script should be added
% in the same folder.


function EyeTra_trialFixations_fribfMRI_behav(dataPath, subjectNumber, numRuns, trialsToPlot)


%% Load Data
%dataPath = '/Users/ExpRoom2/Desktop/GabrielP_Fribbles/Fribbles_fMRI/analysisScripts_1mar/Data';
dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];


% Load EyeData File
eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData.mat'];
load(eyeDataFile);
load([dataFolder,'subInfo_',num2str(subjectNumber),'.mat']);

% Concatenate Rating data from all Runs

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

% % Rename itiFix triggers that follows scale so it is not found as a iti
% % following an image stimuli.
% for i = 1:length(eyeData.triggers.type)
%     if strcmp(eyeData.triggers.type{i},'RatingScaleOnset') && strcmp(eyeData.triggers.type{i+1},'itiFix')
%         eyeData.triggers.type{i+1} = 'itiFixScale';
%     end
% end
% windowOfInterest = {'StimulusOnset','itiFix'}; % We will be lookng for these triggers.
% 
% %% Get Stimulus Presentation time windows (1 per trial)
% stimOnsetInd = find(strcmp(eyeData.triggers.type,windowOfInterest{1}));
% stimOffsetInd = find(strcmp(eyeData.triggers.type,windowOfInterest{2}));
% stimTimeWindow = [eyeData.triggers.time(stimOnsetInd);eyeData.triggers.time(stimOffsetInd)];
% % Duration of Stimulus presentation in ms (already known)
% stimTimeWindow(3,:) = stimTimeWindow(2,:)-stimTimeWindow(1,:);
% eyeData.TimeOfInterest = stimTimeWindow;
% 
% %% Redirect each fixation (within Time windows of interest) to its trial
% 
% % > <; Right now it only takes into account fixations that are entirely
% % within the timeWindows (reject fix if it ends after StimOffset, which it
% % should not do)
% 
% eyeData.TrialFix = cell(1,size(eyeData.TimeOfInterest,2));
% 
% for f = 1:size(eyeData.FixInfo.start,2)% loop through all fixations
%     for t = 1:size(eyeData.TimeOfInterest,2) % loop trials
%         if eyeData.FixInfo.start(1,f) >= eyeData.TimeOfInterest(1,t) && eyeData.FixInfo.end(1,f) <= eyeData.TimeOfInterest(2,t)
%             eyeData.TrialFix{t}(end+1) = f; % The fixation 'f' belongs to the trial 't'.
%         end
%     end
% end
% 
% %% Use Fixations identification to retrieve fix position/duration
% for t = 1:size(eyeData.TrialFix,2)
%     
%     for f = 1:size(eyeData.TrialFix{1,t},2)
%         fixID = eyeData.TrialFix{1,t}(1,f); % Fixation ID (eg. 145th fix from start of dataFile)
%         eyeData.TrialFix{1,t}(2,f) = eyeData.FixInfo.posX(fixID);
%         eyeData.TrialFix{1,t}(3,f) = eyeData.FixInfo.posY(fixID);
%         eyeData.TrialFix{1,t}(4,f) = eyeData.FixInfo.duration(fixID);
%     end
%     
% end



%% Plots
% Screen size that was used to present stimuli
screenXsize = subInfo.windowSize(3) - subInfo.windowSize(1);
screenYsize = subInfo.windowSize(4) - subInfo.windowSize(2);
% Get Stimulus size and position that were used
stimRect = subInfo.stimPositionBids;

% Prepare figure to receive multiple plots
htrials = figure('Name',['Subejct#_',num2str(subjectNumber),'_Individual Trials Scan Paths']);
subPloti = 1; %  Index for subplot within figure
numPlots = length (trialsToPlot);
figRows = 2;
if length(trialsToPlot) == 1
    figRows = 1;
end
figCols = ceil(numPlots/figRows);

% Trial-Wise fixation scan paths
for i = trialsToPlot
    
    set(0,'CurrentFigure',htrials);
    subplot(figRows,figCols,subPloti)
    
    if isempty(eyeData.TrialFix{1,i})
       continue
    else
        
        % Get trial Stimulus
        stim = ratingData{i,4};
        TrialIm = imread([dataPath, '/Stimuli/',stim]);
        im = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
        im.AlphaData = 0.7;

        hold on

        x=eyeData.TrialFix{1,i}(2,:); % X coord
        y=eyeData.TrialFix{1,i}(3,:); % Y coord
        z=eyeData.TrialFix{1,i}(4,:); % Duration (size of dot)

        plot(x, y, '-k','LineWidth',2);
        %scatter(x,y,z,'b','filled','MarkerFaceAlpha',.4); % MarkerFaceAlpha does not work on matlab2014
        scatter(x,y,z,'b','filled');
        xlim([0 screenXsize])
        ylim([0 screenYsize])
        title(['Trial:', num2str(i)]);
        
        subPloti = subPloti + 1;
        
    end
end


end