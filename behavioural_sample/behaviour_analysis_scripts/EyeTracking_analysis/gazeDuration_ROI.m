%% Gabriel Pelletie, March 2019

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Total time spent fixation in one or the other ROI, extracted by condition

%%
function [gazeDur_conj, gazeDur_summ] = gazeDuration_ROI(eyeData, ratingData)

% Find indices for each condition
conjTrials = find(strcmp(ratingData(:,6), 'conj'));
summTrials = find(strcmp(ratingData(:,6), 'summ'));

gazeDur_conj = [];
gazeDur_summ = [];

%% Loop trough Conj trials
for t = conjTrials'
    % Skip if no Fixations detected in this trial
    if isempty(eyeData.TrialFix{1,t})
        continue
    end
    
       gazeDur_conj(end+1, 1) = t;
       gazeDur_conj(end, 2) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 1)));
       gazeDur_conj(end, 3) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 2)));
       gazeDur_conj(end, 4) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 0)));
end

% Calculate Symmetric Viewing Time Index
gazeDur_conj(:, 5) = 1 - (abs (gazeDur_conj(:,2) - gazeDur_conj(:,3)) ./ (gazeDur_conj(:,2) + gazeDur_conj(:,3))); 

%% Loop trough Summ trials
for t = summTrials'
    % Skip if no Fixations detected in this trial
    if isempty(eyeData.TrialFix{1,t})
        continue
    end
    
       gazeDur_summ(end+1, 1) = t;
       gazeDur_summ(end, 2) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 1)));
       gazeDur_summ(end, 3) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 2)));
       gazeDur_summ(end, 4) = sum(eyeData.TrialFix{1,t}(4, (eyeData.TrialFix{1,t}(5,:) == 0)));
       
end

% Calculate Symmetric Viewing Time Index
gazeDur_summ(:, 5) = 1 - (abs (gazeDur_summ(:,2) - gazeDur_summ(:,3)) ./ (gazeDur_summ(:,2) + gazeDur_summ(:,3))); 

end