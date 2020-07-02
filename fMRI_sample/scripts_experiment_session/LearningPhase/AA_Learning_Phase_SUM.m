%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

            % LEARNING PHASE OF THE FRIBBLES FMRI EXPERIMENT %      
            
                                %=%%=%%=% 
                                
%=%%=%%             Script by Gabriel Pelletier, 2017               %=%%=%%
%                      (Last update Jan 23, 2018)                         %

                                %=%%=%%=%    
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%%%%%                                                                 %%%%%    
%                    %%% === Script structure === %%%                     % 
%                   
%         - Learning Conjunction Condition
%               > Learning Block
%               > Learning Probe
%               > Repeat XX cycles
%
%         - Learning Single Attribute Condition
%               > Learning Block
%               > Learning Probe
%               > Repeat XX cycles
%     
%          - Adapted to run on mac, Jan 2018
%           
%          - Modified in Jan 2018
%               > Learning phase structure changed
%               >
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%


function [sumSet] = AA_Learning_Phase_SUM(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun, do_learn, do_probe)

%% Experimental Parameters
repeats = 6;
subjectNumber = subInfo.SubID;

%% Define stimulus fodler

% Assign stimulus sets depending on Order
if subInfo.StimFamily{1} == 1
    
    if subInfo.StimOrder{1} == 1
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/SingleAttribute/'];
    elseif subInfo.StimOrder{1} == 2
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/SingleAttribute/'];
    end
    
elseif subInfo.StimFamily{1} == 2
    
    if subInfo.StimOrder{1} == 1
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/SingleAttribute/'];
    elseif subInfo.StimOrder{1} == 2
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/SingleAttribute/'];
    end
    
end

%% Summation condition = Single attributes - value learning
if do_learn
    % Instructions   
    instruction_display(window, windowRect, instructionFolder, 'Slide4','Slide5','Slide6','Slide7');

    % Rating scale demo, only if its the first condition.
    if subInfo.LearnOrder{1} == 2
        ratingScaleDemo(window, windowRect, instructionFolder)
    end
    instruction_display(window, windowRect, instructionFolder,'Slide8');
end

% Declare variables
condition = 'SingleAttribute';
blockCount = 1; % Will add 1 each time a learning block is done (for data log)
probeCount = 1;

% Load the Stimulus-Value association Matrix
if subInfo.ValueVersion{1} == 1
    load([sumSetFolder,'stimuliValue_v1.mat']);
    load([sumSetFolder,'stimuliValueSum_v1.mat']);
    load([sumSetFolder,'/trialOrder_Sum_v1.mat']);
elseif subInfo.ValueVersion{1} == 2
    load([sumSetFolder,'stimuliValue_v2.mat']);
    load([sumSetFolder,'stimuliValueSum_v2.mat']);    
    load([sumSetFolder,'/trialOrder_Sum_v2.mat']);
end
sumSet = stimuliValueSum;
% Sort the Stimulus-Value matrix in order of value
stimuliValueSorted = sortrows(stimuliValue,2);
singFullSet = stimuliValueSorted;

for i = blocksToRun % Crash recovery
    
    if i == 1 % First learning block, a bit different from the others (order pre-deifined)
     learning_block (window, windowRect, subjectNumber, subInfo.Language, condition, sumSetFolder, ...
         outFolder, singFullSet, repeats, i, 70, instructionFolder, trialOrder)
     blockCount = blockCount + 1;
     % Break between each block 
     instruction_display(window, windowRect, instructionFolder, 'Slide26');
     
    elseif i ~= 1 % Remaning Blocks
        [trialOrder] = makeOrders(singFullSet,repeats);
        learning_block (window, windowRect, subjectNumber, subInfo.Language, condition, sumSetFolder, ...
            outFolder, singFullSet, repeats, i, 60, instructionFolder, trialOrder)
        blockCount = blockCount + 1;
    % Break between each block
        if i < blocksToRun(end)
            instruction_display(window, windowRect, instructionFolder, 'Slide26');
        end

    end
    
end

    
if do_probe % Crash Recovery 
    
    % Learning probe with Value Rating Task
            instruction_display(window, windowRect, instructionFolder, 'Slide9', 'Slide11','Slide29');
            learning_probe_rating(window, windowRect, subInfo, condition, sumSet, outFolder, probeCount);
            probeCount = probeCount + 1;
       
end

%% Save and Quit
fclose all;
ShowCursor();
end % End function