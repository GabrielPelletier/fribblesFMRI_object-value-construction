 %=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
                                %=%%=%%=% 
                                
%=%%=%%             Script by Gabriel Pelletier, 2017               %=%%=%%
%                     (Last update Jan 15, 2018)                        %

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
function learning_probe_rating (myScreen, rect, subInfo, condition, stimMatrix, outputDir, probeCount)


%% Number Runs, Blocks/Run and Trials/Block
runNum = 1;
blockNum = 6; % One block contains Trials = number of unique stimuli in Conj set + Summ set

%% Output Folder
outputFile = [outputDir, subInfo.SubID, '_LearningProbeRating', condition,'_', num2str(probeCount),'.mat'];

% Get stimulus matrix + values
stimValues = stimMatrix;

%% Experiment Parameters
% Iter Trial Interval (jittered)
ITI = 1.5;
jit = 0.5;
% Maximum RT for ratings
maxRatingTime = 7;
% Time interval (jittered) between Stimulus and Rating scale
fixTime2 = 3;
% Duration of presentation of Stimulus (jittered?)
stimDuration = 2.5;
%% Stimuli and Output Directory
stimFolder = [pwd,'/Stimuli/RatingTask/'];
outFolder = [pwd,'/Output/'];

%% Create Response Matrix
timeStamp = datestr(now);
dataHeader = {'subID', 'run', 'block', 'trial', 'stimulus', 'rating', 'RT', ...
'trialOnsetTime', 'stimOnsetTime', 'stimDuration', 'ratingOnsetTime'};
ratingData = {};

%% Start Psychtoolbox and Open a black Window
%[myScreen, rect] = Screen('OpenWindow', 0, 0);
% Hide Cursor
HideCursor();
% Font size and colors for Text
black = [0 0 0];
white = [255 255 255];
Screen('TextSize', myScreen, 30);

[Xcenter, Ycenter] = RectCenter(rect); 
StimYsize = 400;
StimXsize = 530;
destrectStim = [Xcenter-StimXsize/2, Ycenter-(StimYsize/2), Xcenter+StimXsize/2, Ycenter+(StimYsize/2)];

%%
%%%=== Task Starts Here === %%%

% Run Loop
for r = 1 : runNum
    % Block Loop
    for b = 1 : blockNum
    % Shuffle trial order
    rng('shuffle');
    NN = size(stimValues,1);
    stimValues = stimValues(randperm(NN),:);
        
    %% Trial
            for t = 1 : size(stimValues,1)
            % Select stimulus
            stimFileName = stimValues{t,1};
            % Prepare Stimulus for presentation
            trialFribble = imread([stimFolder,stimFileName]);
            stimulus = Screen('MakeTexture', myScreen, trialFribble);

            % ITI, Present Fixation Cross
            DrawFormattedText(myScreen, '+', 'center', 'center', white);
            tfix1 = Screen('Flip', myScreen);
            jitITI = ITI + (rand*jit);
            WaitSecs(jitITI); 
            
            % Present Stimulus with Rating Scale
            % Question and scale Anchor text
            if strcmp(subInfo.Language, 'English')
                question = 'What is the value of this item?';
            elseif strcmp(subInfo.Language, 'Hebrew')
                question = 'What is the value of this item?';
            end
            anchorTxt = {'₪20', '₪100'};
            anchorValues = [20 100];
            % call Rating Scale Function
            [position, RT, answer, scaleOnsetT] = slideScale (myScreen, question, rect, anchorTxt, anchorValues,...
                'aborttime',maxRatingTime,'device', 'keyboard', 'scalaPosition', 0.85, 'displayposition', true, 'image',...
                 trialFribble, 'imagedestrect', destrectStim);

            % log Trial data, one matrix per Run.
            ratingData{end+1,1} = str2double(subInfo.SubID);
            ratingData{end,2} = r; % current run
            ratingData{end,3} = b; % current block
            ratingData{end,4} = t; % current trial
            ratingData{end,5} = stimValues{t,1}; % Which stimulus was presented
            ratingData{end,6} = position; % rating result
            ratingData{end,7} = RT/1000;
            ratingData{end,8} = tfix1; % Trial Onset Time (first fix cross)
%            ratingData{end,9} = StimulusOnsetTime;
%            ratingData{end,10} = tfix2-StimulusOnsetTime; % Stimulus Presentation Duration
            ratingData{end,11} = scaleOnsetT; % Rating Scale onset time
            ratingData{end,12} = stimValues{t,2}; % Real learned stim Value
            %{end,13} = stimValues{t,3}; % Learning Condition
            end % Trial loop
                
    end % Block loop

     % End Of Run Break
      %DrawFormattedText(myScreen, 'End of Run', 'center', 'center', white);
      %Screen('Flip', myScreen);
      %KbWait(-1, 2);
      save(outputFile,'ratingData');
      ratingData = {};
end % Run Loop


      
%% Quit
ShowCursor();
end %end function
