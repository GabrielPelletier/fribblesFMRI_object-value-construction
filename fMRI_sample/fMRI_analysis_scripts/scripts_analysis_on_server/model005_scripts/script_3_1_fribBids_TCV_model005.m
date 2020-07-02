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

%%  model005
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
%%

%%  Which subject(s)
subjects = [454];

runs = [1 2 3 4];

% main dir
rootDir = '/export2/DATA/FRIB_FMRI/fmri_sample';

% Where are the model .tsv (bids format) files?
bidsDir = [rootDir,'/BIDS/'];

% Where are the model TCV files going to be sent?
derivativesDir = [rootDir,'/derivatives/'];

% Model ID Number
modelNUM = '005';

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
            M(:,2) = 3; % DUration hard set to 3 s
            M(:,3) = 1; % unmodulated
            dlmwrite([endFolder,'/cond001.txt'], M , 'delimiter','\t');
        % Conjunction trials, cond002 (value modulation)
            ind_con = find(strcmp(trial_type, 'conj'));
            meanCenteredRatedValues_con = T.value_rating(ind_con) - mean(T.value_rating(ind_con));
            M = T.onset(ind_con);
            M(:,2) = 3; % DUration hard set to 3 s
            M(:,3) = meanCenteredRatedValues_con;
            dlmwrite([endFolder,'/cond002.txt'], M , 'delimiter','\t');
            
        
            
       % Summation trials, cond003 (unmodulated)
            ind_sum = find(strcmp(trial_type, 'summ'));
            M = T.onset(ind_sum);
            M(:,2) = 3;
            M(:,3) = 1;
            dlmwrite([endFolder,'/cond003.txt'], M , 'delimiter','\t');
       % Summation trials, cond004 (value modulation)
            ind_sum = find(strcmp(trial_type, 'summ'));
            meanCenteredRatedValues_sum = T.value_rating(ind_sum) - mean(T.value_rating(ind_sum));
            M = T.onset(ind_sum);
            M(:,2) = 3;
            M(:,3) = meanCenteredRatedValues_sum;
            dlmwrite([endFolder,'/cond004.txt'], M , 'delimiter','\t');            
            
            
            
       % Rating scale Conjunction, cond005 (unmodulated)
            ind_rate_con = ind_con + 1;
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale
            for i=1:length(T.response_time)
                if T.response_time(i) < 0
                    T.response_time(i) = 3;
                elseif 3 < T.response_time(i) 
                    T.response_time(i) = 3;
                end
            end            
            M = [T.onset(ind_rate_con), T.response_time(ind_rate_con)];
            M(:,3) = 1;
            dlmwrite([endFolder,'/cond005.txt'], M , 'delimiter','\t');  
       % Rating scale, Conjunction: cond006 (modulation by rated value
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale
            for i=1:length(T.response_time)
                if T.response_time(i) < 0
                    T.response_time(i) = 3;
                elseif 3 < T.response_time(i) 
                    T.response_time(i) = 3;
                end
            end            
            M = [T.onset(ind_rate_con), T.response_time(ind_rate_con), meanCenteredRatedValues_con];
            dlmwrite([endFolder,'/cond006.txt'], M , 'delimiter','\t');              
            

       % Rating scale Summation, cond007 (unmodulated)
            ind_rate_sum = ind_sum + 1;
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale
            for i=1:length(T.response_time)
                if T.response_time(i) < 0
                    T.response_time(i) = 3;
                elseif 3 < T.response_time(i) 
                    T.response_time(i) = 3;
                end
            end            
            M = [T.onset(ind_rate_sum), T.response_time(ind_rate_sum)];
            M(:,3) = 1;
            dlmwrite([endFolder,'/cond007.txt'], M , 'delimiter','\t');  
       % Rating scale, Summation: cond008 (modulation by rated value
            % Negative RT means limit has been reached. So then RT =
            % durations of rating scale
            for i=1:length(T.response_time)
                if T.response_time(i) < 0
                    T.response_time(i) = 3;
                elseif 3 < T.response_time(i) 
                    T.response_time(i) = 3;
                end
            end            
            M = [T.onset(ind_rate_sum), T.response_time(ind_rate_sum), meanCenteredRatedValues_sum];
            dlmwrite([endFolder,'/cond008.txt'], M , 'delimiter','\t');               
            
    end
end