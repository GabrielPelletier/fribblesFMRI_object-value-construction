%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: binary_choice.m
%
%%%%%%%%%%%%%%%%%%%%%%
%  Gabriel Pelletier, May 2016
%
%%%%%%%%%%%%%%%%%%%%%%
%   What this function does:
%       1) Presents 2 images, one on each side of a central fixation cross.
%           - Num of Trials depends on amount on Stim in the StimFolder.
%           - Num of Blocks to be defined.
%       2) Registers a keyboard response for right/left Choice.
%       3) Logs in a Output file the Image files presented, choices and RT.
%
%%%%%%%%%%%%%%%%%%%%%%
%   Other function file this function needs:
%       a) stim_pairs.m
%
%%%%%%%%%%%%%%%%%%%%%%
%   INPUT arguments:
%       1) StimFolder, containing only the desired Images.
%       2) ...Maybe Number of Blocks.
%       3) ...Maybe ISI and max response delay...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function binary_choice (SubjectId, stimFolder, Output)

%=============================OUTPUT=FOLDER===============================%
%%% Creates an Ouptufolder, where the Subject number is essential.
OutputFile = [Output, 'IntegProbe_' SubjectId '.mat'];
fid1=fopen([Output, 'IntegProbe_' SubjectId '.txt'], 'a');
%Header of the .txt OutputFile
fprintf(fid1,'Subject\tTrial\tKeyPressed\tRightPic\tLeftPic\t\tReactionTime\r\n');

%============================STIMULI=FOLDER===============================%
%stimFolder;
stimFormat = '.jpg';

%==========================Preparation/Initiation=========================%
%%% Get screen number
screens = Screen('Screens');
%%% Draw to the external Screen if there is one
screenNumber = max(screens);

%%% Define colors for backgrounds, text and such
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
green = [0 255 0];

%%% The frame Width around the chosen options
penWidth = 10;

%%% Opens a window filled with infinite darkness (the last [] makes the
%   presentation screen smaller (not full screen) so we can still see and 
%   write on the MATLAB window [0 0 1000 580]
[window, windowRect] = PsychImaging ('OpenWindow', screenNumber, black, [0 0 1000 580]);
    
%%% Get the size and center coordinates of the actual Window
[screenXpixels, screenYpixels] = Screen('WindowSize' , window);
[Xcenter, Ycenter] = RectCenter(windowRect); 

%%% Hide cursor (default(); Hide all cursors on every screen)
HideCursor();
ListenChar(2); %Typed characters won't print in the Command window and screw up the script

%=========================Stimuli Pairs Loading===========================%
%Uses the stimPairs.m function file
[stimuli, shufPairs, ImagePairs] = stim_pairs(stimFolder, stimFormat);

%=========================Experimental Parameters=========================%
trialNum = 5; %size(shufPairs,1); %Number of possible pairs with Stimulus Set
%BlocNum = 5;

%==============================Response Keys==============================%
KbName('UnifyKeyNames');
leftChoice = 'u';
rightChoice = 'i';

%==========================Stimulus Presentation==========================%
%%%Get the size of the Image, in this case they are all the same
Ysize = 300;
Xsize = 400;

%We can use the following line to know the size of an image.
%[Ysize, Xsize, colorBitSize] = size(YOUR IMAGE);


for i = 1:trialNum     %One block of trialNum trials
    
%%%The images must be turned into Textures
imageTexture1 = Screen('MakeTexture', window, ImagePairs{i,1});
imageTexture2 = Screen('MakeTexture', window, ImagePairs{i,2});

%%%Destination rectangle (Defining the position and size of the images)
destrect1 = [Xcenter-(Xsize/2)-(screenXpixels/4), Ycenter-Ysize/2, Xcenter+(Xsize/2)-(screenXpixels/4), Ycenter+Ysize/2];
destrect2 = [Xcenter-(Xsize/2)+(screenXpixels/4), Ycenter-Ysize/2, Xcenter+(Xsize/2)+(screenXpixels/4), Ycenter+Ysize/2];

%%%Draw images to screen (not yet Visible).
Screen('DrawTexture', window, imageTexture1, [], destrect1, 0);%the second  bracket is the Destination Rectangle and 0 (last argument) is the rotation angle.
Screen('DrawTexture', window, imageTexture2, [], destrect2, 0);

%Fixation cross
Screen('TextSize', window, 30);
DrawFormattedText(window, '+', 'center', 'center', white);

Screen('Flip', window); %Images are now visible
secs0 = GetSecs; %sets time 0 for RT calculation


%=============================Register Response=====================================%
%===============================Keyboard press======================================%
%%%Has a key press repsonse been made?
noresp = 1;
while noresp
[keyIsDown, secs, firstPress, deltaSecs] = KbCheck;
    if keyIsDown
    keyPressed = KbName(firstPress);
 
    if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
    end
    
%%% Was the key pressed a defined response Key?    
        switch keyPressed
            case leftChoice
                noresp = 0;
            case rightChoice
                noresp = 0;
        end
    end
end

RT = secs - secs0; % RT calculation

%%% Surround the chosen Image with a colored rectangle.
% Keep the Images and + on screen
Screen('DrawTexture', window, imageTexture1, [], destrect1, 0);
Screen('DrawTexture', window, imageTexture2, [], destrect2, 0);
DrawFormattedText(window, '+', 'center', 'center', white);
% Surrounnd chosen image with colord rectangle
    if keyPressed == leftChoice %leftChoice
            Screen('FrameRect', window, green, destrect1, penWidth);
    elseif keyPressed == rightChoice %rightChoice
            Screen('FrameRect', window, green, destrect2, penWidth);    
    end
  Screen('Flip', window);  
%     

%%%Wait for any key press or some ISI
%KbStrokeWait;
WaitSecs(2); %Should be jittered

%%% Output
% Save in .m file
Results.data(i,:)=[str2num('SubjectId') i RT]; % This is the Data
Results.headers = ('sub Trial ReactionTime'); % This is the Header
% Save in .txt file
fprintf(fid1, '%s\t%d\t%s\t\t%s\t%s\t%d\r\n', SubjectId, i, keyPressed,shufPairs{i,1}, shufPairs{i,2}, RT*1000);

end

fclose(fid1);
save(OutputFile,'Results');
    
%%%Clear the screen
ShowCursor();
ListenChar(1); % Enable to write stuff in the Command window
sca;

end
