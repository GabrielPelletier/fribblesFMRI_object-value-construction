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


% %% Split By Half-Set
% TrialOrder1={};
% OrderSplit = [1;1;2;2;3;3;2;2;1;1;3;3;2;1;1;3;3;2;2;1;3;4;4;6;6;5;5;4;4;6;6;4;4;5;5;4;6;6;5;5;6;5];
% %% For Conjunction, Stim set 2.
% for i = 1:length(OrderSplit)
%    if OrderSplit(i,1) == 1
%        TrialOrder1{i,1} = 'Fa2_2221_m.jpg';
%        TrialOrder1{i,2} = 56;
%    elseif OrderSplit(i,1) == 2
%        TrialOrder1{i,1} = 'Fa2_2121_m.jpg';
%        TrialOrder1{i,2} = 21;
%    elseif OrderSplit(i,1) == 3
%        TrialOrder1{i,1} = 'Fa2_2122_m.jpg';
%        TrialOrder1{i,2} = 63;
%           elseif OrderSplit(i,1) == 4
%        TrialOrder1{i,1} = 'Fa2_2223_m.jpg';
%        TrialOrder1{i,2} = 28;
%           elseif OrderSplit(i,1) == 5
%        TrialOrder1{i,1} = 'Fa2_2323_m.jpg';
%        TrialOrder1{i,2} = 49;
%           elseif OrderSplit(i,1) == 6
%        TrialOrder1{i,1} = 'Fa2_2322_m.jpg';
%        TrialOrder1{i,2} = 35;
%    end
% end