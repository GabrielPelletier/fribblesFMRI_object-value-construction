%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function [learning_accuByBlock_group, learning_RtByBlock_group] = learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocks, plotData)

%% For ploting purposes

numSubs = length(subs);

if plotData
    figure('Name','Accuracy accross learning blocks');
end

figRows = 2;
if numSubs == 1
    figRows = 1;
end

figCols = ceil(numSubs/figRows);
subPloti = 1; %  Index for subplot within figure

learnBlocks = numBlocks;
learnAccConj_block_1to5 = zeros(length(subs), learnBlocks);
learnAccSumm_block_1to5 = zeros(length(subs), learnBlocks);
learnRtConj_block_1to5 = zeros(length(subs), learnBlocks);
learnRtSumm_block_1to5 = zeros(length(subs), learnBlocks);

%% 
for s = 1:length(subs)
    subjectNumber = subs(s);
    
    %% Organize data
    dataDir = [dataPath '/' 'sub-0' num2str(subjectNumber) '/'];

    
    % Conjunction
    for r = 1 : learnBlocks
        load([dataDir num2str(subjectNumber) '_Learning_Conjunction_' num2str(r) '.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAcc = mean(abs(cell2mat(learningBlockData(:,5)) - cell2mat(learningBlockData(:,7))));
        meanRT = mean(cell2mat(learningBlockData(:,6)));
        learnAccConj_block_1to5(s, r) = meanAcc;
        learnRtConj_block_1to5(s, r) = meanRT;
    end

    % Summation
    for r = 1 : learnBlocks
        load([dataDir num2str(subjectNumber) '_Learning_SingleAttribute_' num2str(r) '.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAcc = mean(abs(cell2mat(learningBlockData(:,5)) - cell2mat(learningBlockData(:,7))));
        meanRT = mean(cell2mat(learningBlockData(:,6)));
        learnAccSumm_block_1to5(s, r) = meanAcc;
        learnRtSumm_block_1to5(s, r) = meanRT;
        
    end

    if plotData
        %% Plot stuff
        subplot(figRows,figCols,subPloti);
        plot(learnAccSumm_block_1to5(s,:),'r');
        hold on
        plot(learnAccConj_block_1to5(s,:),'b');
        ylabel('Mean Rating Error (Real value - Trial rating)')
        xlabel('Learning Block')
        legend('SUMM','CONJ');
        title (['sub-0' num2str(subjectNumber)]);
        %xticks([1 2 3 4])
        subPloti = subPloti + 1;
    end
    
end

%% Load data ad stats in group table
SubjectID = subs';
learning_accuByBlock_group = table(SubjectID, learnAccConj_block_1to5, learnAccSumm_block_1to5);
%save ('learning_accuByBlock_group.mat', 'learning_accuByBlock_group');
learning_RtByBlock_group = table(SubjectID, learnRtConj_block_1to5, learnRtSumm_block_1to5);
%save ('learning_RtByBlock_group.mat', 'learning_RtByBlock_group');

end
