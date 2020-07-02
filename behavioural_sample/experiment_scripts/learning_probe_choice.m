%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: learning_probe_conj.m
%            adapted from binary_choice.m (GP 2016)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=                          Gabriel Pelletier                            =%
%=                    --- Last update : Jan 2018 ---                     =%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function ...
%       1) Presents 2 images, one on each side of a central fixation cross.
%           - Num of Trials depends on amount on Stim in the StimFolder.
%           - Num of Blocks to be defined.
%       2) Registers a keyboard response for right/left Choice.
%       3) Logs in a Output file the Images presented, choices and RT.
%       4) Most importantly, logs in if the Stimuli chosen is the one with
%          the highest value (i.e. if learning has occured correctly)
%%%%%%%%%%%%%%%%%%%%%%
%   Other function file this function needs:
%       a) stim_pairs.m
%
%%%%%%%%%%%%%%%%%%%%%%
%   INPUT arguments:
%       1) StimFolder, containing only the desired Images.
%       2) Output path
%       3) 3 Arrays containing high-, med- & low- reward stimuli, as defined in the
%          learning_block_singleFeat function.
%       4) NumBlocks: # of blocks: number of repetitions -1 of all possible pairs that
%          stim_pairs will return, shuffled. !! # of rep - 1!!. If only 1
%          repetion, numBlock must be 0 (I know, it's weird).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function learning_probe_choice (window, windowRect, subjectNumber, condition, stimFolder, output, stimuliValue, pairRepeats, probeCount, feedback)

%% Trial timings
maxRT = 6; % Max reaction time allowed
ISI = 0.8; % Response Confirmation time.
ITI = 1.5; % Time of the fixation cross, jittered around jit.
jit = 0.5; % Jitter value

%% Output files
% Matlab file data
outputFile = [output, subjectNumber, '_LearningProbeChoice_', condition,'_', num2str(probeCount),'.mat'];
learningProbeChoice_Data = {}; 

% Text file data
fid1=fopen([output, subjectNumber, '_LearningProbeChoice_', condition,'_', num2str(probeCount),'.txt'], 'a');
% Header
fprintf(fid1,'Subject/tTrial/tKeyPressed/tChoice/tLeftPic/tRightPic/tRep-0Bad-1Good-2Tie/tReactionTime/r/n');

%% Stimulus Pairs generation
[shufPairs] = stim_pairs(stimuliValue, pairRepeats);
trialNum = (size(shufPairs,1));

%% Screen & hardware stuff 

%PsychDefaultSetup(2);
%Screen('Preference','SkipSyncTests', 1);

% Get screen number
screens = Screen('Screens');
% Draw to the external Screen if there is one
screenNumber = max(screens);

% Define colors for backgrounds, text and such
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
green = [150 150 150];
red = [255 0 0];
orange = [255 165 0];
% The frame Width around the chosen options
penWidth = 8;

% Opens a window filled with infinite darkness (the last [] makes the
%   presentation screen smaller (not full screen) so we can still see and 
%   write on the MATLAB window [0 0 1000 580]
%[window, windowRect] = PsychImaging ('OpenWindow', screenNumber, black);
    
% Get the size and center coordinates of the actual Window
[screenXpixels, screenYpixels] = Screen('WindowSize' , window);
[Xcenter, Ycenter] = RectCenter(windowRect); 

% Text size
Screen('TextSize', window, 30);

% Hide cursor (default(); Hide all cursors on every screen)
HideCursor();
%ListenChar(2); % Typed characters won't print in the Command window and screw up the script

% Response Keys
KbName('UnifyKeyNames');
leftChoice = 'LeftArrow';
rightChoice = 'RightArrow';


%% Trial Presentation

%%%Get the size of the Image, in this case they are all the same
Ysize = 300;
Xsize = 400;

for t = 1:trialNum % == the length of the Matrix with generateed (and repeated) pairs
    
    % Load images and Make textures
    %left option
    stimulus1 = imread([stimFolder,shufPairs{t,1}]);
    imageTexture1 = Screen('MakeTexture', window, stimulus1);
    %right option
    stimulus2 = imread([stimFolder,shufPairs{t,2}]);
    imageTexture2 = Screen('MakeTexture', window, stimulus2);

    % Destination rectangles (Defining the position and size of the images)
    %left
    destrect1 = [Xcenter-(Xsize/2)-(screenXpixels/4), Ycenter-Ysize/2, Xcenter+(Xsize/2)-(screenXpixels/4), Ycenter+Ysize/2];
    %right
    destrect2 = [Xcenter-(Xsize/2)+(screenXpixels/4), Ycenter-Ysize/2, Xcenter+(Xsize/2)+(screenXpixels/4), Ycenter+Ysize/2];
    
    % Start Trial with Fixation Cross
    DrawFormattedText(window, '+', 'center', 'center', white);
    Screen('Flip', window);
    WaitSecs(ITI+(rand*jit));

    % Draw images to screen (not yet Visible).
    %left
    Screen('DrawTexture', window, imageTexture1, [], destrect1, 0);%the second  bracket is the Destination Rectangle and 0 (last argument) is the rotation angle.
    %right
    Screen('DrawTexture', window, imageTexture2, [], destrect2, 0);
    
    Screen('Flip', window); %Images are now visible
    secs0 = GetSecs; %sets time 0 for RT calculation


    % Register Response
    % Has a key press repsonse been made?
        noresp = 1;
        while noresp
            [keyIsDown, secs, firstPress, deltaSecs] = KbCheck;
            
                if keyIsDown
                keyPressed = KbName(firstPress);

                    if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                                keyPressed=char(keyPressed);
                                keyPressed=keyPressed(1);
                    end

                % Was the key pressed a defined response Key?    
                    switch keyPressed
                        case leftChoice
                            noresp = 0;
                        case rightChoice
                            noresp = 0;
                    end
                    
                    % Get Chosen and Unchosen Stimuli
                     if strcmp(keyPressed, leftChoice) == 1
                             chosen = shufPairs{t,1};
                              unchosen = shufPairs{t,2};
                     elseif strcmp(keyPressed, rightChoice) == 1   
                              chosen = shufPairs{t,2};
                              unchosen = shufPairs{t,1};   
                     end
                
                     
                     
                % Verify Response (Good = 1, Error = 0; Tie = 2)
                
                % Get Chosen and Unchosen stimulus value
                chosenInd = find(strcmp(stimuliValue(:,1),chosen));
                chosenValue = stimuliValue{chosenInd,2};
                unchosenInd = find(strcmp(stimuliValue(:,1),unchosen));
                unchosenValue = stimuliValue{unchosenInd,2};

                    if chosenValue > unchosenValue
                        response = 1;
                    elseif unchosenValue > chosenValue
                        response = 0;
                    elseif unchosenValue == chosenValue
                        response = 2; % Tie
                    end

                % Response Confirmation (and Feedback if option is 'on')
                Screen('DrawTexture', window, imageTexture1, [], destrect1, 0);
                Screen('DrawTexture', window, imageTexture2, [], destrect2, 0);

                    if strcmp(feedback,'off')
                        if strcmp(keyPressed, leftChoice) == 1 %leftChoice
                                Screen('FrameRect', window, orange, destrect1, penWidth);
                        elseif strcmp(keyPressed, rightChoice) == 1 %rightChoice
                                Screen('FrameRect', window, orange, destrect2, penWidth);
                        end
                    elseif strcmp(feedback,'on') && (response == 1) % Good respnse, Green FB
                        if strcmp(keyPressed, leftChoice) == 1 %leftChoice
                                Screen('FrameRect', window, green, destrect1, penWidth);
                                feedbackText = 'Good';
                        elseif strcmp(keyPressed, rightChoice) == 1 %rightChoice
                                Screen('FrameRect', window, green, destrect2, penWidth);
                                feedbackText = 'Good';
                        end
                        DrawFormattedText(window, feedbackText, 'center', (screenYpixels*0.8), white);
                    elseif strcmp(feedback,'on') && (response == 0) % Error, Red FB
                        if strcmp(keyPressed, leftChoice) == 1 %leftChoice
                                Screen('FrameRect', window, red, destrect1, penWidth);
                                feedbackText = 'Error';
                        elseif strcmp(keyPressed, rightChoice) == 1 %rightChoice
                                Screen('FrameRect', window, red, destrect2, penWidth);
                                feedbackText = 'Error';
                        end
                        DrawFormattedText(window, feedbackText, 'center', (screenYpixels*0.8), white);
                    end   
                     

                end % End of If key is down.

            RT = secs - secs0; % RT calculation

           % Abort if answer takes too long
                if secs - secs0 > maxRT
                    chosen = 'NoResp';
                    response = 99;
                    keyPressed = 'None';
                    DrawFormattedText(window, ['Too late \n Please respond faster'], 'center', 'center', white);
                    break
                end

        end % End of While...loop waiting for response

    Screen('Flip', window);
    
    % Wait ITI
    WaitSecs(ISI) % Response confirmation time
    Screen('FillRect', window, black);
    Screen('Flip', window);

    % Log trial data
    learningProbeChoice_Data(end+1,:) = [subjectNumber, t, shufPairs(t,1), shufPairs(t,2), chosen, response, RT*1000];
    fprintf(fid1, '%s/t%d/t%s/t/t%s/t%s/t%s/t/t/t%d/t%d/r/n', subjectNumber, t, keyPressed, shufPairs{t,1}, shufPairs{t,2}, chosen, response, RT*1000);

end

%% Save and Quit
fclose(fid1);
save(outputFile,'learningProbeChoice_Data');

ShowCursor();
ListenChar(1);

end %End function

