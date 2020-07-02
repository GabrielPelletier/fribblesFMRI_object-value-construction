%% Modified by Gabriel Pelletier
% Jan 2018
% While loop and Cath/Try loop to work around some difficulties that
% PTB has with Screen Function some times. If it crashes while trying to
% open PTB Screen, then it will try again a few time. It usually works
% well.

function [w, center] = doScreen
% Opens a full-screen window, sets text properties, and hides the cursor.
% Written by KGS Lab
% Edited by AS 8/2014

keepTrying = 1;
while keepTrying < 10
    try
        % open window and find center
            S = Screen('Screens');
            screen_num = max(S);
            [w, rect] = Screen('OpenWindow', screen_num);
            center = rect(3:4) / 2;

            % set text properties
            Screen('TextFont', w, 'Times');
            Screen('TextSize', w, 35);
            Screen('FillRect', w, 128);

            % hide cursor
            HideCursor;
            
        keepTrying = 10;
    catch
        keepTrying = keepTrying + 1;
        disp(['Open screen Function Crashed for the ', num2str(keepTrying), ' time.']);
    end
    
    if keepTrying == 4
       Screen('Preference', 'SkipSyncTests', 1);
       disp('Sync check was disabled because screen crashed too many time');
    end
    
end

end

