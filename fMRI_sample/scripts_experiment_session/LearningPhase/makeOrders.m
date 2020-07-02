function [runMatrix2] = makeOrders(stimSet,repeats)

% Total Trials per run
stimNum = size(stimSet,1);
trialNum = repeats * stimNum;
if mod(trialNum,stimNum) ~= 0
    error('stimNum must be a factor of trialNum');
end
stimRep = trialNum / stimNum;

% Trial types
single = [1;2;3;4;5;6]; %Trial types 1-6 are single trials.
doubled = [11;22;33;44;55;66]; %Trial types 11-66 are repeated twice.
%Weights
singDoubRatio = [1/3 2/3] * trialNum;
% Multiply trial types according to Weights and Total num of Trial desired and Concatenate
runMatrix = [repmat(single, singDoubRatio(1)/stimNum ,1);repmat(doubled, singDoubRatio(2)/(stimNum*2) ,1)];

% Randomize order of trial types
shuf = randperm(length(runMatrix));
runMatrix = runMatrix(shuf, :);

% Replace numbers by actual Stimuli and Values AND double the Doulbed
% trials
runMatrix2 = {};
for i = 1 : length(runMatrix)
    if any(runMatrix(i) == doubled)
        ind = find(runMatrix(i) == doubled);
        runMatrix2{end+1,1} = stimSet{ind,1};
        runMatrix2{end,2} = stimSet{ind,2};
        runMatrix2{end+1,1} = stimSet{ind,1};
        runMatrix2{end,2} = stimSet{ind,2};
    elseif any(runMatrix(i) == single)
        ind = find(runMatrix(i) == single);
        runMatrix2{end+1,1} = stimSet{ind,1};
        runMatrix2{end,2} = stimSet{ind,2};
    end   
end

end
