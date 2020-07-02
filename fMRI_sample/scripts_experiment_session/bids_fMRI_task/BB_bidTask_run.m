%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
                                %=%%=%%=% 
                                
%=%%=%%             Script by Gabriel Pelletier, 2017               %=%%=%%
%                      (Last update March 2018)                         %

                                %=%%=%%=%    
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%%%%%                                                                 %%%%%    
%                    %%% === Script structure === %%%                     % 
%                   
%       - This script runs the Value-rating Task of the Fribbles_fMRI
%       experiment. It is done after the Learning Phase.
%       - Trial structure: Fixation cross, 1 fribble presented,
%               fixation cross, Rating scale (register response).
%    
%       - Task structure: X runs, Y blocks/runs, 
%         12 trials/blocks; 12 stimuli, random order. 
% 
%       - Output: 1.SubjectID,  2.Run,  3.Block,  4.Trial, 
%           5.TrialOnsetTime,  6.StimuluPresentationTime,
%           7.RatingScaleOnsetTime,  9.ResponseTime,  8.Rating RT,  
%           9.Rating Response
%           
%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
function BB_bidTask_run (subjectNumber, language, run, runSeq, runOnsetTimes, stimFolder, outFolder, eyeTracking, Scan)

HideCursor();
%ListenChar(-1);


%% Some duration parameters
% Stimulus duration (Same as rating scale max RT)
stimDur = 3;

% Duration of fixation cross at the end of run
postDur = 8;

% Duration of fixation Before run Starts
preDur = 3;

% Add the preDur to all the stimulus onsetTimes
runOnsetTimes = runOnsetTimes + preDur;

% What device is in use?
% For mri, write 'keyboard' for responseBox and 'mouse' for trackball
device = 'keyboard';


%% Ouput files
% Create Data Matrix
timeStamp = datestr(now);
ratingDataHeader = {'subID', 'run', 'trial', 'stimulus', 'stimulusValue', 'Condition', ...
'valueRating', 'RT', 'scaleStartingPosition', 'stimulusOnset', 'stimulusOffset', 'ratingScaleOnset', 'ratingScaleOffset'};
ratingData = {};
ratingSliderPath = {};

% Opens Text file to write data to
fid = fopen([outFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(run),'.txt'],'w');
%Header of text file (colums)
fprintf(fid,'SubjecNumber\trun\ttrial\tStimulus\tStimulusValue\tCondition\tRating\tRatingRT\tStartSliderPosition\tstimulusOnset\tStimulusOffset\tRatingScaleOnset\tRatingScaleOffset\n');


%% Setup Psychtoolbox and Open Window
% The screen function sometimes fail to synchronize and crashes,
% If this happens, we try again without crashing the script.
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
grey = white/2;
disp(grey)
keepTrying = 1;
while keepTrying < 10
    try
        [myScreen, rect] = PsychImaging('OpenWindow', 0, grey);
        HideCursor;
        keepTrying = 10;
    catch
        keepTrying = keepTrying + 1;
        disp(['Open screen Function Crashed for the ', num2str(keepTrying), ' time.']);
        sca;
    end
    if keepTrying == 4
        Screen('Preference', 'SkipSyncTests', 1); % Skip sync test so it works
        disp('Sync test was skipped because screen crashed too many times')
    end
end


% Font size and colors for Text
white = [255 255 255];
Screen('TextFont', myScreen, 'Arial'); % This font supports Hebrew caracters.
fixFontSize = 60;
textFontSize = 40;
Screen('TextSize', myScreen, 30);


% Get screen Center
screenXcenter = (rect(3)-rect(1))/2 + rect(1);
screenYcenter = (rect(4)-rect(2))/2 + rect(2);    


% Rectangle that will hold Stimulus, wich defines its Size and Position
% You can change the size, but for Fribbles, keep a 400x/300y ratio
stimXsize = 600;
stimYsize = 450;
stimRect = [screenXcenter-stimXsize/2, screenYcenter-stimYsize/2, screenXcenter+stimXsize/2, screenYcenter+stimYsize/2];


% Rating Scale stuff
if strcmp(language,'English')
   question = 'How much are you willing to pay for this item?';
elseif strcmp(language,'Hebrew')
   question = 'How much are you willing to pay for this item?';
end
anchorTxt = {'20', '100'};
anchorValues = [20 100];   


%% Set up the EyeTracker + Calibration
    if eyeTracking == 1
        eyeTrackerSetup (myScreen); 
       % Open file to record data to
        edfFileName = [num2str(subjectNumber), '_run',num2str(run), '.edf'];
        Eyelink('Openfile', edfFileName);
    end
    

%% Put up Instruction and Wait for participant Press
instruction_display(myScreen, rect, [stimFolder,'Instructions/',language,'/'], 'fribBids');

%% Start Eye-recording  
if eyeTracking == 1    
    Eyelink('StartRecording');
end

%% Wait for Scanner Trigger
DisableKeysForKbCheck([]); % re-enable all keys for KbCheck 
if Scan == 1
   % This is waiting for the Scanner trigger
   trigImage = imread([stimFolder,'Instructions/',language,'/trigger.jpg']);
   Screen('PutImage', myScreen, trigImage);
   Screen(myScreen,'Flip');
    while 1
        escapeKey = KbName('t');
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown && keyCode(escapeKey)
            break;
        end        
    end
DisableKeysForKbCheck(KbName('t')); % re-enable all keys for KbCheck 
elseif Scan == 0 % Wait for any keyboar input
    DrawFormattedText(myScreen,'Press any key to start the run', 'center', 'center', white);
    Screen(myScreen,'Flip');  
    while 1 
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            break;
        end        
    end
end

t0 = GetSecs; % Reference time for everything

if eyeTracking == 1 
    Eyelink('message','RUNSYNCTIME');
end

%%
%%%=== Run Starts Here === %%%     
tic

% Present Fixation Cross Before Run Starts
Screen('TextSize', myScreen, fixFontSize);
DrawFormattedText(myScreen, '+', 'center', 'center', [255 255 255]);
Screen('TextSize', myScreen, textFontSize);
Screen('Flip', myScreen);
% Will stay onScreen until the onset of the first stimulus,
% so the pre-duration is definded in defined in the onsetlists generator.
 

%% Trial loop
for t = 1 : length(runSeq)
    
                   if eyeTracking == 1    
                        Eyelink('Message', 'TrialID %d', t);
                   end
                    
                if strcmp(runSeq{t,1},'bid') %% If trial is a BID (rating) TRIAL

                    % call Rating Scale Function
                    WaitSecs('UntilTime', t0 + runOnsetTimes(t)); % Pre-specified OnetStime
                    
                        if eyeTracking == 1
                            Eyelink('Message', 'RatingScaleOnset');
                        end
                        
                    % Scale appears    
                    [position, RT, answer, scaleOnsetTime, startingPosition, trial_sliderPath] = slideScale_mod(myScreen, question, rect, anchorTxt, anchorValues,...
                        'aborttime', stimDur,'device', device, 'startposition', 'center','displayposition', true, 'scan', Scan);
                    
                    % Present cross if answer faster than max Rating time.
                    Screen('TextSize', myScreen, fixFontSize);
                    DrawFormattedText(myScreen, '+', 'center', 'center', [255 255 255]);
                    Screen('TextSize', myScreen, textFontSize);
                    Screen('Flip', myScreen);
                    
                    %% ITI Fixation Cross
                    Screen('TextSize', myScreen, fixFontSize);
                    DrawFormattedText(myScreen, '+', 'center', 'center', [255 255 255]);
                    Screen('TextSize', myScreen, textFontSize);
                    itiFix = Screen('Flip', myScreen, scaleOnsetTime + stimDur);

                        if eyeTracking == 1
                            Eyelink('Message', 'itiFix');
                        end
                    
                    % Log data in to mat
                    ratingData{end+1,1} = subjectNumber;
                    ratingData{end,2} = run; % current Run                    
                    ratingData{end,3} = t; % current trial
                    ratingData{end,4} = runSeq{t,1}; % Which stimulus was presented
                    ratingData{end,7} = position; % Rating result
                    ratingData{end,8} = RT/1000; % Reaction time in Sec
                    ratingData{end,9} = startingPosition;  % Where the slider started
                    ratingData{end,12} = scaleOnsetTime - t0;  % scale onset time
                    ratingData{end,13} = itiFix - t0;  % Scale offset time
                    % Load Full path of slider during this trial in the
                    % next column of the run's slider path matrix.
                    ratingSliderPath{1, end+1} = trial_sliderPath;
                    
                    % Load data into txt
                    fprintf(fid,'%d\t%d\t%d\t%s\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%d\t%d\n',...
                        subjectNumber,run,t,runSeq{t,1},'NaN','NaN',position,RT,startingPosition, 'NaN', 'Nan', scaleOnsetTime - t0, itiFix - t0);
                    
                    timingCheck (t,1) = scaleOnsetTime - t0;
                    timingCheck (t,2) = itiFix - t0;                    
                  
                else % Otherwise, STIMULUS TRIAL 
                    
                    stimFileName = runSeq{t,1};
                    % Prepare Stimulus for presentation
                    trialFribble = imread([stimFolder,stimFileName]);
                    stimulus = Screen('MakeTexture', myScreen, trialFribble);

                    % Present Stimulus
                    Screen('DrawTexture', myScreen, stimulus, [], stimRect);
                    [VBLTimestamp, StimulusOnsetTime, FlipTimestamp] = Screen('Flip', myScreen, t0 + runOnsetTimes(t));
                    
                    StimulusOnsetTime2 = GetSecs()-t0;
               
                        if eyeTracking == 1
                            Eyelink('Message', 'StimulusOnset');
                        end         
                        
                    StimulusOnsetTime3 = GetSecs()-t0;    
                    
                    %% ITI Fixation Cross
                    Screen('TextSize', myScreen, fixFontSize);
                    DrawFormattedText(myScreen, '+', 'center', 'center', [255 255 255]);
                    Screen('TextSize', myScreen, textFontSize);
                    itiFix = Screen('Flip', myScreen, StimulusOnsetTime + stimDur);

                        if eyeTracking == 1
                            Eyelink('Message', 'itiFix');
                        end

                    % log Trial data, one matrix per Run.
                    ratingData{end+1,1} = subjectNumber;
                    ratingData{end,2} = run; % Current Run
                    ratingData{end,3} = t; % current trial
                    ratingData{end,4} = runSeq{t,1};% Which stimulus was presented
                    ratingData{end,5} = runSeq{t,2};% The real stimulus value.
                    ratingData{end,6} = runSeq{t,3}; % Learning Condition
                    ratingData{end,10} = StimulusOnsetTime - t0;  % stimulus onset time
                    ratingData{end,11} = itiFix - t0;  % stimulus offset time
                    
                    % Load data into txt
                    fprintf(fid,'%d\t%d\t%d\t%s\t%d\t%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\n',...
                        subjectNumber,run,t,runSeq{t,1},runSeq{t,2},runSeq{t,3},'NaN','NaN','NaN',StimulusOnsetTime - t0,itiFix - t0, 'NaN', 'Nan');
                    
                    timingCheck (t,1) = StimulusOnsetTime - t0;
                    timingCheck (t,2) = itiFix - t0;
                    timingCheck (t,3) = StimulusOnsetTime2;
                    timingCheck (t,4) = StimulusOnsetTime3;
                    
                end
                
end % Trial loop


% After the last trial, present a fix Cross for some time
Screen('TextSize', myScreen, fixFontSize);
DrawFormattedText(myScreen, '+', 'center', 'center', [255 255 255]);
Screen('TextSize', myScreen, textFontSize);
itiFix = Screen('Flip', myScreen, StimulusOnsetTime + stimDur);
WaitSecs(postDur);


runDur = toc;    


% STOP the Run's Eye tracking recording.
if eyeTracking == 1
   Eyelink('StopRecording');
   Eyelink('CloseFile');
   Eyelink('ReceiveFile', edfFileName, outFolder, 1);
end


% Save Behavioral data files
save([outFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(run),'.mat'],'ratingData');
save([outFolder,num2str(subjectNumber),'ratingDataHeader.mat'],'ratingDataHeader');
save([outFolder,num2str(subjectNumber),'ratingSliderPath_Run',num2str(run),'.mat'], 'ratingSliderPath');
fclose(fid);


% Log and Save Run info
subRunInfo.startTime = t0;
subRunInfo.TimingChecks = timingCheck;
subRunInfo.RunDuration = runDur;
subRunInfo.StimList = runSeq;
subRunInfo.StimOnsets = runOnsetTimes;
subRunInfo.stimPositionBids = stimRect; % Size and Position of Stimulis for EyeTracking Analysis
subRunInfo.windowSize = rect;
save([outFolder,num2str(subjectNumber),'_subRunInfo_', num2str(run), '.mat'], 'subRunInfo');


% Close Screen
sca;
ShowCursor();
%ListenChar(-1);
sca;


end %end function
