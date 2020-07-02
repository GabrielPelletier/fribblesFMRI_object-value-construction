%% Demo to test the devices used to move the rating scale
% in the MRI

commandwindow;

%% Testing for scanner or not?
scan = 1;

%% How many Repeats of the scale demo ?
rep = 3;

%% Device to 'keyboard' or 'mouse'
% If Scan = 1, keyboard will be the response box buttons
% If Scan == 1, mouse will be the MRI trackball

%device = 'keyboard';
device = 'keyboard';


ListenChar(-1); % So the characters do not print in the command window.


%% Setup Psychtoolbox and Open Window
% The screen function sometimes fail to synchronize and crashes,
% If this happens, we try again without crashing the script.
Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
Screen('Preference', 'SkipSyncTests', 1); % Skip sync test so it works immidiately
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
grey = white/2;
keepTrying = 1;
while keepTrying < 10
    try
        [myScreen, rect] = PsychImaging('OpenWindow', 0, grey);
        HideCursor;
        keepTrying = 10;
    catch
        keepTrying = keepTrying + 1;
        disp(['Open screen Function Crashed for the ', num2str(keepTrying), ' time.']);
        sca;
    end
end

for i = 1:rep
    % Run the demo
    ratingScaleDemo(myScreen, rect, device, scan)
end
sca;

ListenChar(1)
