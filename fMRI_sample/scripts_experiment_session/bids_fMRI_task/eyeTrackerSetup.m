%%
% Gabriel Pelletier, Feb 2018
%
% This function is for the setup and calibration of the Eye-Tracker
%
%
%
function [edfFileName] = eyeTrackerSetup (myScreen, subjectID)
HideCursor();
   
    Eyelink('Initialize');

    black = BlackIndex(myScreen);
    white = WhiteIndex(myScreen);
    grey = white/2;
    dummymode = 0; 
    
    el=EyelinkInitDefaults(myScreen);
    el.backgroundcolour = grey;
    el.foregroundcolour = white;
    el.msgfontcolour    = white;
    el.imgtitlecolour   = white;
    el.calibrationtargetcolour = el.foregroundcolour;
    EyelinkUpdateDefaults(el);
    
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [~,vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');

    % CALIBRATION of the eye tracker
    EyelinkDoTrackerSetup(el);
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    % get eye that's tracked
    eye_used = Eyelink('EyeAvailable'); 
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end

ShowCursor();
end