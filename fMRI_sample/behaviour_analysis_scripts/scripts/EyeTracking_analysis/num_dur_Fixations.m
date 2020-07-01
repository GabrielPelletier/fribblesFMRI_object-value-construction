%% Gabriel Pelletie, March 2019

% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Total time spent fixation in one or the other ROI, extracted by condition

%%
function  [numFix_conj, numFix_summ, durFix_conj, durFix_summ] = num_dur_Fixations(eyeData, ratingData) 

% Find indices for each condition
conjTrials = find(strcmp(ratingData(:,6), 'conj'));
summTrials = find(strcmp(ratingData(:,6), 'summ'));

numFix_conj = [];
numFix_summ = [];
durFix_conj = [];
durFix_summ = [];

%% Loop trough Conj trials
for t = conjTrials'
    
       numFix_conj(end+1, 1) = t;
       numFix_conj(end, 2) = size(eyeData.TrialFix{1,t},2);
       numFix_conj(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial   

    % If no Fixations detected in this trial put NaN as mean fixation durations
    if isempty(eyeData.TrialFix{1,t})
        durFix_conj(end+1 , 1) = t;
        durFix_conj(end, 2) = nan;
        durFix_conj(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial
        continue
    end
       durFix_conj(end+1 , 1) = t;
       durFix_conj(end, 2) = mean(eyeData.TrialFix{1,t}(4,:));
       durFix_conj(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial
end


%% Loop trough Summ trials
for t = summTrials'
    
       numFix_summ(end+1, 1) = t;
       numFix_summ(end, 2) = size(eyeData.TrialFix{1,t},2);
       numFix_summ(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial

    % If no Fixations detected in this trial put NaN as mean fixation durations
    if isempty(eyeData.TrialFix{1,t})
        durFix_summ(end+1 , 1) = t;
        durFix_summ(end, 2) = nan;
        durFix_summ(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial
        continue
    end
       durFix_summ(end+1 , 1) = t;
       durFix_summ(end, 2) = mean(eyeData.TrialFix{1,t}(4,:)); % Average duration of fixations in this trial
       durFix_summ(end, 4) = ratingData{t, 5}; % Value of Stimulus in this trial
end

end