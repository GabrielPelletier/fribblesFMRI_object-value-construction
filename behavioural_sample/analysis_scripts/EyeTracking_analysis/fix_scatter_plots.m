%% Scatter Plots for eyetracking data
% for the bids task of the frbbles_fmri experiment.

function fix_scatter_plots (dataPath, subjectNumber, numRuns, varargin)

if isempty(varargin)
   showROISonPlot = 0; % If ROIS not provided, do not attempt to plot them 
else 
    showROISonPlot = 1;
    conjROI = varargin{1};
    summROI = varargin{2};
end



%% Load data
% Concatenate Rating data from all Runs

dataFolder = [dataPath,'/',(num2str(subjectNumber)),'/'];

%load files
load([dataFolder,'subInfo_',num2str(subjectNumber),'.mat']);
eyeDataFile = [dataFolder,num2str(subjectNumber),'_eyeData.mat'];
load(eyeDataFile);

% COncatenate bahavioral ratings data from all runs
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



% Screen size that was used to present stimuli
screenXsize = subInfo.windowSize(3) - subInfo.windowSize(1);
screenYsize = subInfo.windowSize(4) - subInfo.windowSize(2);
% Get Stimulus size and position that were used
stimRect = subInfo.stimPositionBids;


% Scatter plot, all Trial per condition

% Get the Stimulus set that was assigned to this subject for each condition 
conjSet = subInfo.ConjSet{1,1}(1:3);
summSet = subInfo.SummSet{1,1}(1:3); 

    % Find Indexes for each Stimulus Set
    indConjSet = find(~cellfun(@isempty, (strfind(ratingData(:,4),conjSet))));
    
    indSummSet = find(~cellfun(@isempty, (strfind(ratingData(:,4),summSet))));
    
    xConjSet = []; % Will concatenate all fixs' Xcoord in a single Matrix
    xSummSet = []; % Will concatenate all fixs' Xcoord in a single Matrix
    yConjSet = [];
    ySummSet = [];
    
    for t = 1:size(eyeData.TrialFix,2)
        
        if isempty(eyeData.TrialFix{1,t})
            continue
        elseif any(t == indConjSet)
           xConjSet = [xConjSet, eyeData.TrialFix{1,t}(2,:)];
           yConjSet = [yConjSet, eyeData.TrialFix{1,t}(3,:)];
        elseif any(t == indSummSet)
           xSummSet = [xSummSet , eyeData.TrialFix{1,t}(2,:)];
           ySummSet = [ySummSet, eyeData.TrialFix{1,t}(3,:)];            
        end
    end
    
    figure % Plot ConjSet Trials (Conjunction/Configural condition)
    stim = ratingData{indConjSet(1),4};
    TrialIm = imread([dataPath,'/Stimuli/',stim]);
    im1 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
    im1.AlphaData = 0.7;
    hold on
    scatter(xConjSet,yConjSet);
    xlim([0 screenXsize])
    ylim([0 screenYsize])
    title(['sub-',num2str(subjectNumber),'- CONFIGURAL'])
    
    if showROISonPlot
       % Draw ROIs
        rectangle('Position',[conjROI{1}(1) conjROI{1}(2) (conjROI{1}(3)-conjROI{1}(1)) (conjROI{1}(4)-conjROI{1}(2))])
        rectangle('Position',[conjROI{2}(1) conjROI{2}(2) (conjROI{2}(3)-conjROI{2}(1)) (conjROI{2}(4)-conjROI{2}(2))])
    end
    
    figure % Plot SummSet Trials (Sumamtion/Elemental condition)
    stim = ratingData{indSummSet(1),4};
    TrialIm = imread([dataPath,'/Stimuli/',stim]);
    im2 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
    im2.AlphaData = 0.7;
    hold on
    scatter(xSummSet,ySummSet);
    xlim([0 screenXsize])
    ylim([0 screenYsize])
    title(['sub-',num2str(subjectNumber),'- ELEMENTAL'])
    
   if showROISonPlot
       % Draw ROIs
        rectangle('Position',[summROI{1}(1) summROI{1}(2) (summROI{1}(3)-summROI{1}(1)) (summROI{1}(4)-summROI{1}(2))])
        rectangle('Position',[summROI{2}(1) summROI{2}(2) (summROI{2}(3)-summROI{2}(1)) (summROI{2}(4)-summROI{2}(2))])
   end
end
