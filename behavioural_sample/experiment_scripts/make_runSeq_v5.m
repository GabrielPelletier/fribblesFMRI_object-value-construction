%% Script to make orders, timings and ITIs
%  for Runs of Bid task (fMRI runs).
%looseRunSequences= {};


load('order_learning_stimuli.mat')

for s = 309:length(order_learning_stimuli) % Each row is for ONE SUBJECT

    %% Load the Matrix containing predefined Stimulus Set assignments
    % for upcoming subject (will also contain runs sequences).

    stimFamily = order_learning_stimuli(s,2);
    stimOrder = order_learning_stimuli(s,3);

    %% Stimuli folders used for each condition for this sujbect
    if stimFamily == 1

        if stimOrder == 1
            conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/WholeObject/'];
            sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/SingleAttribute/'];
        elseif stimOrder == 2
            conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/WholeObject/'];
            sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/SingleAttribute/'];
        end

    elseif stimFamily == 2

        if stimOrder == 1
            conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/WholeObject/'];
            sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/SingleAttribute/'];
        elseif stimOrder == 2
            conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/WholeObject/'];
            sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/SingleAttribute/'];
        end

    end

    % Get stimulus/value associations matrices (2 versions / stim set)
    if order_learning_stimuli(s,4) == 1
        load([conjSetFolder,'stimuliValueWhole_v1.mat']);
        load([sumSetFolder,'stimuliValueSum_v1.mat']);
    elseif order_learning_stimuli(s,4) == 2
        load([conjSetFolder,'stimuliValueWhole_v2.mat']);
        load([sumSetFolder,'stimuliValueSum_v2.mat']);
    end

    summStimValues = stimuliValueSum;
    summStimValues(:,3) = {'summ'};
    conjStimValues = stimuliValueWhole;
    conjStimValues(:,3) = {'conj'}; % Add learning condition info


    % Combine all Stimuli-Values together (12 stimuli)
    allStimValues = [conjStimValues;summStimValues];


    %% Task Parameters
    % Nubmer of unique stimuli
    stimNum = size(allStimValues,1);

    numRuns = 4;
    numStim = length(allStimValues); % 12
    rep = 2; % each Stimulus repeated X times per run

    runStimNum = rep * numStim;
    runBidNum = runStimNum; % Each stimulus will be bid on
    runTrialNum = runBidNum + runStimNum;
    totStimNum = runStimNum * numRuns;
    totBidNum = runBidNum * numRuns; % per run
    totTrialNum = totStimNum + totBidNum;

    % Trial timings
    stimDur = 3; % seconds
    ITImin = 4;
    ITImax = 8;
    trialAveDur = stimDur + (ITImin + ITImax)/2;

    totDur = totTrialNum * trialAveDur;
    fprintf('Task duration= %d min', totDur/60);

    for r = 1: numRuns
        %% Make Stimulus Presentation Order List
        stimList = [];
        for i = 1:rep
            stimList = [stimList; allStimValues];
        end

        % Shuffle order Randomly but with certain conditions
        iter = 1;
        conditions = 0;
        while conditions == 0
            disp(iter);
            NN = randperm(length(stimList));
            stimList = stimList(NN,:);

            % Condition0 : do not start with a bid.
            if strcmp(stimList{1},'bid')
              continue
            end

            % Condition1 : no stimulus repeated twice in a row.
            for i = 1:length(stimList)-1
                if strcmp(stimList{i},stimList{i+1}) == 1
                    cond1 = 0;
                    break
                else
                    cond1 = 1;
                end
            end

            %Compile conditions
            if cond1 ==  1 %&& cond2 ==1  % All conditions are met
                conditions = 1;
            end

            iter = iter + 1;    
        end


        %% Add bid trial after each stimulus trial
        stimList1 = cell(runBidNum + runStimNum , 3);
        bidList = cell(runBidNum,3);
        bidList(:,1) = {'bid'}; bidList(:,2) = {0}; bidList(:,3) = {'bid'}; 
        j=1;
        for i = 1:2:length(stimList1)
            stimList1(i,:) = stimList(j,:);
            j = j+1;
        end
        for i = 2:2:length(stimList1)
            stimList1(i,:) = bidList(1,:);
        end
        stimList = stimList1;
        seq.runs(r).stimList = stimList;

    %     %% Make ITIs List
    %     ITI = (rand(size(stimList,1),1) * (ITImax-ITImin)) + ITImin;
    %     seq.runs(r).ITI = ITI;

    %     %% Make Stimulus Onset Time List
    %     stimOn(1,1) = 0;
    %     for i = 2:length(stimList)
    %         stimOn(i,1) = stimOn(i-1,1) + ITI(i,1) + stimDur;
    %     end
    %     seq.runs(r).stimOnsetTime = stimOn;

    %     %% Make ITI onset times
    %     seq.runs(r).itiOnsetTime = seq.runs(r).stimOnsetTime + stimDur;

    end
    runSequences_v5{s,1} = seq;
    %save('subSeq_v3.mat','subSeq_v3');
    %looseRunSequences = seq;

end
