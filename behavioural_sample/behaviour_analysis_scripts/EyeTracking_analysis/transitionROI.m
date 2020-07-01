%% Gabriel Pelletie, March 2019

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Identify wether each fixation is a transition from one ROI to the other.
% Adds this information (1 or 0) to the eyeData file: eyeData.TrialFix (6th
% row of each fixation column).

%%

function [eyeData, trans_conj, trans_summ] = transitionROI(eyeData, ratingData)

% Find indices for each condition
conjTrials = find(strcmp(ratingData(:,6), 'conj'));
summTrials = find(strcmp(ratingData(:,6), 'summ'));

trans_conj=[];
trans_summ = [];

%% Loop through CONJ trials
for t = conjTrials'
    % Skip if no Fixations detected in this trial and send Warning
    if isempty(eyeData.TrialFix{1,t})
        warning('Trial %d has 0 fixations, this might be indicativ of bad EyeTracking data', t);
        continue
    end
    
    % Loop Through all Fixations of this trial
    for f = 1 : size(eyeData.TrialFix{1,t}, 2) - 1
        % Define whether this is a transition from on ROI to the other
        % (direction is not important) and add this info to the eyeData
        if eyeData.TrialFix{1,t}(5,f) == 1 && eyeData.TrialFix{1,t}(5,f+1) == 2
                eyeData.TrialFix{1,t}(6,f+1) = 1; % Yes, this is a transition
                
        elseif eyeData.TrialFix{1,t}(5,f) == 2 && eyeData.TrialFix{1,t}(5,f+1) == 1
                eyeData.TrialFix{1,t}(6,f+1) = 1; % Yes, this is a transition
                
        else
                eyeData.TrialFix{1,t}(6,f+1) = 0; % This is not a transition
                
        end
        
    end
    
    % If only one fix during this trial, add a Zero as Transition number
        if size(eyeData.TrialFix{1,t}, 2) == 1
            eyeData.TrialFix{1,t}(6, 1) = 0; % Not a transition, only 1 fixation
        end
    
       trans_conj(end+1, 1) = t; % Trial num
       trans_conj(end, 2) = sum(eyeData.TrialFix{1,t}(6,:)); % Number of transitions in this trial
       trans_conj(end, 3) = size(eyeData.TrialFix{1,t}, 2);  % Total number of fixations in this trial
       
end

%% Loop through summ trials
for t = summTrials'
    % Skip if no Fixations detected in this trial and send Warning
    if isempty(eyeData.TrialFix{1,t})
        warning('Trial %d has 0 fixations, this might be indicativ of bad EyeTracking data', t);
        continue
    end
        
    
    % Loop Through all Fixations of this trial
    for f = 1 : size(eyeData.TrialFix{1,t}, 2) - 1
        % Define whether this is a transition from on ROI to the other
        % (direction is not important) and add this info to the eyeData
        if eyeData.TrialFix{1,t}(5,f) == 1 && eyeData.TrialFix{1,t}(5,f+1) == 2
                eyeData.TrialFix{1,t}(6,f+1) = 1; % Yes, this is a transition
                
        elseif eyeData.TrialFix{1,t}(5,f) == 2 && eyeData.TrialFix{1,t}(5,f+1) == 1
                eyeData.TrialFix{1,t}(6,f+1) = 1; % Yes, this is a transition
                
        else
                eyeData.TrialFix{1,t}(6,f+1) = 0; % This is not a transition
                
        end
        
    end
    
    % If only one fix during this trial, add a Zero as Transition number
        if size(eyeData.TrialFix{1,t}, 2) == 1
            eyeData.TrialFix{1,t}(6, 1) = 0; % Not a transition, only 1 fixation
        end
    
       trans_summ(end+1, 1) = t; % Trial num
       trans_summ(end, 2) = sum(eyeData.TrialFix{1,t}(6,:)); % Number of transitions in this trial
       trans_summ(end, 3) = size(eyeData.TrialFix{1,t}, 2);  % Total number of fixations in this trial
   
end




end