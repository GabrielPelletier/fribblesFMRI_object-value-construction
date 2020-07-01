%% This is the main script to analyse subject-level data from

% ---- fribbles_fmri_behavioral ---- %

% Gabriel Pelletier, march 2019

% Select the phse of the experiment and the types or graph that you want
% the code to Output by indicating =0 or =1 for the items in the list 
% bellow.

clear

%% Where is the Data ?
dataPath = '/../data';


%% Which-subject(s)
% All 
subs = [23,24,25,26,27,28,29,30,101,102,103,104,105,106,107,108,109,110,...
         111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,201,...
         202, 203, 204, 205, 206, 207, 208, 209];

numBidsRuns = 4;

%% What do you want to plot?

%%% Learning phase
learningPhase = 0; % If this first line is =0 then nothing underneath will be plot.
        learningAccuracyRaw = 1;
        learningRtRaw = 1;
        learningRtMean = 1;
        learningAccuracyMeanBlock = 1;
        
        learningProbeMeanRatings = 1;
        learningProbeMeanAccuracy = 1;
        


%%% Bids phase
bidPhase = 1; % If this first line is =0 then nothing underneath will be plot.
        
        plot_aveRt = 0;
        plot_rtByValue = 0;
        
        bidMainAveRatings = 0;
        bidMainRawRatings = 1;
        
        bidMainRatings = 0;
        bidsMainRawRatings_linReg = 0;
        bidsMainLinReg_CI = 0;
        residualsPlot = 0;
        
        accuracy_histogram = 0;
        average_acc_plot = 0;
        
%%% EyeTracking
eyeTracking = 0;

    % Do we need to extract the data from raw .edf files?
    edfexcraction = 0;
    
    % Scatter plot one per condition per subject, 
    % of all the fixations overlaid on a fribble from the condition.
    all_trials_scatter = 0;

    % Trial-by-trial scanpaths with fixation position, duration and path
    single_trials_plots = 0;
    % which trials?
    trialsToPlot = [10 20 30 90]; % Should plot small number of trials at a time (around 8)

    % Do we plot the cumulative fixation duration heatmap?
    subject_heatmap = 1;
    
%% Codes run here depending on what was selectes up-there.


%% Learning phase


numBlocks = 5; % Number of learning blocks


if learningPhase
    
     for subjectNumber = subs

        learningAnalysis_ratings(dataPath, subjectNumber, numBlocks, learningAccuracyRaw, learningRtRaw, learningRtMean);

        learningAnalysis_ratingProbe(dataPath, subjectNumber, 1, learningProbeMeanRatings);

     end
    
    % plots that take all subs at the same time
    learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocks, learningAccuracyMeanBlock);
    probeAnalysis_meanAccuracy (dataPath, subs, learningProbeMeanAccuracy);
    
end



%%% Bids phase

if bidPhase  == 1
  
    for subjectNumber = subs
        
        % load data
        full_subject_data = [];
        for r = 1 : numBidsRuns
            load([dataPath '/' num2str(subjectNumber) '/' num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(r) '.mat']);
            full_subject_data = [full_subject_data;ratingData];
        end

        analysis_accuracy_subject(full_subject_data, subjectNumber, bidMainAveRatings, bidMainRawRatings);
        [sub_rt_by_value] = analysis_reactionTimes_subject(subjectNumber, full_subject_data, plot_aveRt, plot_rtByValue);
        
    end  
    
    bids_ratingAccuracy_subject(dataPath, subs, accuracy_histogram, average_acc_plot);
    
    regres_SubLevel(dataPath, subs, bidsMainRawRatings_linReg, bidsMainLinReg_CI, residualsPlot);
    
end


%% EyeTracking
numRuns = 4; 

if eyeTracking == 1
    
    addpath([pwd,'/EyeTracking_analysis']);
    
    for subjectNumber = subs
   
        if edfexcraction
            EyeTra_extraction_fribfMRI_behav(dataPath, subjectNumber, numRuns)
        end
    
        if all_trials_scatter == 1
            fix_scatter_plots(dataPath, subjectNumber, numRuns)
        end
        
        if single_trials_plots
        	EyeTra_trialFixations_fribfMRI_behav(dataPath, subjectNumber, numRuns, trialsToPlot)
        end
        
        if subject_heatmap == 1
            DurationHeatmap_subject(dataPath, subjectNumber);
        end
            
    end
    
end

fclose all;