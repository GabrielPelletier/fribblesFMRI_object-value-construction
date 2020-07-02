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

function [conjFullSetProbe] = AA_Learning_Phase_CON(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun, do_learn, do_probe)
ListenChar();

%% Experimental Parameters
repeats = 6; % Each stmili will be repeated X times during one block.
subjectNumber = subInfo.SubID;

%% Define stimulus fodler
% Assign stimulus sets depending on Order

if subInfo.StimFamily{1} == 1

    if subInfo.StimOrder{1} == 1
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/WholeObject/'];
    elseif subInfo.StimOrder{1} == 2
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/WholeObject/'];
    end
    
elseif subInfo.StimFamily{1} == 2  
    
    if subInfo.StimOrder{1} == 1
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/WholeObject/'];
    elseif subInfo.StimOrder{1} == 2
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/WholeObject/'];
    end

end

% Load the Stimulus-Value association Matrix depending on valueVersion
if subInfo.ValueVersion{1} == 1
    load([conjSetFolder,'stimuliValue_v1.mat']);
    load([conjSetFolder,'stimuliValueWhole_v1.mat']);
    load([conjSetFolder,'/trialOrder_Conj_v1.mat']);
elseif subInfo.ValueVersion{1} == 2
    load([conjSetFolder,'stimuliValue_v2.mat']);
    load([conjSetFolder,'stimuliValueWhole_v2.mat']);
    load([conjSetFolder,'/trialOrder_Conj_v2.mat']);
end
conjFullSet = stimuliValue;
conjFullSetProbe = stimuliValueWhole;

%% Conjunction condition; Attributes combinations - value learning.

if do_learn % Crash Recovery
    % Instructions
    instruction_display(window, windowRect, instructionFolder, 'Slide16','Slide17','Slide18','Slide19');
    % Rating scale demo, only if its the first condition.
    if subInfo.LearnOrder{1} == 1
        ratingScaleDemo(window, windowRect, instructionFolder)
    end
    instruction_display(window, windowRect, instructionFolder,'Slide20');
end

% Declare variables
condition = 'Conjunction';
blockCount = 1; % Will add each time a learning block is done (for data log)
probeCount = 1;


for i = blocksToRun % Crash recovery
    
    if i == 1 % Only this procedure for the frist learning block
        
    % Run first Learning Block WITH mask
     learning_block (window, windowRect, subjectNumber, subInfo.Language, condition, conjSetFolder, ... 
         outFolder, conjFullSet, repeats, i, 70, instructionFolder, trialOrder)
     blockCount = blockCount + 1;
    % Break between Blocks + Instructions about removing the mask.
     instruction_display(window, windowRect, instructionFolder, 'Slide26');
 
    elseif i ~= 1 % If we are past the first block
        
    % Run remaining learning blocks WITHOUT mask
        [trialOrder] = makeOrders(conjFullSetProbe,repeats);
        learning_block (window, windowRect, subjectNumber, subInfo.Language, condition, conjSetFolder, ...
            outFolder, conjFullSetProbe, repeats, i, 60, instructionFolder, trialOrder)
        blockCount = blockCount + 1;
    % Add break between each block
        if i < blocksToRun(end)
            instruction_display(window, windowRect, instructionFolder, 'Slide26');
        end
        
    end
    
end


    
if do_probe % Crash Recovery

    % Run Learning probe with Value Rating Task
    instruction_display(window, windowRect, instructionFolder, 'Slide12','Slide14'); 
    learning_probe_rating(window, windowRect, subInfo, condition, conjFullSetProbe, outFolder, probeCount); 
    probeCount = probeCount + 1;

end

%% Save and Quit
fclose all;
ShowCursor();
end % End function