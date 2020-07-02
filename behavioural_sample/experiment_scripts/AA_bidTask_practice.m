 %=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
                                %=%%=%%=% 
                                
%=%%=%%             Script by Gabriel Pelletier, 2017               %=%%=%%
%                      (Last update Jan 23, 2018)                         %

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
function [stimRect] = AA_bidTask_practice(myScreen, rect, subInfo, runNum, blockNum, eyeTracking, outFolder)

% If we are to use EyeTracking, Set it up
if eyeTracking == 1
    
    eyetStatus = Eyelink('Initialize');

    black = BlackIndex(myScreen);
    white = WhiteIndex(myScreen);
    dummymode = 0; 
    el=EyelinkInitDefaults(myScreen);
    el.backgroundcolour = black;
    el.backgroundcolour = black;
    el.foregroundcolour = white;
    el.msgfontcolour    = white;
    el.imgtitlecolour   = white;
    el.calibrationtargetcolour = el.foregroundcolour;
    EyelinkUpdateDefaults(el);
    
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [~,vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');

    % open file to record data to
    edfFileName = [num2str(subInfo.SubID),'_rate.edf'];
    Eyelink('Openfile', edfFileName);

    % CALIBRATION of the eye tracker
    EyelinkDoTrackerSetup(el);
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    % get eye that's tracked
    eye_used = Eyelink('EyeAvailable'); 
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end

end

%% Define Stimuli to use and Get Stimulus/Value matrices
% Retrieve stimulus sets and associated value from learning phase

if subInfo.StimFamily{1} == 1
    
    if subInfo.StimOrder{1} == 1
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/WholeObject/'];
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/SingleAttribute/'];
    elseif subInfo.StimOrder{1} == 2
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet2/WholeObject/'];
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet1/SingleAttribute/'];
    end
    
elseif subInfo.StimFamily{1} == 2
    
    if subInfo.StimOrder{1} == 1
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/WholeObject/'];
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/SingleAttribute/'];
    elseif subInfo.StimOrder{1} == 2
        conjSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet4/WholeObject/'];
        sumSetFolder = [pwd,'/Stimuli/LearningPhase/StimSet3/SingleAttribute/'];
    end

end

% Get stimulus matrices based on this
load([conjSetFolder,'stimuliValueWhole.mat']);
conjStimValues = stimuliValueWhole;
conjStimValues(:,3) = {'conj'}; % Add learning condition info

load([sumSetFolder,'stimuliValueSum.mat']);
summStimValues = stimuliValueSum;
summStimValues(:,3) = {'summ'};

% Combine all Stim-values together
allStimValues = [conjStimValues;summStimValues];

%% Experiment Parameters
% Iter Trial Interval (jittered)
ITI = [1.5 4]; % Range for ITI
% Maximum RT for ratings
maxRatingTime = 3.5;
% Time interval (jittered) between Stimulus and Rating scale
fixTime2 = 3;
% Duration of presentation of Stimulus (jittered?)
stimDuration = 3;

%% Stimuli Directory
stimFolder = [pwd,'/Stimuli/RatingTask/'];

%% Create Response Matrix
timeStamp = datestr(now);
dataHeader = {'subID', 'run', 'block', 'trial', 'stimulus', 'rating', 'RT', ...
'trialOnsetTime', 'stimOnsetTime', 'stimDuration', 'ratingOnsetTime'};
ratingData = {};

%% Start Psychtoolbox and Open a black Window
% Hide Cursor
HideCursor();
% Font size and colors for Text
black = [0 0 0];
white = [255 255 255];
Screen('TextSize', myScreen, 30);

% Get screen Center
screenXcenter = (rect(3)-rect(1))/2 + rect(1);
screenYcenter = (rect(4)-rect(2))/2 + rect(2);    

% Define Rectangle that will hold Stimulus, 
% wich defines its Size and Position!

% You can change the size, but for Fribbles, keep a 400x/300y ratio
stimXsize = 600;
stimYsize = 450;
stimRect = [screenXcenter-stimXsize/2, screenYcenter-stimYsize/2, screenXcenter+stimXsize/2, screenYcenter+stimYsize/2];

%%
%%%=== Task Starts Here === %%%

% Run Loop
for r = 1 : runNum
                if eyeTracking == 1    
                    Eyelink('Message', 'RunID %d', r);
                end
                
      % Present Fixation Cross Before Run Starts
       DrawFormattedText(myScreen, '+', 'center', 'center',[255 255 255]);
       Screen('Flip', myScreen);
       WaitSecs(2);
                
    % Block Loop
    for b = 1 : blockNum
                if eyeTracking == 1    
                    Eyelink('Message', 'BlockID %d', b);
                end        
                
    % Shuffle trial order
    rng('shuffle');
    NN = size(allStimValues,1);
    allStimValues = allStimValues(randperm(NN),:);
        
    %% Trial
            for t = 1 : size(allStimValues,1)
                
                if eyeTracking == 1    
                    Eyelink('Message', 'TrialID %d', t);
                end
       
            % Select stimulus
            stimFileName = allStimValues{t,1};
            % Prepare Stimulus for presentation
            trialFribble = imread([stimFolder,stimFileName]);
            stimulus = Screen('MakeTexture', myScreen, trialFribble);
            % Jitter ITI That will follow the Trial
            jitITI = (ITI(2)-ITI(1)).*rand + ITI(1);
            
                % Start the Trial's Eye tracking recording.
                if eyeTracking == 1
                    Eyelink('StartRecording');
                end
                
            % Present Stimulus
            Screen('DrawTexture', myScreen, stimulus, [], stimRect);
            [VBLTimestamp, StimulusOnsetTime, FlipTimestamp] = Screen('Flip', myScreen);
                
                if eyeTracking == 1
                    Eyelink('Message', 'StimulusOfInterestOnset');
                end             
            
            % Present Fixation Cross (After Stimulus presentation Duration)
            DrawFormattedText(myScreen, '+', 'center', 'center',[255 255 255]);
            tfix2 = Screen('Flip', myScreen, StimulusOnsetTime+stimDuration);
            
                if eyeTracking == 1
                    Eyelink('Message', 'PostStimFix');
                end  
                
            [realWakeupTimeSecs] = WaitSecs('UntilTime', tfix2+fixTime2);
              
            
            % Rating Scale
            % Question and scale Anchor text
            question = 'How much are you willing to pay for this item?';
            anchorTxt = {'20₪', '100₪'};
            anchorValues = [20 100];
            
                if eyeTracking == 1
                    Eyelink('Message', 'RatingScaleOnset');
                end                 
            
            % call Rating Scale Function
            [position, RT, answer, scaleOnsetT, startingPosition] = slideScale_mod(myScreen, question, rect, anchorTxt, anchorValues,...
                'aborttime',maxRatingTime,'device','keyboard', 'startposition', 'center','displayposition', true);
            
                if eyeTracking == 1
                    Eyelink('Message', 'RatingScaleOffSet');
                end 
                
            % ITI Fixation Cross
            DrawFormattedText(myScreen, '+', 'center', 'center', white);
            tfix1 = Screen('Flip', myScreen);
            
                if eyeTracking == 1
                    Eyelink('Message', 'itiFix');
                end
                
           % Wait ITI, jittered    
           WaitSecs(jitITI);
                
            % log Trial data, one matrix per Run.
            ratingData{end+1,1} = str2double(subInfo.SubID);
            ratingData{end,2} = r; % current run
            ratingData{end,3} = b; % current block
            ratingData{end,4} = t; % current trial
            ratingData{end,5} = allStimValues{t,1}; % Which stimulus was presented
            ratingData{end,6} = position; % rating result
            ratingData{end,7} = RT/1000;
            ratingData{end,8} = tfix1; % Trial Onset Time (first fix cross)
            ratingData{end,9} = StimulusOnsetTime;
            ratingData{end,10} = tfix2-StimulusOnsetTime; % Stimulus Presentation Duration
            ratingData{end,11} = scaleOnsetT; % Rating Scale onset time
            ratingData{end,12} = allStimValues{t,2}; % Real learned stim Value
            ratingData{end,13} = allStimValues{t,3}; % Learning Condition
            ratingData{end,13} = startingPosition;  % Where the slider started 
            
            end % Trial loop
                
                % STOP the Trial's Eye tracking recording.
                if eyeTracking == 1
                    Eyelink('StopRecording');
                end            
            
    end % Block loop

     % End Of Run Break
     
     if r < runNum % Only if this is not the last Run
      DrawFormattedText(myScreen, 'End of Run', 'center', 'center', white);
      Screen('Flip', myScreen);
      KbWait(-1, 2);
     end
     
     % Save data after each run
      save([outFolder,subInfo.SubID,'_ValueRatingTask_Run',num2str(r),'.mat'],'ratingData');
      ratingData = {};
      
end % Run Loop

%% Quit

    if eyeTracking == 1
        Eyelink('CloseFile');
        Eyelink('ReceiveFile',edfFileName, outFolder, 1);
        Eyelink('Shutdown');
    end
    
ShowCursor();

end %end function
