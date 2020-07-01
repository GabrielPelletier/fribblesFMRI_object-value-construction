%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function [probe_acc_group] = probeAnalysis_meanAccuracy (dataPath, subs, plotData)

matC = []; % Holds mean accuracy for each subject, Conjnuction
matS = [];%  Holds mean accuracy for each subject, Summ
matC_std = []; % standard dev
matS_std = []; % standard dev

%% 
% Where is the data?
%dataPath = '';

% Which subjects do you want to analyze?
%subs = [21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
%subs = 30;
numSubs = length(subs);
% For ploting purposes
%figure('Name','Accuracy accross learning blocks');
numSubs = length (subs);
learnBlocks = 5;
learnAccConj = zeros(subs(end), learnBlocks);
learnAccSumm = zeros(subs(end), learnBlocks);

for subjectNumber = subs
    
    %% Organize data
    dataDir = [dataPath,'/',num2str(subjectNumber),'/'];

    % Conjunction

        load([dataDir,num2str(subjectNumber),'_LearningProbeRatingConjunction_1.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAccConj = mean(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        stdAccConj = std(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));

    % Summation

        load([dataDir,num2str(subjectNumber),'_LearningProbeRatingSingleAttribute_1.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAccSumm = mean(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        stdAccSumm = std(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        
      matC(end+1,1) =  meanAccConj;
      matC(end,2) =  subjectNumber;
      matC_std(end+1, 1) = stdAccConj;
      
      matS(end+1,1) =  meanAccSumm;
      matS(end,2) =  subjectNumber;  
      matS_std(end+1, 1) = stdAccSumm;

end

if plotData
    %% Plot stuff
    figure
    dumC = ones(size(matC,1),1);
    scatter(dumC,matC(:,1),'b');
    
    hold on
    dumS = ones(size(matC,1),1)*2;
    scatter(dumS,matS(:,1),'r');
    
    ylabel('Mean Rating Error (Real value - Trial rating)')
    xlabel('CONJUNCTION (1)   -    SUMMATION (2)')
    legend('CONJ','SUMM');
    title ('Accuracy during Learning Probe');
    xlim([0 3]);
    %xticks([0 1 2 3]);
        
%     figure
%     for i = 1:length(probeAccGroup)
%     plot([1,2],probeAccGroup(i,:),'-o')
%     hold on
%     plot([1,2],probeAccGroup(i,:),'-o')
%     end
%     hold off
end 

%% Load data ad stats in group table
SubjectID = subs';
summMeanAccuracy = matS(:,1);
conjMeanAccuracy = matC(:,1);
summStdAccuracy = matS_std(:,1);
conjStdAccuracy = matC_std(:,1);

probe_acc_group= table(SubjectID, summMeanAccuracy, conjMeanAccuracy, summStdAccuracy, conjStdAccuracy);
%save ('ratingAcc_group.mat', 'ratingAcc_group');
end