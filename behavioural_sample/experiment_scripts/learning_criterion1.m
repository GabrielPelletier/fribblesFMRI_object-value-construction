%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: learning_criterion1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=                          Gabriel Pelletier                            =%
%=                  --- Last update : May 24, 2016 ---                   =%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes the Results from the 
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LearningOk] = learning_criterion1(SubjectId, resultFile, criterion)

%%% Coding/debugging purposes %%%
%SubjectId = 121;

% Load the output .mat file from learning_probe function
load([pwd,resultFile,SubjectId]);
% Keep only the 2nd and 3rd column in an Array called A
A = Results.data(:,2:3);

% Define pairType and for each pair type compute the number of Total
% presenatation and the number of Good responses

typePair1tot=0;
typePair1good=0;
typePair2tot=0;
typePair2good=0;
typePair3tot=0;
typePair3good=0;

for i =1:size(A,1) %size(A,1) is the number of rows of A (trialNum)
    if A(i,1) == 1
    typePair1tot = typePair1tot+1;
        if A(i,2)==1
        typePair1good=typePair1good+1;
        end
    end
    
    if A(i,1) == 2
    typePair2tot = typePair2tot+1;
        if A(i,2)==1
        typePair2good=typePair2good+1;
        end
    end
    
    if A(i,1) == 3
    typePair3tot = typePair3tot+1;
        if A(i,2)==1
        typePair3good=typePair3good+1;
        end
    end
end

% Define what is the desired Learning Criterion
%criterionTot = 0.9; % All trials combined
criterionInd = criterion; % For each individual Pair types % this value is Input Arg of the function
typePair1crit = 0; % 0 = criterion not met.
typePair2crit = 0;
typePair3crit = 0;

% Check if criterion is met
if (typePair1good/typePair1tot) >= criterionInd
typePair1crit = 1; % 1 = Criterion is met
end
if (typePair2good/typePair2tot) >= criterionInd
typePair2crit = 1;
end
if (typePair3good/typePair3tot) >= criterionInd
typePair3crit = 1;
end

% Get how many stim-reward associations have been learned. This will be the
% output of the function to decide if we go on or we go back to learning.
LearningOk = typePair1crit + typePair2crit + typePair3crit;

end %end of the function