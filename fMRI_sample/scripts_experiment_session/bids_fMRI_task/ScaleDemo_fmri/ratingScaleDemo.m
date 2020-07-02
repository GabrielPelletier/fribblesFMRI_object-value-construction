%% Demo for rating scale used in fribbles_fMRI experiment.



function ratingScaleDemo(window, windowRect, device, scan)
Screen('TextFont', window, 'Arial'); % THis font supports Hebrew caracters.
Screen('TextSize', window, 30); % THis font supports Hebrew caracters.
%screenXsize = windowRect(3);
screenYsize = windowRect(4);
[Xcenter, Ycenter] = RectCenter(windowRect);
% Show image and scale, Move slider and Confirm
anchorValues = [20 100];
anchorTxt = {'20', '100'};
question = 'What is the value of this item?';
stimAveValue = 29;
stimulusValue = 29;
maxRatingTime = 10000;
slideScale_demo_mri(window, question, windowRect, anchorTxt, anchorValues, stimulusValue, stimAveValue, ...
                'aborttime', maxRatingTime ,'device', device, 'displayposition', true, 'scan',scan);

end