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

    % Skip if no Fixations detected in this trial
    if isempty(eyeData.TrialFix{1,t})
        continue
    end
       durFix_conj(end+1 , 1) = t;
       durFix_conj(end, 2) = mean(eyeData.TrialFix{1,t}(4,:));
end


%% Loop trough Summ trials
for t = summTrials'
    
       numFix_summ(end+1, 1) = t;
       numFix_summ(end, 2) = size(eyeData.TrialFix{1,t},2);  

    % Skip if no Fixations detected in this trial
    if isempty(eyeData.TrialFix{1,t})
        continue
    end
       durFix_summ(end+1 , 1) = t;
       durFix_summ(end, 2) = mean(eyeData.TrialFix{1,t}(4,:));
end

end