%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: instruction_display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=                          Gabriel Pelletier                            =%
%=                  --- Last update : June 9, 2016 ---                   =%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function displays images in the center on the screen.
% It was made to display instructions for an experiment.
% The instructions were written on PowerPoint and each
% slide were saved individually as .jpg 
% 
% The function takes as many Slides as you want. It will present one slide
% and wait for a keyboard press, then present another until there is no
% more arguments in the function.
%
% The slides must be in the folder defined by instructionFolder
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function instruction_display (window, windowRect, instructionFolder, varargin)
%PsychDefaultSetup(2); 
%Screen('Preference','SkipSyncTests', 1);

% Change this if you want to make the instructions bigger or smaller.
scaler = 0.9;

% Get the size of the on screen window
screenXpixels = windowRect(3);
screenYpixels = windowRect(4);
%[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Hide cursor (default(); Hide all cursors on every screen)
HideCursor();

%%% Load and present slide images
    for i = 1:length(varargin)
        Slide = imread([instructionFolder, varargin{i}, '.jpg']);
        slideTexture = Screen('MakeTexture', window, Slide);
        
        % Get Image Size and Ratio
        [s1, s2, s3] = size(Slide);
        aspectRatio = s2 / s1;
        
        % Rescale the Image
        heightScaler = scaler;
        imageHeight = screenYpixels .* heightScaler;
        imageWidth = imageHeight .* aspectRatio;
        theRect = [0 0 imageWidth imageHeight];
        destRect = CenterRectOnPointd(theRect, screenXpixels / 2,...
        screenYpixels / 2);
        
        % Present image
        Screen('DrawTexture', window, slideTexture, [], destRect); 
        Screen('Flip', window);

        WaitSecs(2);
        
        resp = 0;
        while resp == 0
            KbWait(-1, 2);
            [keyIsDown,secs,keycode] = KbCheck;
            if keyIsDown
                resp = 1;
            end
        end

    end
    
end %end of function

