%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

                % Main script for Fribbles_fMRI experiment %      
                          % FMRI BIDING PHASE %
                                %=%%=%%=% 
                                   
%=%%=%%             Script by Gabriel Pelletier, 2018               %=%%=%%
%                      (Last update Feb, 2018)                         %

                                %=%%=%%=%    
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%%%%%                                                                 %%%%%    
%                    %%% === Script structure === %%%                     % 
%                   

%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

sca;
clear;
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
commandwindow;
tic;

%% Ask for subject Number and get subject Information
[subjectNumber] = subjectPrompt; % Subjec ID
% Do we use EyeTraking?
[eyeTracking] = EyeTrackingPrompt;

% Output folder
outFolder = [pwd,'/Output/',subjectNumber,'/'];
load([outFolder,'subInfo_',subjectNumber,'.mat']);

% Folder Instruction (Language)
instructionFolder = [pwd,'/Instructions/',subInfo.Language,'/'];

% Stimuli dir
stimFolder = [pwd,'/Stimuli/RatingTask/'];
 
% Load the matrix containig all the sequences
load('runSequences_v4.mat');
% Get this subject's sequences (1 per run)
runs = runSequences_v4{str2double(subjectNumber),1}.runs;
% How many runs?
numRuns = size(runs,2);
% Simulus Duration (for Scale Rating duration)
stimDur = 3;

%% Setup Psychtoolbox and Open Window
% The screen function sometimes fail to synchronize and crashes,
% If this happens, we try again without crashing the script.
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
grey = white/2;
keepTrying = 1;
while keepTrying < 5
    try
        [window, windowRect] = PsychImaging('OpenWindow', 0, grey);
        %[window, windowRect] = Screen('OpenWindow', 0, 0.5);
        keepTrying = 5;
    catch
        keepTrying = keepTrying + 1;
        disp(['Open screen Function Crashed for the ', num2str(keepTrying), ' time.']);
        sca;
    end
end
Screen('TextFont', window, 'Arial'); % This font supports Hebrew caracters.

% Set up the EyeTracker + Calibration
if eyeTracking == 1
   [edfFileName] = eyeTrackerSetup (window, subInfo.SubID); 
end

% Instructions after the setup of the EyeTracker
instruction_display(window, windowRect, instructionFolder, 'Slide25');

%% Run task
for i = 1 : numRuns
    runSeq = runs(i);
    [stimRect, ratingData, timingCheck] = BB_bidTask_run(window, windowRect, subInfo, i, runSeq, stimFolder, stimDur, eyeTracking);
    save([outFolder,subInfo.SubID,'_fmri_RatingTask_Run',num2str(i),'.mat'],'ratingData');

    % End of run Break
    if i < numRuns % Only if this is not the last Run
          DrawFormattedText(window, 'Short Pause \n Another Run will start in a few seconds.', 'center', 'center', [255 255 255]);
          Screen('Flip', window);
          WaitSecs(10);
          DrawFormattedText(window, 'The run starts now.', 'center', 'center', [255 255 255]);
          Screen('Flip', window);
          WaitSecs(2);
    end
    % Save real onset timings
    subInfo.TimingChecks{i} = timingCheck;
    
end

% End of task
subInfo.BidPhaseDuration = toc;
subInfo.RunSeq = runs;
subInfo.numRunsBid = numRuns;
subInfo.stimPositionBids = stimRect;% Size and Position of Stimulis for EyeTracking Analysis
subInfo.windowSize = windowRect;
save([outFolder,'subInfo_',subjectNumber,'.mat'], 'subInfo');
% Exp is over Slide
instruction_display(window, windowRect, instructionFolder, 'Slide27');
sca;
ShowCursor();
PsychHID('KbQueueStop');

% Shutdown the Eyetracker
if eyeTracking == 1
    Eyelink('CloseFile');
    Eyelink('ReceiveFile', edfFileName, outFolder, 1);
    Eyelink('Shutdown');
end

% Resolve the Auctions and show Bonus amount
auctionResolve(subjectNumber, numRuns);
