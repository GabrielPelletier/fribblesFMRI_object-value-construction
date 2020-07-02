%% Demo for rating scale used in fribbles_fMRI experiment.


function ratingScaleDemo(window, windowRect, instructionFolder)

slide1 = imread([instructionFolder,'scaleDemo_1.jpg']); % Slider manipulaton + confirmation Instructions    
slide2 = imread([instructionFolder,'scaleDemo_2.jpg']); % Feedback explanation Intructions

Screen('TextFont', window, 'Arial'); % THis font supports Hebrew caracters.
Screen('TextSize', window, 30); % THis font supports Hebrew caracters.
%screenXsize = windowRect(3);
screenYsize = windowRect(4);
[Xcenter, Ycenter] = RectCenter(windowRect);
resizeFactor = 0.8;
slideSize = size(slide1) * resizeFactor;
destrectSlide = [Xcenter-slideSize(2)/2, screenYsize*0.2 , Xcenter+slideSize(2)/2, screenYsize*0.2+(slideSize(1))];

% Show image and scale, Move slider and Confirm
anchorValues = [0 100];
anchorTxt = {'₪0', '₪100'};
question = 'What is the value of this item?';
stimAveValue = 29;
stimulusValue = 29;
maxRatingTime = 10000;
slideScale_demo(window, question, windowRect, anchorTxt, anchorValues, stimulusValue, stimAveValue, ...
                'aborttime', maxRatingTime ,'device', 'keyboard', 'scalaPosition', 0.85, ...
                'displayposition', true, 'image1', slide1, 'image2', slide2, 'imagedestrect', destrectSlide);

KbWait(-1);
end