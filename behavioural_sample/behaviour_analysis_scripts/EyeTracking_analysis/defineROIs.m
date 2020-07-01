%% Gabriel Pelletie, March 2019

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Define the ROIs, (in screen coordinates) for each of the 2 stimulus 
% category based on ...

% ROIs will be used to determine if each fixation was on a given attribute
% which will be used to analyze Total Time spend looking at each attribute
% and the number of between-attributes transitions, by condition.


function [conjROI, summROI] = defineROIs(dataPath, subInfo, verifyROI)

% Conjunction Set and example stimulus
conjSet = subInfo.ConjSet{1,1}(1:3);
conjStim = subInfo.ConjSet{1,1};

% Summation set and example stimulus
summSet = subInfo.SummSet{1,1}(1:3);
summStim = subInfo.SummSet{1,1};

% Define ROIS for each stimulus set.
% ! The coordinates given here Are hard-coded and depend on the size of the
% stimulus and the display used during the experiment !

ROIS = {'Fa2'; 'Fa3'; 'Fc1'; 'Fc3'};

% There are 2 ROIS per stimulus sets (2 Attributes of the object)
ROIS{find(strcmp(ROIS(:,1),'Fa2')), 2} = [750 300 1000 550]; % For Fa2 set, Attribute 1
ROIS{find(strcmp(ROIS(:,1),'Fa2')), 3} = [1000 475 1250 725]; % For Fa2 set, attribute 2

ROIS{find(strcmp(ROIS(:,1),'Fa3')), 2} = [675 300 925 550]; % For Fa3 set
ROIS{find(strcmp(ROIS(:,1),'Fa3')), 3} = [925 275 1175 525]; % For Fa3 set

ROIS{find(strcmp(ROIS(:,1),'Fc1')), 2} = [875 312 1125 562]; % For Fc1 set
ROIS{find(strcmp(ROIS(:,1),'Fc1')), 3} = [825 562 1075 812]; % For Fc1 set

ROIS{find(strcmp(ROIS(:,1),'Fc3')), 2} = [725 312 975 562]; % For Fc3 set
ROIS{find(strcmp(ROIS(:,1),'Fc3')), 3} = [825 562 1075 812]; % For Fc3 set


% Find the correct ROIs for each conditon for this subject
conjROI{1} = ROIS{find(strcmp(ROIS(:,1), conjSet)), 2};
conjROI{2} = ROIS{find(strcmp(ROIS(:,1), conjSet)), 3};

summROI{1} = ROIS{find(strcmp(ROIS(:,1), summSet)), 2};
summROI{2} = ROIS{find(strcmp(ROIS(:,1), summSet)), 3};

   
    
% Plot Stimuli with ROI on top to see if they make sense.
    if verifyROI
        
        % Screen size that was used to present stimuli
        screenXsize = subInfo.windowSize(3) - subInfo.windowSize(1);
        screenYsize = subInfo.windowSize(4) - subInfo.windowSize(2);
        % Get Stimulus size and position that were used
        stimRect = subInfo.stimPositionBids;
        
        figure('Position', [0 0 1500 900]) % Plot stimulus + ROIs CONJ
        TrialIm = imread([dataPath,'/stimuli/',conjStim]);
        im1 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
        im1.AlphaData = 0.7;
        xlim([0 screenXsize])
        ylim([0 screenYsize])
        hold on
        % Draw ROIs
        rectangle('Position',[conjROI{1}(1) conjROI{1}(2) (conjROI{1}(3)-conjROI{1}(1)) (conjROI{1}(4)-conjROI{1}(2))], 'LineWidth',3)
        rectangle('Position',[conjROI{2}(1) conjROI{2}(2) (conjROI{2}(3)-conjROI{2}(1)) (conjROI{2}(4)-conjROI{2}(2))], 'LineWidth',3)
        
        figure('Position', [0 0 1500 900]) % Plot stimulus + ROIs SUMM
        TrialIm = imread([dataPath,'/stimuli/',summStim]);
        im1 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
        im1.AlphaData = 0.7;
        xlim([0 screenXsize])
        ylim([0 screenYsize])
        % Draw ROIs
        rectangle('Position',[summROI{1}(1) summROI{1}(2) (summROI{1}(3)-summROI{1}(1)) (summROI{1}(4)-summROI{1}(2))], 'LineWidth',3)
        rectangle('Position',[summROI{2}(1) summROI{2}(2) (summROI{2}(3)-summROI{2}(1)) (summROI{2}(4)-summROI{2}(2))], 'LineWidth',3)
        
    end

end
