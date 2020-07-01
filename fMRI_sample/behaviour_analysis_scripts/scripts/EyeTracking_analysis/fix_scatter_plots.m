%% Scatter Plots for eyetracking data
% for the bids task of the frbbles_fmri experiment.

function fix_scatter_plots (dataPath, subjectNumber, numRuns)
    % Data path
    dataFolder = [dataPath '/sub-0' (num2str(subjectNumber)) '/'];
    
    % Create Empty figures that will contain the sub-figures
    conjH = figure;
    summH = figure;
    
for rr = 1 : numRuns
    
    % Load EyeTrack data
    load([dataFolder num2str(subjectNumber) '_subRunInfo_' num2str(rr) '.mat']);
    eyeDataFile = [dataFolder num2str(subjectNumber) '_eyeData_run' num2str(rr) '.mat'];
    
    %try
    load(eyeDataFile);
    
    % Load Rating (bidding) data
    behavFile = [dataFolder num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(rr) '.mat'];
    load(behavFile);

    % Get rid of Rating Scale trials
    scaleTrials = find(strcmp(ratingData(:,4),'bid'));
    ratingData(scaleTrials, :) = [];
    trialNum = size(ratingData,1);

    % Screen size that was used to present stimuli
    screenXsize = subRunInfo.windowSize(3) - subRunInfo.windowSize(1);
    screenYsize = subRunInfo.windowSize(4) - subRunInfo.windowSize(2);
    % Get Stimulus size and position that were used
    stimRect = subRunInfo.stimPositionBids;


    % Scatter plot, all Trial per condition

    % Get the Stimulus set that was assigned to this subject for each condition 
    % Find first stimulus of the Conj Condition
    conjInd = find(strcmp(subRunInfo.StimList(:,3), 'conj'));
    summInd = find(strcmp(subRunInfo.StimList(:,3), 'summ'));
    conjSet = subRunInfo.StimList{conjInd(1),1}(1:3);
    summSet = subRunInfo.StimList{summInd(1),1}(1:3);

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
    
    set(0, 'CurrentFigure', conjH); %Conjunction/Configural
    subplot(2,2,rr)
    stim = ratingData{indConjSet(1),4};
    TrialIm = imread([dataPath,'/stimuli/',stim]);
    im1 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
    im1.AlphaData = 0.7;
    hold on
    scatter(xConjSet,yConjSet);
    xlim([0 screenXsize])
    ylim([0 screenYsize])
    title(['sub-0' num2str(subjectNumber) ', Run-0' num2str(rr), ', Configural Condition'])
    
%    if showROISonPlot
%       % Draw ROIs
%        rectangle('Position',[conjROI{1}(1) conjROI{1}(2) (conjROI{1}(3)-conjROI{1}(1)) (conjROI{1}(4)-conjROI{1}(2))])
%        rectangle('Position',[conjROI{2}(1) conjROI{2}(2) (conjROI{2}(3)-conjROI{2}(1)) (conjROI{2}(4)-conjROI{2}(2))])
%    end
    
    set(0, 'CurrentFigure', summH); % Summation/Elemental 
    subplot(2,2,rr)
    stim = ratingData{indSummSet(1),4};
    TrialIm = imread([dataPath,'/stimuli/',stim]);
    im2 = image([stimRect(1) stimRect(3)],[stimRect(2) stimRect(4)], TrialIm);
    im2.AlphaData = 0.7;
    hold on
    scatter(xSummSet,ySummSet);
    xlim([0 screenXsize])
    ylim([0 screenYsize])
    title(['sub-0' num2str(subjectNumber) ', Run-0' num2str(rr), ', Elemental Condition'])
    
%    if showROISonPlot
%        % Draw ROIs
%         rectangle('Position',[summROI{1}(1) summROI{1}(2) (summROI{1}(3)-summROI{1}(1)) (summROI{1}(4)-summROI{1}(2))])
%         rectangle('Position',[summROI{2}(1) summROI{2}(2) (summROI{2}(3)-summROI{2}(1)) (summROI{2}(4)-summROI{2}(2))])
%    end

    %catch % If theres was no eye-tracking file for this run
    %    continue
    %end
    
end % runs loop

end % function
