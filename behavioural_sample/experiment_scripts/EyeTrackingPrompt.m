function [eyeTracking] = EyeTrackingPrompt


eyeTracking = questdlg('Will we use Eye-Tracking?:','eyeTracking','Yes','No','Yes');

    while isempty(eyeTracking)
        eyeTracking = questdlg('Will we use Eye-Tracking?:','eyeTracking','Yes','No','Yes');
    end

    if strcmp(eyeTracking,'Yes')
        eyeTracking = 1;
    elseif strcmp(eyeTracking,'No')
        eyeTracking = 0;
    end

end