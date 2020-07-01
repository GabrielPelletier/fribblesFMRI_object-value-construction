% ---- fribbles_fMRI ---- % 
% Gabriel Pelletier, 2019

% This is the main script to analyse Behavioral Data of the Bidding task of
% the experiment (the task inside the MRI).

% It also converts and plots the eye-tracking data to for quick
% visualization.

% Select what graphs you want to plot
% by indicating = 0 or = 1 for the items in the list bellow.


%% Where is the Data ?
dataPath = ['../../behav_eye_data/fribBids_bidding'];


%% Which-subject(s)

% Get all subjects from the data folders
sub_folders = fdir(dataPath);

sub_ind = find(contains(sub_folders(:,1), 'sub-'));
all_subs = sub_folders(sub_ind, 1);
for i = 1:length(all_subs)
    subs(i) = str2num(all_subs{i}(6:8));
end

% Exclusions?
exclusions_behavior = [310 401 404 409 416 424 425 426 427 443 451];
exclusions_mri = [401 404 420 442];
extra = [454];
exclusions = [exclusions_behavior, exclusions_mri, extra];
[c,out_ind] = intersect(subs, exclusions);
subs(out_ind) = [];

fprintf('\nN = %d\n\n', length(subs));

%% Number of runs (usually 4)
numBidsRuns = 4;

%% For plotting purposes
numSubs = length (subs);
figRows = 2; if length(subs) == 1; figRows = 1; end
figCols = ceil(numSubs/figRows);

%% What do you want to plot?

%%% Bids phase
bidPhase = 1; % If this first line is =0 then nothing underneath will be plot.

        bidsPractice = 0;
        rawRatingsPlot = 0;
        linearRegressionPlots = 0;
        
        plot_aveRt = 0;
        plot_rtByValue =0;
        plot_aveRatingByValue = 0;
        plot_rawRatings = 0; % not useful 

        bidsMainRawRatings_linReg = 0; % Raw Ratings AND linear regression fit lines (true value against rated value)
        residualsPlot = 0;
        bidsMainLinReg_CI = 0; % Linear regression fit lines with CI (true value against rated value)

        accuracy_histogram = 0;
        
        average_acc_plot = 1; % Plots all subjects on the same graph, and the group averages
        average_rt_plot = 1;
        plot_groupRegression = 0; % Group-level linear regression with confidence interval.
        
        
%%% EyeTracking
eyeTracking = 0;

    % Do we need to extract the data from raw .edf files?
    edfexcraction = 0;
    
    % Scatter plot one per condition per subject, 
    % of all the fixations overlaid on a fribble from the condition.
    all_trials_scatter = 1;

    % Trial-by-trial scanpaths with fixation position, duration and path
    single_trials_plots = 0;
        % which trials?
        trialsToPlot = [4 5 6 7]; % Should plot small number of trials at a time (around 8)

%% Codes run here depending on what was selectes up-there.

%%% Bids phase
exclusions_StimulusAcc = [];

if bidPhase  == 1
    if plot_aveRt; figHandle1 = figure('Name', 'Average Rating Reaction Times by Condition');
    else; figHandle1 = 0; end
    if plot_rtByValue; figHandle2 = figure('Name', 'Reaction Times by Value-Level');
    else; figHandle2 = 0; end
    if plot_aveRatingByValue; figHandle3 = figure('Name', 'Average Rating by Value-Level');
    else; figHandle3 = 0; end
    subPloti =  1;
    
    
    for s = 1 : length(subs)
        subjectNumber = subs(s);
        
        % load data
        full_subject_data = [];
        for r = 1 : numBidsRuns
            load([dataPath '/' 'sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(r) '.mat']);
            full_subject_data = [full_subject_data;ratingData];
        end

        [excluded, subject_conj, subject_summ] = analysis_accuracy_subject (full_subject_data, subjectNumber, plot_aveRatingByValue, figHandle3, plot_rawRatings, figRows, figCols, subPloti);
        if excluded == 1; exclusions_StimulusAcc(end+1) = subjectNumber; end
        group_data.conj_Acc(:,s) = subject_conj(:,2);
        group_data.summ_Acc(:,s) = subject_summ(:,2);
        
        [subject_conjRt, subject_summRt] = analysis_reactionTimes_subject(subjectNumber, full_subject_data, plot_aveRt, figHandle1, plot_rtByValue, figHandle2, figRows, figCols, subPloti);
        group_data.conj_Rt(:,s) = subject_conjRt(:,2);
        group_data.summ_Rt(:,s) = subject_summRt(:,2);
        
        if plot_aveRt | plot_rtByValue | plot_aveRatingByValue; subPloti = subPloti + 1; end
        
    end
    
   % Subject-level Average accuracy by condition, in a single group-graph
   exclusions_GeneralAcc = bids_ratingAccuracy_subject(dataPath, subs, accuracy_histogram, average_acc_plot);
   
    % Subject-level Average Reaction-time by condition, in a single group-graph
   bids_ratingRT_subject(dataPath, subs, average_rt_plot);
   
   % Single-Subject Linear regression graphs with raw ratings
   regres_SubLevel(dataPath, subs, bidsMainRawRatings_linReg, bidsMainLinReg_CI, residualsPlot);
   
   % Group-level Linear regression graphs with Confidence Interval
   regres_GroupLevel(group_data, plot_groupRegression);
   
end

%%% EyeTracking

if eyeTracking == 1
    
    addpath([pwd,'/EyeTracking_analysis']);
    
    for subjectNumber = subs
        
       %if isfile([dataPath '/sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_run1.edf'])
           %fdir([dataPath '/sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_run*.edf'])
           
            if edfexcraction
                fprintf('\n ***  Now exctracting and converting Eye-Tracking data for sub-0%d\n', subjectNumber);
                EyeTra_extraction_fribfMRI_scan(dataPath, subjectNumber, numBidsRuns)
            end
  
            try eyeTrackingFiles = fdir([dataPath '/sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_eyeData_run*.mat']); catch eyeTrackingFiles = 0; end
            if size(eyeTrackingFiles,1) == 4
                
                if all_trials_scatter
                    fix_scatter_plots(dataPath, subjectNumber, numBidsRuns)
                end

                if single_trials_plots
                    EyeTra_trialFixations_fribfMRI_behav(dataPath, subjectNumber, numBidsRuns, trialsToPlot)
                end
                
            else fprintf('\n *******  There seems to be no, or incomplete, or corrupted Eye-Tracking data files for sub-0%d\n', subjectNumber);
                continue
            end
            
       %end
    end
    
    % Run EyeTracking data QC on all subs
    cutoff_proportion = 0.60; % If less than this proportion of Samples are registered as fixation for a given trial, this trial is flagged as "bad".
    % If too many trials are flagged as Bad, this participants' data should
    % be excluded from eye-tracking analyis altogether.
    QC_summary = data_quality_check(dataPath, subs, numBidsRuns, cutoff_proportion);
    
    
end