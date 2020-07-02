%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

                % Main script for Fribbles_fMRI experiment %      
                            % TRAINING PHASE % 
                                %=%%=%%=% 
                                
%=%%=%%             Script by Gabriel Pelletier, 2018               %=%%=%%
%                      (Last update Feb, 2018)                         %

                                %=%%=%%=%    
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%%%%%                                                                 %%%%%    
%                    %%% === Script structure === %%%                     % 
%                   
%         - Introduction Instructions
%               
%
%         - Value Learning Phase
%               > Instructions
%               > Runs AA_Learning_Phase.m
%     
%          - Value Rating Phase
%               > Instructions
%               > Runs AA_Rating_Task_Slider.m
%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

sca;
clear;
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebuglevel', 3); % No PTB intro screen
commandwindow;
tic

%% Subejct Information
[subjectNumber] = subjectPrompt; % Subjec ID
[age] = agePrompt; % Subjec ID
[gender] = genderPrompt; % Subjec ID
[lang] = languagePrompt; % Language for instruction
     instructionFolder = [pwd,'/Instructions/',lang,'/'];
%[eyeTracking] = EyeTrackingPrompt; % Ask if we'll use EyeTracking (1=yes)
eyeTracking = 0; % We won't use Eye-Tracking for the Practice.

% Get the learning condition order, the fibbles family used for this
% subjects and the sub-family used for each condition (8 possible
% combinations of these 3x2 factors).
load('order_learning_stimuli.mat'); % Order combinations are preloaded in a matrix
learnOrder = order_learning_stimuli(str2double(subjectNumber),1); % Order (1 = CONF first; 2 ELEM first)
stimFamily = order_learning_stimuli(str2double(subjectNumber),2); % Wich Family of Fribbles is used (one of two)
stimOrder = order_learning_stimuli(str2double(subjectNumber),3); % Wich SUB-Family of Fribbles is allocated to which Condition
valueVersion = order_learning_stimuli(str2double(subjectNumber),4); % Which version of stimuli-value association (1 or 2)? 

% Log in Subject information
subInfo.SubID = subjectNumber;
subInfo.LearnOrder{1} = learnOrder;
    if learnOrder == 1
        subInfo.LearnOrder{2} = 'Conjunction';
        subInfo.LearnOrder{3} = 'SingleAttribute';
    elseif learnOrder == 2
        subInfo.LearnOrder{2} = 'SingleAttribute';
        subInfo.LearnOrder{3} = 'Conjunction';
    end
subInfo.ValueVersion{1} = valueVersion;
subInfo.StimOrder{1} = stimOrder;
subInfo.StimFamily{1} = stimFamily;
subInfo.Language = lang;
subInfo.Age = age;
subInfo.Gender = gender;
subInfo.SessionTime = datetime;
subInfo.eyeTracking = eyeTracking;

% Attempt to Create Output Folder based on Subject number
outDir = [pwd,'/Output/'];
[ok, msg, msgID] = mkdir (outDir,[subjectNumber,'/']);


% Defaut parameters for running the task, will change if this is a recovery
% after code crash
learnBlocksNum = 5; % Total number of learning blocks

do_learn_cond1 = 1;
blocksToRun_cond1 = 1:learnBlocksNum;
do_probe_cond1 = 1;

do_learn_cond2 = 1;
blocksToRun_cond2 = 1:learnBlocksNum;
do_probe_cond2 = 1;

do_practice = 1;


%% Crash Recovery Procedure

% If the Folder already exists, ask what we should do (is this a recovery
% after a crash, or a simple mistake with the subNum?)

if isempty(msgID) == 0
    [recovery] = recoveryPrompt;
    
    % Do different Recovery procedure depending on what was selected in the prompt.
    if recovery == 0 % Abort everything
        return
    end
    
    if recovery == 2 % Overright the exixting file and start from scratch
    end
    
    if recovery == 1 % Do the Post-Crash Recovery procedure
    
    % Lod Subject info collected before Crash     
    load([outDir,subjectNumber,'/','subInfo_',subjectNumber,'.mat']); 
    
    % Check what was run already for FIRST learning condition. cond1

        % How many Learning blocks have we completed already?
        files1 = dir ([outDir,subjectNumber,'/','*Learning_',subInfo.LearnOrder{2},'*.mat']);

        if length(files1) == learnBlocksNum
            do_learn_cond1 = 0;
        end
        blocksToRun_cond1 = length(files1)+1 : learnBlocksNum;

        % Did we run the learning probe
        do_probe_cond1 = isempty(dir ([outDir,subjectNumber,'/','*LearningProbeRating',subInfo.LearnOrder{2},'_*.mat']));

    % Check what was run already for SECOND learning condition. cond2

        % How many Learning blocks have we completed already?
        files2 = dir ([outDir,subjectNumber,'/','*Learning_',subInfo.LearnOrder{3},'*.mat']);

        if length(files2) == learnBlocksNum % If we did all the blocks, skip the learning
            do_learn_cond2 = 0;
        end
        blocksToRun_cond2 = length(files2)+1 : learnBlocksNum;

        % Did we run the learning probe?
        do_probe_cond2 = isempty(dir ([outDir,subjectNumber,'/','*LearningProbeRating',subInfo.LearnOrder{3},'_*.mat']));


    % Check if the Bidding Practice was run already
        do_practice = isempty(dir ([outDir,subjectNumber,'/','*ValueRatingTask_Run1.mat']));
    end    
    
end

outFolder = [outDir,[subjectNumber,'/']];
subInfo.outFolder = outFolder;
save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');


%% Setup Psychtoolbox and Open Window
% The screen function sometimes fail to synchronize and crashes,
% If this happens, we try again without crashing the script.
keepTrying = 1;
screenOp = 0;
while keepTrying < 10
    try
        [window, windowRect] = PsychImaging('OpenWindow', 0, 0);
        keepTrying = 10;
        screenOp = 1;
    catch
        keepTrying = keepTrying + 1;
        disp(['Open screen Function Crashed for the ', num2str(keepTrying), ' time.']);
    end
end
if screenOp == 0
    sca;
    error('Screen function crashed 10 times trying to open screen. You can Try again running the start of the experiment')
end

Screen('TextFont', window, 'Arial'); % This font supports Hebrew caracters.


%% Learning Phase

if learnOrder == 1

    if length(blocksToRun_cond1) == learnBlocksNum % Crash Recovery stuff
        % General Introduction; only show if we did not complete the first
        % learning block.
        instruction_display(window, windowRect, instructionFolder, 'Slide1', 'Slide2', 'Slide3');
    end    
        
        % CON (Instructions are contained within the function)
        [conjFullSetProbe] = AA_Learning_Phase_CON(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun_cond1, do_learn_cond1, do_probe_cond1);
        subInfo.ConjSet = conjFullSetProbe;
        save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');
        
    if do_learn_cond1 % Crash recovery
        % Instructions Between 2 conditions learning
        instruction_display(window, windowRect, instructionFolder, 'Slide15');
        KbWait();
    end    
    
        % SUM (Instructions are contained within the function)
        [sumSet] = AA_Learning_Phase_SUM(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun_cond2, do_learn_cond2, do_probe_cond2);
        subInfo.SummSet = sumSet;
        save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');

    if do_learn_cond2 % Crash recovery
        % End of Learning
        instruction_display(window, windowRect, instructionFolder,'Slide21');
        KbWait();
    end
    
elseif learnOrder == 2
    
    if length(blocksToRun_cond1) == learnBlocksNum % Crash recovery   
        % General Introduction; only show if we did not complete the first
        % learning block.
        instruction_display(window, windowRect, instructionFolder, 'Slide1', 'Slide2', 'Slide3');
    end
    
    % SUM (Instructions are contained within the function)
    [sumSet] = AA_Learning_Phase_SUM(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun_cond1, do_learn_cond1, do_probe_cond1);
    subInfo.SummSet = sumSet;
    save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');
    
    if do_learn_cond1 % Crash recovery
    % Instructions Between 2 conditions
        instruction_display(window, windowRect, instructionFolder, 'Slide15');
        KbWait();
    end
    
    % CON (Instructions are contained within the function)
    [conjFullSetProbe] = AA_Learning_Phase_CON(subInfo, window, windowRect, instructionFolder, outFolder, blocksToRun_cond2, do_learn_cond2,do_probe_cond2);
    subInfo.ConjSet = conjFullSetProbe;
    save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');

    if do_learn_cond2 % Crash recovery  
        % End of Learning
        instruction_display(window, windowRect, instructionFolder,'Slide21');
        KbWait();
    end
    
end


%% Rating (Buying) Phase PRACTICE
if do_practice % Crash recovery
    
    numRuns = 1;
    numBlocks = 3;

    % The screen function sometimes fail to synchronize and crashes,
    % If this happens, we try again without crashing the script.
    screens = Screen('Screens');
    screenNumber = max(screens);
    white = WhiteIndex(screenNumber);
    grey = white/2;


    % Instructions
    instruction_display(window, windowRect, instructionFolder,'Slide22','Slide23','Slide24');

    % Run task
    [stimRect] = AA_bidTask_practice(window, windowRect, subInfo, numRuns, numBlocks, eyeTracking, outFolder);

    subInfo.LearningPhaseDuration = toc;

    % End of Training Phase
    subInfo.windowSize = windowRect;
    subInfo.stimPositionTraining = stimRect; % For eyeTracking Analysis
    subInfo.numRunsBidPractice = numRuns;
    save([outFolder,'subInfo_',subjectNumber,'.mat'],'subInfo');


    
end

instruction_display(window, windowRect, instructionFolder, 'Slide28');

ShowCursor();
sca;
PsychHID('KbQueueStop');


% Copy data to the lab's dropbox
try
    send_data_to_dropbox(subjectNumber, outDir);
catch
    fprintf('\nFailed to copy the files from this computer to Dropbox.\n');
end
