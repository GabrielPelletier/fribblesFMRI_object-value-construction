%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function [learningAcc_group] = learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocks)

%% 

% dataPath = '';

% Which subjects do you want to analyze?
%subs = [20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
%subs = 30;
numSubs = length(subs);

learnBlocks = numBlocks;
learnAccConj_block_1to5 = zeros(length(subs), learnBlocks);
learnAccSumm_block_1to5 = zeros(length(subs), learnBlocks);

for li = 1:length(subs)
    
    subjectNumber = subs(li);
    
    %% Organize data
    dataDir = [dataPath,'/',num2str(subjectNumber),'/'];

    % Conjunction
    for r = 1 : learnBlocks
        load([dataDir,num2str(subjectNumber),'_Learning_Conjunction_',num2str(r),'.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAcc = mean(abs(cell2mat(learningBlockData(:,5)) - cell2mat(learningBlockData(:,7))));
        learnAccConj_block_1to5(li, r) = meanAcc;
    end

    % Summation
    for r = 1 : learnBlocks
        load([dataDir,num2str(subjectNumber),'_Learning_SingleAttribute_',num2str(r),'.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAcc = mean(abs(cell2mat(learningBlockData(:,5)) - cell2mat(learningBlockData(:,7))));
        learnAccSumm_block_1to5(li, r) = meanAcc;
    end
    
end

%% Load data ad stats in group table
 SubjectIDs = subs';
 learningAcc_group = table(SubjectIDs, learnAccSumm_block_1to5, learnAccConj_block_1to5);
% save ('ratingAcc_group.mat', 'ratingAcc_group');

end
