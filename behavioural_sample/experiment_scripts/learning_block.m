%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: learning_block_conj
%  Adapted from Fribbles_EyeTracking task, for the Fribbles_fMRI project.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=                          Gabriel Pelletier                            =%
%=                  --- Last update : Dec 03, 2017 ---                   =%
%                    gabriel.pelletier@mail.mcgill.ca                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function ...
%  
%   Trial Structure:
%   - Presents an image alone for a period of time, then present
%     its outcome (it's value).
%   - The image and outcome then stay displayed until a key is pressed.
%   - This goes on for a number of trials.
%
%   - The function contains 1 block of training. Has to be called each time
%     another block is needed.
%
%   - Outcoumes vary in magnitude;
%     Reward magnitude for each Fribble (unique combination of attributes)
%     follows a normal distribution of MEAN and STDEV that can be 
%     manipulated.
%
%%%  Modifications to be done (Jan 2018)
%%%  - Add rating between a few seconds after the image is presented,
%%%    and the real price is shown.
%%%  - Use the slider Scale do to so.
%%%
%%%%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables for coding/debugging
% Output = [pwd,'/Results/'];
% stimFolder = 'ConjA/';
% SubjectId = '0';

function learning_block (window, windowRect, subjectNumber, lang, condition, stimFolder, output, stimuliValue, repeats, blockCount, countDownTime, instructionFolder, varargin)

%% Is the trial order pre-defined or is it generated in this script?
if isempty(varargin) == 1 % if order not provided
    getOrder = 0;
elseif isempty(varargin) == 0
    getOrder = 1;
    trialOrder = varargin{1};
end


%% Timing of trial phases
maxRatingTime = 5; % Stimulus Presentation + Rating
valueDuration = 2;

%% Output Files
% Create Output .text and .mat files
outputFile = [output, subjectNumber, '_Learning_', condition,'_', num2str(blockCount),'.mat'];
learningBlockData = {}; % Will hold the data in a matlab file.
fid1=fopen([output, subjectNumber, '_Learning_', condition,'_', num2str(blockCount),'.txt'], 'a');
% Header of the .txt OutputFile
fprintf(fid1,'Subject/tTrial/tPresentedStim/tOutcome/tRewLevel/r/n');

%% Scale parameters, Question and Anchors
if strcmp(condition,'Conjunction')
    anchorTxt = {'₪20', '₪100'};
    anchorValues = [20 100];    
elseif strcmp(condition,'SingleAttribute')
    anchorTxt = {'₪5', '₪55'};
    anchorValues = [5 55];
end

if strcmp(lang,'English')
    question = 'What is the value of this item?';
elseif strcmp(lang,'Hebrew')
    question = 'What is the value of this item?';
end


%% Screen Preparation/Initiation (if needed)
HideCursor();
% Get screen number
screens = Screen('Screens');
% Draw to the external Screen if there is one
screenNumber = max(screens);

% Define colors for backgrounds, text and such
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);

% Opens a black window
%[window, windowRect] = Screen('OpenWindow',0, black);

% Get the size and center coordinates of the actual Window
%[screenXpixels, screenYpixels] = Screen('WindowSize' , window);
[Xcenter, Ycenter] = RectCenter(windowRect); 

% Text size
Screen('TextSize', window, 25);

%% Reward distributions
% Load Reward matrices
if strcmp(condition,'Conjunction')
    load([pwd,'/ValueMatrices/d1.mat'],'d1');
    load([pwd,'/ValueMatrices/d2.mat'],'d2');
    load([pwd,'/ValueMatrices/d3.mat'],'d3');
    load([pwd,'/ValueMatrices/d4.mat'],'d4');
    load([pwd,'/ValueMatrices/d5.mat'],'d5');
    load([pwd,'/ValueMatrices/d6.mat'],'d6');
    v1 = d1;
    v2 = d2;
    v3 = d3;
    v4 = d4;
    v5 = d5;
    v6 = d6;
elseif strcmp(condition,'SingleAttribute')
    load([pwd,'/ValueMatrices/dS1.mat'],'dS1');
    load([pwd,'/ValueMatrices/dS2.mat'],'dS2');
    load([pwd,'/ValueMatrices/dS3.mat'],'dS3');
    load([pwd,'/ValueMatrices/dS4.mat'],'dS4');
    load([pwd,'/ValueMatrices/dS5.mat'],'dS5');
    load([pwd,'/ValueMatrices/dS6.mat'],'dS6');
    v1 = dS1;
    v2 = dS2;
    v3 = dS3;
    v4 = dS4; % %Will not be used in SingleAtt learning
    v5 = dS5;
    v6 = dS6;
end

% Shuffle the arrays
rng('shuffle');
n = length(v1);
v1 = v1(randperm(n),:);
v2 = v2(randperm(n),:);
v3 = v3(randperm(n),:);
v4 = v4(randperm(n),:);
v5 = v5(randperm(n),:);
v6 = v6(randperm(n),:);

%==========================Stimulus Presentation==========================%
%%%Get the size of the Images, in this case they are all the same
StimYsize = 400;
StimXsize = 530;
RewaYsize = 150;
RewaXzize = 150;

% Destination rectangles : where and how big the Stim will be on the screen
destrectStim = [Xcenter-StimXsize/2, Ycenter-(StimYsize/2), Xcenter+StimXsize/2, Ycenter+(StimYsize/2)];

stimuliValue = sortrows(stimuliValue,2);

% Create Trials Matrix if not already provided
    if getOrder == 0
        trialMatrix = {};
        for rep = 1 : repeats
            trialMatrix = [trialMatrix; stimuliValue];
            % Shuffle This
            rng('shuffle');
            NN = size(trialMatrix,1);
            trialMatrix = trialMatrix(randperm(NN),:);
        end
        
    elseif getOrder == 1
        trialMatrix = trialOrder;
    end

    % Replace Average Value with actual trial value, from distributions.
    trialMatrix(:,3) = trialMatrix(:,2);
    i1=1; i2=1; i3=1; i4=1; i5=1; i6=1;
    for i = 1 : length(trialMatrix)
         if trialMatrix{i,2} == mean(v1)
             trialMatrix{i,2} = v1(i1);
             i1 = i1 + 1;
             if i1 == length(v1)
                i1 = 1;
             end
        elseif trialMatrix{i,2} == mean(v2)
            trialMatrix{i,2} = v2(i2);
            i2 = i2 + 1;
                if i2 == length(v2)
                    i2 = 1;
                end       
        elseif trialMatrix{i,2} == mean(v3)
             trialMatrix{i,2} = v3(i3);
              i3 = i3 + 1;
                if i3 == length(v3)
                    i3 = 1;
                end
        elseif trialMatrix{i,2} == mean(v4)
             trialMatrix{i,2} = v4(i4);
             i4 = i4 + 1; 
                if i4 == length(v4)
                    i4 = 1;
                end        
        elseif trialMatrix{i,2} == mean(v5)
             trialMatrix{i,2} = v5(i5);
            i5 = i5 + 1;
                if i5 == length(v5)
                    i5 = 1;
                end        
        elseif trialMatrix{i,2} == mean(v6)
             trialMatrix{i,2} = v6(i6);
             i6 = i6 + 1;   
                 if i6 == length(v6)
                    i6 = 1;
                end       
        end  
    end
    
%% Before First Trial, Present all stimuli with their value range.  
margX = 350;
margY = 300;
StimXsize = 400; 
StimYsize = 300;
dest1 = [margX, margY, StimXsize+margX, margY+StimYsize];
dest2 = [StimXsize+margX+20, margY, StimXsize*2+margX+20, margY+StimYsize];
dest3 = [StimXsize*2+margX+40, margY, StimXsize*3+margX+40, margY+StimYsize];
dest4 = [margX, margY+StimYsize+20, StimXsize+margX, margY+StimYsize*2+20];
dest5 = [StimXsize+margX+20, margY+StimYsize+20, StimXsize*2+margX+20, margY+StimYsize*2+20];
dest6 = [StimXsize*2+margX+40, margY+StimYsize+20, StimXsize*3+margX+40, margY+StimYsize*2+20];

stim1 = imread([stimFolder,stimuliValue{1,1}]);
    stim1 = Screen('MakeTexture', window, stim1);    
stim2 = imread([stimFolder,stimuliValue{2,1}]);
    stim2 = Screen('MakeTexture', window, stim2);      
stim3 = imread([stimFolder,stimuliValue{3,1}]);
    stim3 = Screen('MakeTexture', window, stim3);       
stim4 = imread([stimFolder,stimuliValue{4,1}]);
    stim4 = Screen('MakeTexture', window, stim4);        
stim5 = imread([stimFolder,stimuliValue{5,1}]);
    stim5 = Screen('MakeTexture', window, stim5);        
stim6 = imread([stimFolder,stimuliValue{6,1}]);
    stim6 = Screen('MakeTexture', window, stim6);
        
% Text explaining What's happening.

        if strcmp(condition,'Conjunction')
            slide = imread([instructionFolder,'Slide_ConjStudy.jpg']);
            slideTex = Screen('MakeTexture', window, slide);
        elseif strcmp(condition,'SingleAttribute')
            slide = imread([instructionFolder,'Slide_SummStudy.jpg']);
            slideTex = Screen('MakeTexture', window, slide);
        end
        slideSize = size(slide);
        slideDest = [(Xcenter-slideSize(1)), 0 , (Xcenter+slideSize(1)), slideSize(2)];
        
% For countdown stuff
countdown = sort((1:1:countDownTime),'descend');


for i = 1:length(countdown)
    count = num2str(countdown(i));
     Screen('DrawTexture', window, slideTex, [], slideDest, 0);
     Screen('DrawTexture', window, stim5, [], dest5, 0);
     Screen('DrawTexture', window, stim6, [], dest6, 0);
     Screen('DrawTexture', window, stim4, [], dest4, 0);
     Screen('DrawTexture', window, stim3, [], dest3, 0);
     Screen('DrawTexture', window, stim2, [], dest2, 0);
     Screen('DrawTexture', window, stim1, [], dest1, 0);
    % Add value range on top of each Fribble
    Screen('TextSize', window, 22);
    if strcmp(lang,'Hebrew')
        DrawFormattedText(window, ['₪ ',num2str(mean(v1))], 'center',dest1(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest1);
        DrawFormattedText(window, ['₪ ',num2str(mean(v2))], 'center', dest2(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest2);
        DrawFormattedText(window, ['₪ ',num2str(mean(v3))], 'center', dest3(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest3);
        DrawFormattedText(window, ['₪ ',num2str(mean(v4))], 'center', dest4(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest4);
        DrawFormattedText(window, ['₪ ',num2str(mean(v5))], 'center', dest5(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest5);
        DrawFormattedText(window, ['₪ ',num2str(mean(v6))], 'center', dest6(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest6);
    elseif strcmp(lang,'English')
        DrawFormattedText(window, [num2str(mean(v1)),' ₪'], 'center',dest1(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest1);
        DrawFormattedText(window, [num2str(mean(v2)),' ₪'], 'center', dest2(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest2);
        DrawFormattedText(window, [num2str(mean(v3)),' ₪'], 'center', dest3(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest3);
        DrawFormattedText(window, [num2str(mean(v4)),' ₪'], 'center', dest4(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest4);
        DrawFormattedText(window, [num2str(mean(v5)),' ₪'], 'center', dest5(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest5);
        DrawFormattedText(window, [num2str(mean(v6)),' ₪'], 'center', dest6(2) + 0.08 * StimYsize, black,[],[],[],[],[],dest6);
    end
    
    Screen('TextSize', window, 25);
%   DrawFormattedText(window, text, 'center', 65, white);
    DrawFormattedText(window, [count], 'center', 225, [255 0 0]);
    % Flip everything
    Screen('Flip', window);
    % Wait a second before Presenting Next Countdown
    WaitSecs(1);    
end % Countdown loop.

% Short fixation cross to start each Learning block.
Screen('TextSize', window, 30);
DrawFormattedText(window, '+', 'center', 'center', white);
Screen('Flip', window);
WaitSecs(1.5);

%% Trial loop starts Here
  
for tt = 1 : length(trialMatrix)
    
    % Load learning stimulus tfor this trial

    trialStim = imread([stimFolder,trialMatrix{tt,1}]);
    stimulusValue = trialMatrix{tt,2};
    trialStimName = trialMatrix{tt,1};
    
    % Value of Stmiulius in this learning trial
    Outcome = trialMatrix{tt,2};
    stimAveValue = trialMatrix{tt,3};
    
    % MakeTextures
    textureStim = Screen('MakeTexture', window, trialStim);

    %% Rating scale, participant's value estimation
    %[ratingValue, ratingTime, answer, scaleOnsetT] = slideScale_learn(window, question,...
    %    windowRect, anchorTxt, anchorValues, destrectStim, 'aborttime', maxRatingTime,'device','keyboard','image',trialStim); 
    [ratingValue, ratingTime, answer, scaleOnsetT] = slideScale_learn_v2 (window, question, windowRect, anchorTxt, anchorValues, stimulusValue, stimAveValue, ...
                'aborttime',maxRatingTime,'device', 'keyboard', 'scalaPosition', 0.85, 'displayposition', true, 'image', trialStim, 'imagedestrect', destrectStim);


    %% Log data in both .mat and .txt files
    learningBlockData(end+1,:) = {subjectNumber, tt, trialStimName , Outcome, stimAveValue, ratingTime, ratingValue};
    fprintf(fid1, '%s/t%d/t%s/t/t%d/t%d/t%d/t%d/r/n', subjectNumber, tt, trialStimName, Outcome, stimAveValue, ratingTime,ratingValue);
    
    %% Wait for key press Or delay before the next trial
    % KbWait(-1, 2);
    WaitSecs(valueDuration);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    WaitSecs(0.6); %ISI
end
    
%% Save stuff and end function
fclose(fid1);
save (outputFile,'learningBlockData'); %Save the .mat data file for this learning block.
%save(Outputfile,'Results');

WaitSecs(1);
ShowCursor();

end %(end Funtion)