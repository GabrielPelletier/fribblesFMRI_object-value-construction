%% Organize events in 3-columns-vvvectors
% April 10, 2019
%
% for fmri data analysis
% of fribbles_fmri_bids task
%
% The directories where the files are sent are based on BIDS format.
% All the necessary folders and sub-folders are created by the script that
% converts dicom files into nifti. This script should be in the same folder
% as this one: from_dicom_to_bids.m and should be ran before this one.
%

%%  model010
%   This models stimulus presentation accoridng to conditions (Conj and Summ), modulated
%   by value RATING on this trial.
%   Also models the Rating Scale with duration = RT, Unmodulated.
%

% TCVs: 
% cond001.txt = conjunction trials: Onset Of stimulus // Duration of stimulus presentation // 1 (unmodulated)
% cond002.txt = conjunction trials: Onset Of stimulus // Duration of stimulus presentation // RATED value
% cond003.txt = summation trials: Onset Of stimulus // Duration of stimulus presentation // 1 (unmodulated)
% cond004.txt = summation trials: Onset Of stimulus // Duration of stimulus presentation // RATED value
% cond003.txt (Of No Interest) = Rating Scale Conjunction: Onset of scale // duration = Reaction Time // 1 (unmodulated)
% cond006.txt (Of No Interest) = Rating Scale Conjuntion: Onset of scale // duration = Reaction Time // Rated Value
% cond007.txt (Of No Interest) = Rating Scale Summation: Onset of scale // duration = Reaction Time // 1 (unmodulated)
% cond008.txt (Of No Interest) = Rating Scale Summation: Onset of scale // duration = Reaction Time // Rated Value

% ... not updated yet ...

%%

%%  Which subject(s)
subjects =  [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];

runs = [1 2 3 4];

% main dir
rootDir = '/export2/DATA/FRIB_FMRI/fmri_sample';

% Where are the model .tsv (bids format) files?
bidsDir = [rootDir,'/BIDS/'];

% Where are the model TCV files going to be sent?
derivativesDir = [rootDir,'/derivatives/'];

% Model ID Number
modelNUM = '013';

% Mean rt across all trials and all subs
meanRT = 2.402;

%%
for subjectNumber = subjects
    
    subjectFileCode  = ['0',num2str(subjectNumber)];
    
    % Create subfolder for subject (if already exists it will just be
    % skip)
    if ~exist([derivativesDir,'sub-',subjectFileCode],'dir') mkdir([derivativesDir,'sub-',subjectFileCode]); end
    if ~exist([derivativesDir,'sub-',subjectFileCode,'/model'],'dir') mkdir([derivativesDir,'sub-',subjectFileCode,'/model']); end
    if ~exist([derivativesDir,'sub-',subjectFileCode,'/model/model' modelNUM],'dir') mkdir([derivativesDir,'sub-',subjectFileCode,'/model/model' modelNUM]); end
    if ~exist([derivativesDir,'sub-',subjectFileCode,'/model/model' modelNUM '/onsets'],'dir') mkdir([derivativesDir,'sub-',subjectFileCode,'/model/model' modelNUM '/onsets']); end

    for rr = runs
        
        filename = [bidsDir,'sub-',subjectFileCode,'/func/sub-',subjectFileCode,'_task-fribBids_run-0',num2str(rr), '_events.tsv'];
        T = tdfread(filename);
        trial_type = cellstr(T.trial_type); % Format conversion for condition
        
       % The onsets TCV files will land there:
        endFolder = [derivativesDir,'sub-',subjectFileCode,'/model/model' modelNUM '/onsets/task-fribBids_run-0',num2str(rr)];
        mkdir(endFolder);
        
        
       % Conjunction trials, cond001 (unmodulated)
            ind_con = find(strcmp(trial_type, 'conj'));
            M = T.onset(ind_con);
            M(:,2) = 3; % Duration hard set to 3 s
            M(:,3) = 1; % unmodulated
            dlmwrite([endFolder,'/cond001.txt'], M , 'delimiter','\t');
            clear M;
        % Conjunction trials, cond002 (value modulation)
            ind_con = find(strcmp(trial_type, 'conj'));
            meanCenteredRatedValues_con = T.value_rating(ind_con) - mean(T.value_rating(ind_con));
            M = T.onset(ind_con);
            M(:,2) = 3; % DUration hard set to 3 s
            M(:,3) = meanCenteredRatedValues_con;
            dlmwrite([endFolder,'/cond002.txt'], M , 'delimiter','\t');
            clear M;
        
            
       % Summation trials, cond003 (unmodulated)
            ind_sum = find(strcmp(trial_type, 'summ'));
            M = T.onset(ind_sum);
            M(:,2) = 3;
            M(:,3) = 1;
            dlmwrite([endFolder,'/cond003.txt'], M , 'delimiter','\t');
            clear M;
       % Summation trials, cond004 (value modulation)
            ind_sum = find(strcmp(trial_type, 'summ'));
            meanCenteredRatedValues_sum = T.value_rating(ind_sum) - mean(T.value_rating(ind_sum));
            M = T.onset(ind_sum);
            M(:,2) = 3;
            M(:,3) = meanCenteredRatedValues_sum;
            dlmwrite([endFolder,'/cond004.txt'], M , 'delimiter','\t');            
            clear M;
            
            
       % Rating scale Conjunction, cond005 (unmodulated)
            ind_rate_con = ind_con + 1;
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale
            M(:,1) = T.onset(ind_rate_con);
            M(:,2) = meanRT; % Fixed duration = mean RT across all trials and all subs
            M(:,3) = 1; % Unmodulated 
            dlmwrite([endFolder,'/cond005.txt'], M , 'delimiter','\t');  
            clear M;
       % Rating scale, Conjunction: cond006 (modulation by rated value          
            M(:,1) = T.onset(ind_rate_con);
            M(:,2) = meanRT;
            M(:,3) = meanCenteredRatedValues_con;
            dlmwrite([endFolder,'/cond006.txt'], M , 'delimiter','\t');              
            clear M;

       % Rating scale Summation, cond007 (unmodulated)
            ind_rate_sum = ind_sum + 1;
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale          
            M(:,1)= T.onset(ind_rate_sum);
            M(:,2) = meanRT;
            M(:,3) = 1;
            dlmwrite([endFolder,'/cond007.txt'], M , 'delimiter','\t');  
            clear M;
       % Rating scale, Summation: cond008 (modulation by rated value
            M(:,1) = T.onset(ind_rate_sum);
            M(:,2) = meanRT;
            M(:,3) = meanCenteredRatedValues_sum;
            dlmwrite([endFolder,'/cond008.txt'], M , 'delimiter','\t');               
            clear M;
            
       % RT nuisance regressor: cond009, Modelling all Rating scales with duration = meanRT and modulated
            % by the mean-centered Trial RT.
            ind_rate =  find(strcmp(trial_type, 'rating'));
            for i=1:length(T.response_time)
                if T.response_time(i) < 0
                    T.response_time(i) = 3;
                elseif 3 < T.response_time(i) 
                    T.response_time(i) = 3;
                end
            end
            % If all responses were Too Late (so all == 3s) then change the
            % first value to something very close but not equal to 3 so
            % taht the mean centered values are not all equal to 0.
            if all(T.response_time(ind_rate) == 3)
                T.response_time(ind_rate(1)) = T.response_time(ind_rate(1)) - 0.0001;
            end
            meanCenteredRT = T.response_time(ind_rate) - mean(T.response_time(ind_rate));
            M(:,1) = T.onset(ind_rate); % onsets all ratings
            M(:,2) = meanRT; % mean RT across everything
            M(:,3) = meanCenteredRT;
            dlmwrite([endFolder,'/cond009.txt'], M , 'delimiter','\t');
            clear M;
            
        % Accuracy nuisance regressor: cond010, Modelling all STIMULI modulated
        % by the difference abs(TrueValue - RatedValue), mean-centered
        ind_stim = find(strcmp(trial_type, 'summ') | strcmp(trial_type, 'conj'));     
        ratingError = abs(T.value_rating(ind_stim) - T.value_real(ind_stim));
        meanCenteredRatingError = ratingError - mean(ratingError);
        M(:,1) = T.onset(ind_stim);
        M(:,2) = 3;
        M(:,3) = meanCenteredRatingError;
        dlmwrite([endFolder,'/cond010.txt'], M , 'delimiter','\t');
        clear M;
        
        % Accuracy nuisance regressor: cond011, Modelling all RATINGS  modulated
        % by the difference abs(TrueValue - RatedValue), mean-centered     
        ratingError = abs(T.value_rating(ind_rate) - T.value_real(ind_rate));
        meanCenteredRatingError = ratingError - mean(ratingError);
        M(:,1) = T.onset(ind_rate);
        M(:,2) = meanRT;
        M(:,3) = meanCenteredRatingError;
        dlmwrite([endFolder,'/cond011.txt'], M , 'delimiter','\t');
        clear M;        
        
    end
end