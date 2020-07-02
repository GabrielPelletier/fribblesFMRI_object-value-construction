

function [trialOrder1] = learnTrialOrder(stimSet, repeats)


%repeats = 6;
%stimSet = conjFullSet;

numTrials = repeats * size(stimSet,1);
n = length(stimSet);
stimSet = stimSet(randperm(n),:);

if mod(repeats,2) == 0
    numTrials = repeats * size(stimSet,1);
    
    trialOrder = cell(numTrials,2);
    factor1 = numTrials/2; % Because each trial will be doubled.
    factor2 = factor1 / size(stimSet,1);

    stimSetRep =[];
    for i = 1:factor2
        stimSetRep = [stimSetRep;stimSet];
    end

    n = length(stimSetRep);
    stimSetRep = stimSetRep(randperm(n),:);

    trialOrder = {};
    for i = 1 : size( stimSetRep,1)
        trialOrder{end+1,1} =  stimSetRep{i,1};
        trialOrder{end,2} =  stimSetRep{i,2};
        trialOrder{end+1,1} =  stimSetRep{i,1};
        trialOrder{end,2} = stimSetRep{i,2};
    end
    
    % Shuffle some trials so they do not all repeat themselves (to avoid
    % predictability and boredom during the task)
    jitTrials = randi(24,4,1)+10;
    r1 = randperm(length(jitTrials));
    jitTrials(:,2) = jitTrials(r1,1);

    while any(jitTrials(:,1)==jitTrials(:,2))
        r1 = randperm(length(jitTrials));
        jitTrials(:,2) = jitTrials(r1,1);
    end

    % Swap these trials
    trialOrder1 = trialOrder;
    trialOrder1(jitTrials(:,1),:) = trialOrder1(jitTrials(:,2),:);

    
elseif mod(repeats,2) == 1 
    
    rr = repeats - 1;
    numTrialsMod = rr * size(stimSet,1);
    trialOrder = cell(numTrialsMod,2);
    factor1 = numTrialsMod/2; % Because each trial will be doubled.
    factor2 = factor1 / size(stimSet,1);

    stimSetRep =[];
    for i = 1:factor2
        stimSetRep = [stimSetRep;stimSet];
    end

    n = length(stimSetRep);
    stimSetRep = stimSetRep(randperm(n),:);

    trialOrder = {};
    for i = 1 : size( stimSetRep,1)
        trialOrder{end+1,1} =  stimSetRep{i,1};
        trialOrder{end,2} =  stimSetRep{i,2};
        trialOrder{end+1,1} =  stimSetRep{i,1};
        trialOrder{end,2} = stimSetRep{i,2};
    end
    
    % Shuffle some trials so they do not all repeat themselves (to avoid
    % predictability and boredom during the task)
    jitTrials = randi(24,4,1)+10;
    r1 = randperm(length(jitTrials));
    jitTrials(:,2) = jitTrials(r1,1);

    while any(jitTrials(:,1)==jitTrials(:,2))
        r1 = randperm(length(jitTrials));
        jitTrials(:,2) = jitTrials(r1,1);
    end
    
    % Swap these trials
    trialOrder1 = trialOrder;
    trialOrder1(jitTrials(:,1),:) = trialOrder1(jitTrials(:,2),:);
    
    % At the end of the matrix, add one repetition of the stimulus set that
    % was left behind by the line rr = repeats - 1; This one will not be
    % doubled (because the num of repeats is not divisible by 2);
    trialOrder1 = [trialOrder1; stimSet];
    
end
    
end