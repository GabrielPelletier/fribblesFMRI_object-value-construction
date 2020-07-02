function [position, RT, answer, t0] = slideScale_demo(screenPointer, question, rect, endPoints, anchorValues, stimulusValue, stimAveValue, varargin)
%SLIDESCALE This funtion draws a slide scale on a PSYCHTOOLOX 3 screen and returns the
% position of the slider spaced between -100 and 100 as well as the raection time and if an answer was given.
%
%   Usage: [position, secs] = slideScale(ScreenPointer, question, center, rect, endPoints, varargin)
%   Mandatory input:
%    ScreenPointer  -> Pointer to the window.
%    question       -> Text string containing the question.
%    rect           -> Double contatining the screen size.
%                      Obtained with [myScreen, rect] = Screen('OpenWindow', 0);
%    endPoints      -> Cell containg the two text string of the left and right
%                      end of the scala. Exampe: endPoints = {'left, 'right'};
%
%   Varargin:
%    'linelength'     -> An integer specifying the lengths of the ticks in
%                        pixels. The default is 10.
%    'width'          -> An integer specifying the width of the scala line in
%                        pixels. The default is 3.
%    'startposition'  -> Choose 'right', 'left' or 'center' start position.
%                        Default is center.
%    'scalalength'    -> Double value between 0 and 1 for the length of the
%                        scale. The default is 0.9.
%    'scalaposition'  -> Double value between 0 and 1 for the position of the
%                        scale. 0 is top and 1 is bottom. Default is 0.8.
%    'device'         -> A string specifying the response device. Either 'mouse' 
%                        or 'keyboard'. The default is 'mouse'.
%    'responsekey'    -> String containing name of the key from the keyboard to log the
%                        response. The default is 'return'.
%    'slidecolor'     -> Vector for the color value of the slider [r g b] 
%                        from 0 to 255. The dedult is red [255 0 0].
%    'scalacolor'     -> Vector for the color value of the scale [r g b] 
%                         from 0 to 255.The dedult is black [0 0 0].
%    'aborttime'      -> Double specifying the time in seconds after which
%                        the function should be aborted. In this case no
%                        answer is saved. The default is 8 secs.
%    'image'          -> An image saved in a uint8 matrix. Use
%                        imread('image.png') to load an image file.
%    'imageRect'      -> Specify the position and size of the image.
%                        
%    'displayposition' -> If true, the position of the slider is displayed. 
%                        The default is false. 
%
%   Output:
%    'position'      -> Deviation from zero in percentage, 
%                       with -100 <= position <= 100 to indicate left-sided
%                       and right-sided deviation.
%    'RT'            -> Reaction time in milliseconds.
%    'answer'        -> If 0, no answer has been given. Otherwise this
%                       variable is 1.
%
%   Author: Joern Alexander Quent
%   e-mail: alexander.quent@rub.de
%   Version history:
%                    1.0 - 4. January 2016 - First draft
%                    1.1 - 18. Feburary 2016 - Added abort time and option to
%                    choose between mouse and key board
%                    1.2 - 5. October 2016 - End points will be aligned to end
%                    ticks
%                    1.3 - 06/01/2017 - Added the possibility to display an
%                    image
%                    1.4 - 5. May 2017 - Added the possibility to choose a
%                    start position
%                    1.5 - 7. November 2017 - Added the possibility to display
%                    the position of the slider under the scale.
%                    1.6 - 27. November 2017 - The function now waits until
%                    all keys are released before exiting. 
%                    1.7 - 28. November 2017 - More than one screen
%                    supported now.
%                    1.8 - 29. November 2017 - Fixed issue that mouse is
%                    not properly in windowed mode.

%% Parse input arguments
% Default values
center        = round([rect(3) rect(4)]/2);
lineLength    = 15;
width         = 3;
scalaLength   = 0.7;
scalaPosition = 0.6;
sliderColor   = [255 0 0];
scaleColor    = [255 255 255]; %[0 0 0];
textColor     = [255 255 255]; %[0 0 0];
device        = 'mouse';
aborttime     = 8;
responseKey   = KbName('return');
GetMouseIndices;
drawImage     = 0;
startPosition = 'center';
displayPos    = false;
sliderSpeed = 5; % Only in use if devide = keyboard and use arrowKeys to slide

% Set keys.
    KbName('UnifyKeyNames');
    responseKey = KbName('DownArrow');
    rightKey = KbName('RightArrow');
    leftKey = KbName('LeftArrow');
    escapeKey = KbName('ESCAPE');

i = 1;
while(i<=length(varargin))
    switch lower(varargin{i})
        case 'linelength'
            i             = i + 1;
            lineLength    = varargin{i};
            i             = i + 1;
        case 'width'
            i             = i + 1;
            width         = varargin{i};
            i             = i + 1;
        case 'startposition'
            i             = i + 1;
            startPosition = varargin{i};
            i             = i + 1;
        case 'scalalength'
            i             = i + 1;
            scalaLength   = varargin{i};
            i             = i + 1;
        case 'scalaposition'
            i             = i + 1;
            scalaPosition = varargin{i};
            i             = i + 1;
        case 'device' 
            i             = i + 1;
            device = varargin{i};
            i             = i + 1;
        case 'responsekey'
            i             = i + 1;
            responseKey   = KbName(varargin{i});
            i             = i + 1;
        case 'slidecolor'
            i             = i + 1;
            sliderColor    = varargin{i};
            i             = i + 1;
        case 'scalacolor'
            i             = i + 1;
            scaleColor    = varargin{i};
            i             = i + 1;
        case 'aborttime'
            i             = i + 1;
            aborttime     = varargin{i};
            i             = i + 1;
        case 'image1'
            i             = i + 1;
            image1         = varargin{i};
            i             = i + 1;
            stimuli1       = Screen('MakeTexture', screenPointer, image1);
            drawImage     = 1;
        case 'image2'
            i             = i + 1;
            image2         = varargin{i};
            i             = i + 1;
            stimuli2       = Screen('MakeTexture', screenPointer, image2);
            drawImage     = 1;    
        case 'displayposition'
            i             = i + 1;
            displayPos    = varargin{i};
            i             = i + 1;
        case 'imagedestrect'
            i             = i + 1;
            imageRect    = varargin{i};
            i             = i + 1;
    end
end

% Sets the default key depending on choosen device
if strcmp(device, 'mouse')
    responseKey   = 1; % X mouse button
end

%% Checking number of screens and parsing size of the global screen
screens       = Screen('Screens');
if length(screens) > 1 % Checks for the number of screens
    screenNum        = 1;
else
    screenNum        = 0;
end
globalRect          = Screen('Rect', screenNum);

%% Coordinates of scale lines and text bounds
if strcmp(startPosition, 'right')
    x = globalRect(3)*scalaLength;
elseif strcmp(startPosition, 'center')
    x = globalRect(3)/2;
elseif strcmp(startPosition, 'left')
    x = globalRect(3)*(1-scalaLength);
else
    error('Only right, center and left are possible start positions');
end
SetMouse(round(x), round(rect(4)*scalaPosition), screenPointer, 1);
midTick    = [center(1) rect(4)*scalaPosition - lineLength - 5 center(1) rect(4)*scalaPosition  + lineLength + 5];
leftTick   = [rect(3)*(1-scalaLength) rect(4)*scalaPosition - lineLength rect(3)*(1-scalaLength) rect(4)*scalaPosition  + lineLength];
rightTick  = [rect(3)*scalaLength rect(4)*scalaPosition - lineLength rect(3)*scalaLength rect(4)*scalaPosition  + lineLength];
horzLine   = [rect(3)*scalaLength rect(4)*scalaPosition rect(3)*(1-scalaLength) rect(4)*scalaPosition];
textBounds = [Screen('TextBounds', screenPointer, endPoints{1}); Screen('TextBounds', screenPointer, endPoints{2})];
% if drawImage == 1
%     rectImage  = [center(1) - imageSize(2)/2 rect(4)*(scalaPosition - 0.2) - imageSize(1) center(1) + imageSize(2)/2 rect(4)*(scalaPosition - 0.2)];
%     if rect(4)*(scalaPosition - 0.2) - imageSize(1) < 0
%         error('The height of the image is too large. Either lower your scale or use the smaller image.');
%     end
% end

% Calculate the range of the scale, which will be need to calculate the
% position
scaleRange        = round(rect(3)*(1-scalaLength)):round(rect(3)*scalaLength); % Calculates the range of the scale
scaleRangeShifted = round((scaleRange)-mean(scaleRange));                      % Shift the range of scale so it is symmetrical around zero

%% Loop for scale loop
t0                         = GetSecs;
answer                     = 0;
while answer == 0
    
if strcmp(device, 'mouse')    
%%%%%%%%%%%%%%% MOUSE CURSOR MOVING THE SCALE %%%%%%%%%%%%%%%%%%%
    [x,y,buttons,focus,valuators,valinfo] = GetMouse(screenPointer, 1);
    if x > rect(3)*scalaLength
        x = rect(3)*scalaLength;
    elseif x < rect(3)*(1-scalaLength)
        x = rect(3)*(1-scalaLength);
    end
elseif strcmp(device, 'keyboard')    
%%%%%%%%%%%%%%% KEYBORAD ARROWS MOVING THE SCALE %%%%%%%%%%%%%%%%%% 
    [keyIsDown, seconds, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(rightKey)
                    x = x + sliderSpeed;
            elseif keyCode(leftKey)                
                    x = x - sliderSpeed;       
            elseif keyCode(escapeKey)
                break;
            end
        end
        
        if x > rect(3)*scalaLength
        x = rect(3)*scalaLength;
         elseif x < rect(3)*(1-scalaLength)
        x = rect(3)*(1-scalaLength);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  
    % Draw image if provided
    if drawImage == 1
         Screen('DrawTexture', screenPointer, stimuli1,[] , imageRect, 0);
    end
    
    % Drawing the question as text
    %DrawFormattedText(screenPointer, question, 'center', rect(4)*(scalaPosition - 0.1),textColor); 
    [nx,ny,textbounds] = DrawFormattedText(screenPointer, question, 'center', imageRect(4) + 24,textColor);
    
    % Drawing the end points of the scala as text
    DrawFormattedText(screenPointer, endPoints{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
    DrawFormattedText(screenPointer, endPoints{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
    
    % Drawing the scala
    Screen('DrawLine', screenPointer, scaleColor, midTick(1), midTick(2), midTick(3), midTick(4), width);         % Mid tick
    Screen('DrawLine', screenPointer, scaleColor, leftTick(1), leftTick(2), leftTick(3), leftTick(4), width);     % Left tick
    Screen('DrawLine', screenPointer, scaleColor, rightTick(1), rightTick(2), rightTick(3), rightTick(4), width); % Right tick
    Screen('DrawLine', screenPointer, scaleColor, horzLine(1), horzLine(2), horzLine(3), horzLine(4), width);     % Horizontal line
    
    % The slider
    Screen('DrawLine', screenPointer, sliderColor, x, rect(4)*scalaPosition - lineLength, x, rect(4)*scalaPosition  + lineLength, width);
    
    % Caculates position

    %position          = round((x)-mean(scaleRange));           % Shift the x value according to the new scale
    %position          = (position/max(scaleRangeShifted))*100; % Converts the value to percentage
    
    % Modified By G. Pelletier
    maxScaleValue = anchorValues(2);
    minScaleValue = anchorValues(1);
    position          = round((x) - scaleRange(1)); % Position (in Pixels) from Start of Scale
    position          = (position*(maxScaleValue-minScaleValue))/(scaleRange(end)-scaleRange(1))+minScaleValue; % Converts number on Maxium Scale Value
    
    
    % Display position
    bounds = Screen('TextBounds', screenPointer, num2str(round(position)));
    %Screen('FrameRect', screenPointer, [125 125 125], [x-(bounds(1,3)/2),rect(4)*(scalaPosition + 0.02)-(bounds(1,2)/2),x+(bounds(1,3)/2),rect(4)*(scalaPosition + 0.02)+(bounds(1,4))], 1)
    if displayPos
        DrawFormattedText(screenPointer, num2str(round(position)), x-(bounds(1,3)/2), rect(4)*(scalaPosition + 0.05), [125 125 125]);
        %DrawFormattedText(screenPointer, num2str(round(position)), rectImage(3)-(imageSize(2)/2)-20, rect(4)*(scalaPosition + 0.05)); 
    end

    % Flip screen
   scaleOnsetTime = Screen('Flip', screenPointer);
 
    % Check if answer has been given
    if strcmp(device, 'mouse')
        secs = GetSecs;
        if buttons(responseKey) == 1
            answer = 1;
        end
    elseif strcmp(device, 'keyboard')
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(responseKey) == 1
            answer = 1;
        end
    else
        error('Unknown device');
    end
    
    % Abort if answer takes too long
    if secs - t0 > aborttime
%         DrawFormattedText(screenPointer, 'Please respond faster', 'center', 'center', [255 255 255]);
%         Screen('Flip', screenPointer);
%         WaitSecs(0.7);
        break
    end

end

%% Wating that all keys are released
KbReleaseWait();

%% Calculating the reaction time and the position
RT = (secs - t0) * 1000;% converting RT to millisecond


%% Present Feedback (Real Trial Value)
feedbackPos1 = ((stimulusValue - minScaleValue) * (scaleRange(end) - scaleRange(1))) / (maxScaleValue-minScaleValue);
feedbackPos = feedbackPos1 + scaleRange(1);
% FeedBack Slider
Screen('DrawLine', screenPointer, [255 255 51], feedbackPos, rect(4)*scalaPosition - lineLength, feedbackPos, rect(4)*scalaPosition  + lineLength, width);
% FeedBack Value Text
bounds1 = Screen('TextBounds', screenPointer, num2str(stimulusValue));
if displayPos
        DrawFormattedText(screenPointer, ['₪ ',num2str(round(stimulusValue))], feedbackPos -(bounds1(1,3)/2), rect(4)*(scalaPosition) - 50, [255 255 51]);
end

% And re-draw everything else
 % Draw image if provided
    if drawImage == 1
         Screen('DrawTexture', screenPointer, stimuli2,[] , imageRect, 0);
    end
    
    % Drawing the question as text
    DrawFormattedText(screenPointer, question, 'center', imageRect(4) + 24, textColor); 
    
    % Drawing the end points of the scala as text
    DrawFormattedText(screenPointer, endPoints{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
    DrawFormattedText(screenPointer, endPoints{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
    
    % Drawing the scala
    Screen('DrawLine', screenPointer, scaleColor, midTick(1), midTick(2), midTick(3), midTick(4), width);         % Mid tick
    Screen('DrawLine', screenPointer, scaleColor, leftTick(1), leftTick(2), leftTick(3), leftTick(4), width);     % Left tick
    Screen('DrawLine', screenPointer, scaleColor, rightTick(1), rightTick(2), rightTick(3), rightTick(4), width); % Right tick
    Screen('DrawLine', screenPointer, scaleColor, horzLine(1), horzLine(2), horzLine(3), horzLine(4), width);     % Horizontal line
    % Display position
    if displayPos
        DrawFormattedText(screenPointer, num2str(round(position)), x-(bounds(1,3)/2), rect(4)*(scalaPosition + 0.05), [125 125 125]);
        %DrawFormattedText(screenPointer, num2str(round(position)), rectImage(3)-(imageSize(2)/2)-20, rect(4)*(scalaPosition + 0.05)); 
    end
    % The slider
    Screen('DrawLine', screenPointer, sliderColor, x, rect(4)*scalaPosition - lineLength, x, rect(4)*scalaPosition  + lineLength, width);
  
    if (abs(position - stimAveValue) < 3)
       DrawFormattedText(screenPointer, 'GOOD !', 'center', rect(4)*0.92, [0 125 0]);
    end
    
FBOnsetTime = Screen('Flip', screenPointer);
WaitSecs(1);

end