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
function [stimRect, ratingData, timingCheck] = BB_bidTask_run (myScreen, rect, subInfo, run, runSeq, stimFolder, stimDur, eyeTracking)

Screen('TextFont', myScreen, 'Arial'); % This font supports Hebrew caracters.

% % If we are to use EyeTracking, Set it up
% if eyeTracking == 1
%     
%     eyetStatus = Eyelink('Initialize');
% 
%     black = BlackIndex(myScreen);
%     white = WhiteIndex(myScreen);
%     dummymode = 0; 
%     el=EyelinkInitDefaults(myScreen);
%     el.backgroundcolour = black;
%     el.backgroundcolour = black;
%     el.foregroundcolour = white;
%     el.msgfontcolour    = white;
%     el.imgtitlecolour   = white;
%     el.calibrationtargetcolour = el.foregroundcolour;
%     EyelinkUpdateDefaults(el);
%     
%     % exit program if this fails.
%     if ~EyelinkInit(dummymode, 1)
%         fprintf('Eyelink Init aborted.\n');
%         cleanup;  % cleanup function
%         return;
%     end
%     
%     [~,vs]=Eyelink('GetTrackerVersion');
%     fprintf('Running experiment on a ''%s'' tracker.\n', vs );
% 
%     % make sure that we get gaze data from the Eyelink
%     Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
% 
%     % open file to record data to
%     edfFileName = [num2str(subInfo.SubID),'_rate.edf'];
%     Eyelink('Openfile', edfFileName);
% 
%     % CALIBRATION of the eye tracker
%     EyelinkDoTrackerSetup(el);
%     % do a final check of calibration using driftcorrection
%     EyelinkDoDriftCorrection(el);
%     % get eye that's tracked
%     eye_used = Eyelink('EyeAvailable'); 
%     if eye_used == el.BINOCULAR % if both eyes are tracked
%         eye_used = el.LEFT_EYE; % use left eye
%     end
% 
% end


%% Create Response Matrix
timeStamp = datestr(now);
dataHeader = {'subID', 'run', 'trial', 'stimulus', 'rating', 'RT', ...
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
%%%=== Run Starts Here === %%%
                           
      if eyeTracking == 1    
          Eyelink('StartRecording');
          Eyelink('Message', 'RunID %d', run);
      end
                
      % Present Fixation Cross Before Run Starts
       DrawFormattedText(myScreen, '+', 'center', 'center',[255 255 255]);
       Screen('Flip', myScreen);
       WaitSecs(2);
       
   % This will containt the run's data              
   ratingData = {};
   
   % Rating Scale stuff
     if strcmp(subInfo.Language,'English')
         question = 'How much are you willing to pay for this item?';
     elseif strcmp(subInfo.Language,'Hebrew')
         question = 'How much are you willing to pay for this item?';
     end
        anchorTxt = {'₪20', '₪100'};
        anchorValues = [20 100];   
   
    t0 = GetSecs();
    
    %% Trial
            for t = 1 : length(runSeq.stimList)

                if eyeTracking == 1    
                    Eyelink('Message', 'TrialID %d', t);
                end
                
             %% If trial is a BID (rating) TRIAL
                
                if strcmp(runSeq.stimList{t},'bid')

                    % call Rating Scale Function
                    WaitSecs('UntilTime', t0 + runSeq.stimOnsetTime(t)); % Per-specified OnetStime
                    
                        if eyeTracking == 1
                            Eyelink('Message', 'RatingScaleOnset');
                        end                 
                        
                    [position, RT, answer, scaleOnsetTime, startingPosition] = slideScale_mod(myScreen, question, rect, anchorTxt, anchorValues,...
                        'aborttime', stimDur,'device', 'keyboard', 'startposition', 'center','displayposition', true);
                    % Present corss if answer faster than max Rating time.
                    DrawFormattedText(myScreen, '+', 'center', 'center', white);
                    Screen('Flip', myScreen);
                    
                    %% ITI Fixation Cross
                    DrawFormattedText(myScreen, '+', 'center', 'center', white);
                    itiFix = Screen('Flip', myScreen, t0 + runSeq.itiOnsetTime(t));

                        if eyeTracking == 1
                            Eyelink('Message', 'itiFix');
                        end
                        
                    % Log data
                    ratingData{end+1,1} = str2double(subInfo.SubID);
                    ratingData{end,2} = run; % current Run                    
                    ratingData{end,3} = t; % current trial
                    ratingData{end,4} = runSeq.stimList{t,1}; % Which stimulus was presented
                    ratingData{end,7} = position; % Rating result
                    ratingData{end,8} = RT/1000; % Reaction time in Sec
                    ratingData{end,9} = startingPosition;  % Where the slider started
                    
                    timingCheck (t,1) = scaleOnsetTime - t0;
                    timingCheck (t,2) = itiFix - t0;                    
                  
                else
                 %% Otherwise, STIMULUS TRIAL 
                    stimFileName = runSeq.stimList{t};
                    % Prepare Stimulus for presentation
                    trialFribble = imread([stimFolder,stimFileName]);
                    stimulus = Screen('MakeTexture', myScreen, trialFribble);

                    % Present Stimulus
                    Screen('DrawTexture', myScreen, stimulus, [], stimRect);
                    [VBLTimestamp, StimulusOnsetTime, FlipTimestamp] = Screen('Flip', myScreen, t0 + runSeq.stimOnsetTime(t));

                        if eyeTracking == 1
                            Eyelink('Message', 'StimulusOnset');
                        end             


                    %% ITI Fixation Cross
                    DrawFormattedText(myScreen, '+', 'center', 'center', white);
                    itiFix = Screen('Flip', myScreen, t0 + runSeq.itiOnsetTime(t));

                        if eyeTracking == 1
                            Eyelink('Message', 'itiFix');
                        end

                    % log Trial data, one matrix per Run.
                    ratingData{end+1,1} = str2double(subInfo.SubID);
                    ratingData{end,2} = run; % Current Run
                    ratingData{end,3} = t; % current trial
                    ratingData{end,4} = runSeq.stimList{t,1};% Which stimulus was presented
                    ratingData{end,5} = runSeq.stimList{t,2};% The real stimulus value.
                    ratingData{end,6} = runSeq.stimList{t,3}; % Learning Condition
   
                    %ratingData{end,8} = tfix1; % Trial Onset Time (first fix cross)
                    %ratingData{end,9} = StimulusOnsetTime;
                    %ratingData{end,10} = tfix2-StimulusOnsetTime; % Stimulus Presentation Duration
                    %ratingData{end,11} = scaleOnsetT; % Rating Scale onset time
                    %ratingData{end,12} = allStimValues{t,2}; % Real learned stim Value
                    %ratingData{end,13} = allStimValues{t,3}; % Learning Condition  
                    timingCheck (t,1) = StimulusOnsetTime - t0;
                    timingCheck (t,2) = itiFix - t0;
                end
                
            end % Trial loop
            
            % After the last trial, Wait for the last ITI time
            WaitSecs(runSeq.ITI(t));

            % STOP the Trial's Eye tracking recording.
            if eyeTracking == 1
                Eyelink('StopRecording');
            end
            
ShowCursor();

end %end function
