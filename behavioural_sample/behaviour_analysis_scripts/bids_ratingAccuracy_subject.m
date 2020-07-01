%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function [bids_acc_rt_group, group_data_byValue] = bids_ratingAccuracy_subject (dataPath, subs, accuracyHistogram, averageAccPlot)

%% 

%dataPath = '';

% Which subjects do you want to analyze?
%subs = [21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
%subs = 23;

% For ploting purposes
if accuracyHistogram
    figure('Name','Value Rating Accuracy');
end
numSubs = length (subs);
figRows = 2;
if length(subs) == 1
    figRows = 1;
end
figCols = ceil(numSubs/figRows);
subPloti = 1; %  Index for subplot within figure

% Will hold every subject data
summMeanAccuracy = [];
conjMeanAccuracy = [];
summStdAccuracy = [];
conjStdAccuracy = [];

summMeanRT = [];
conjMeanRT = [];

for s = 1 : length(subs)
    subjectNumber = subs(s);
    
    %% Organize data
    dataDir = [dataPath,'/',num2str(subjectNumber),'/'];
    runNums = 4;
    
    % Concatenate runs data
    fullSubData = [];
    for r = 1 : runNums
        load([dataDir,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(r),'.mat']);
        fullSubData = [fullSubData;ratingData];
    end

    % Merge stimuli trials with the folowing rating trial
    ratingInd = find(strcmp(fullSubData(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = fullSubData(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = fullSubData(ratingInd(i), 7:9);
    end

    % Split data by Learning condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp( ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp( ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];   
    
    % Re-code 63 (miscoded) to 90 for some early subjects
    recode_ind = find(summData(:,1) == 63);
    summData(recode_ind, 1) = 90;
    
    %% Calculate absolute value difference (rating accuracy)
    conjData(:,4) = abs(conjData(:,1)-conjData(:,2));
    summData(:,4) = abs(summData(:,1)-summData(:,2));
    summMeanAccuracy(end+1,1) = mean(summData(:,4));
    conjMeanAccuracy(end+1,1) = mean(conjData(:,4));
    summStdAccuracy(end+1,1) = std(summData(:,4));
    conjStdAccuracy(end+1,1) = std(conjData(:,4));
    
%% Average Ratings per value level
    values = unique(conjData(:,1),'sorted');
    
    aveRatingsConj = [];
    aveRatingsSumm = [];
    stdRatingsConj = [];
    stdRatingsSumm = [];
    
    for v = 1:length(values)
        aveC = mean(conjData(conjData(:,1) == values(v),2));
        aveS = mean(summData(summData(:,1) == values(v),2));
        aveRatingsConj(v,1) = values(v);
        aveRatingsConj(v,2) = aveC;
        aveRatingsSumm(v,1) = values(v);
        aveRatingsSumm(v,2) = aveS;
        
        stdC = std(conjData(conjData(:,1) == values(v),2));
        stdS = std(summData(summData(:,1) == values(v),2));
        stdRatingsConj(v,1) = values(v);
        stdRatingsConj(v,2) = stdC;
        stdRatingsSumm(v,1) = values(v);
        stdRatingsSumm(v,2) = stdS;
    end
    
    group_data_byValue.conj_Acc(:,s) = aveRatingsConj(:,2);
    group_data_byValue.summ_Acc(:,s) = aveRatingsSumm(:,2);   
    
    %% Get average RT for sub by condition
    summMeanRT(end+1,1) = mean(summData(:,3));
    conjMeanRT(end+1,1) = mean(conjData(:,3));
    

    if accuracyHistogram    
        %% Plot stuff
        subplot(figRows,figCols,subPloti)
        histogram(summData(:,4),'BinWidth',1,'FaceColor','r');
        hold on
        histogram(conjData(:,4),'BinWidth',1,'FaceColor','b');
        xlabel('Rating error (Real value - Trial rating)')
        ylabel('Number of observations')
        axis([0 60 0 30])
        legend('SUMM','CONJ');
        title (num2str(subjectNumber));

        subPloti = subPloti + 1;
    end
    
    
end

%% Load data ad stats in group table
SubjectIDs = subs';
bids_acc_rt_group = table(SubjectIDs, conjMeanAccuracy, summMeanAccuracy, conjStdAccuracy, summStdAccuracy, conjMeanRT, summMeanRT);
%save ('ratingAcc_group.mat', 'ratingAcc_group');


    if averageAccPlot
    figure
        for i = 1:size(bids_acc_rt_group,1)
        plot([1,2],bids_acc_rt_group{i,2:3},'-o') % Conj
        hold on
        end
        hold off
        title ('AVERAGE RATING ACCURACY');
        xlim ([0 3]);
        %xticks ([0 1 2 3]);
        xlabel('CONJUNCTION(1)      SUMMATION (2)') % x-axis label
        ylabel('Accuracy') % y-axis label
    end

end
