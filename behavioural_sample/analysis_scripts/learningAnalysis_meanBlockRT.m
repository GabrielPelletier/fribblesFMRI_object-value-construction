%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function [learningRt_group] = learningAnalysis_meanBlockRT(dataPath, subs, numBlocks)

%% 

learnBlocks = numBlocks;
learnRtConj_block_1to5 = zeros(length(subs), learnBlocks);
learnRtSumm_block_1to5 = zeros(length(subs), learnBlocks);

for li = 1:length(subs)
    
    subjectNumber = subs(li);
    
    %% Organize data
    dataDir = [dataPath,'/',num2str(subjectNumber),'/'];

    % Conjunction
    for r = 1 : learnBlocks
        load([dataDir,num2str(subjectNumber),'_Learning_Conjunction_',num2str(r),'.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanRt = mean(cell2mat(learningBlockData(:,6)));
        learnRtConj_block_1to5(li, r) = meanRt;
    end

    % Summation
    for r = 1 : learnBlocks
        load([dataDir,num2str(subjectNumber),'_Learning_SingleAttribute_',num2str(r),'.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanRt = mean(cell2mat(learningBlockData(:,6)));
        learnRtSumm_block_1to5(li, r) = meanRt;
    end
    
end

%% Load data ad stats in group table
 SubjectIDs = subs';
 learningRt_group = table(SubjectIDs, learnRtSumm_block_1to5, learnRtConj_block_1to5);
% save ('ratingAcc_group.mat', 'ratingAcc_group');

end
