%% Gabriel Pelletie, March 2019

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Classify each fixation within a trial: Identify if the fixation was on
% ROI-1 or ROI-2.

function [eyeData] = classify_fixationROI(eyeData, ratingData, conjROI, summROI)

% Find indices for each condition
conjTrials = find(strcmp(ratingData(:,6), 'conj'));
summTrials = find(strcmp(ratingData(:,6), 'summ'));

%% Loop through CONJ trials
for t = conjTrials'
    
    % Loop Through all Fixations of this trial
    for f = 1 : size(eyeData.TrialFix{1,t}, 2)
        % Add ROI information for this fixation, ROW-5 (ROI-1, ROI-2 or 0
        % if outside both)
        if eyeData.TrialFix{1,t}(2,f) > conjROI{1}(1) && eyeData.TrialFix{1,t}(2,f) < conjROI{1}(3) && ...
           eyeData.TrialFix{1,t}(3,f) > conjROI{1}(2) && eyeData.TrialFix{1,t}(3,f) < conjROI{1}(4)
       
                eyeData.TrialFix{1,t}(5,f) = 1; % Fix falls into ROI-1
                
        elseif eyeData.TrialFix{1,t}(2,f) > conjROI{2}(1) && eyeData.TrialFix{1,t}(2,f) < conjROI{2}(3) && ...
               eyeData.TrialFix{1,t}(3,f) > conjROI{2}(2) && eyeData.TrialFix{1,t}(3,f) < conjROI{2}(4)
       
                eyeData.TrialFix{1,t}(5,f) = 2; % Fix falls into ROI-2
                
        else
                eyeData.TrialFix{1,t}(5,f) = 0; % Fix falls into none of the ROIs
        end
        
    end
    
end

%% Loop through SUMM trials
for t = summTrials'
    
    % Loop Through all Fixations of this trial
    for f = 1 : size(eyeData.TrialFix{1,t}, 2)
        % Add ROI information for this fixation, ROW-5 (ROI-1, ROI-2 or 0
        % if outside both)
        if eyeData.TrialFix{1,t}(2,f) > summROI{1}(1) && eyeData.TrialFix{1,t}(2,f) < summROI{1}(3) && ...
           eyeData.TrialFix{1,t}(3,f) > summROI{1}(2) && eyeData.TrialFix{1,t}(3,f) < summROI{1}(4)
       
                eyeData.TrialFix{1,t}(5,f) = 1; % Fix falls into ROI-1
                
        elseif eyeData.TrialFix{1,t}(2,f) > summROI{2}(1) && eyeData.TrialFix{1,t}(2,f) < summROI{2}(3) && ...
               eyeData.TrialFix{1,t}(3,f) > summROI{2}(2) && eyeData.TrialFix{1,t}(3,f) < summROI{2}(4)
       
                eyeData.TrialFix{1,t}(5,f) = 2; % Fix falls into ROI-2
                
        else
                eyeData.TrialFix{1,t}(5,f) = 0; % Fix falls into none of the ROIs
        end
        
    end
    
end


end