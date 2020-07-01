% Level 1 analysis script for
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Level-1 analysis : exctracting and averaging variables of interest for
% each run and each participant. The results are loaded in a Table
% containing each run of each participant.
% table name: groupEyeDerivatives

% Gabriel Pelletier
% Last update: August 2019

%%

function [groupEyeDerivatives] = level1_analysis_byValue (subs, which_runs, main_path)

bids_dataPath = [main_path 'fribBids_bidding/'];
train_dataPath = [main_path 'fribBids_training/'];

% Variables to be filled
groupTrans_conj = [];
groupTrans_summ = [];
groupGazeDur_conj = [];
groupGazeDur_summ = [];
groupNumFix_conj = [];
groupNumFix_summ = [];
groupDurFix_conj = [];
groupDurFix_summ = [];
subjectID_col = [];
runsID_col = [];

% Loop through subjects
for s = 1 : length(subs)
    subjectNumber = subs(s);
    subID = ['sub-0' (num2str(subjectNumber))];
    
    if isfile([bids_dataPath subID '/' num2str(subjectNumber) '_eyeData_run1.mat'])
    
        % Loop through runs for this subject
        for r = 1 : length(which_runs)
            run = which_runs(r);

            %% Step 1: Get Behavior & EyeTracking data
            dataFolder = [bids_dataPath subID '/'];
            % Subject information data fro TRAINING phase
            load([train_dataPath subID '/' 'subInfo_' num2str(subjectNumber) '.mat']);
            % Behaviroal rating data
            behavFile = [bids_dataPath subID '/' num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(run) '.mat'];
            load(behavFile);         
            % EyeTracking data
            eyeDataFile = [bids_dataPath subID '/' num2str(subjectNumber) '_eyeData_run' num2str(run) '.mat'];
            load(eyeDataFile);

            % Get rid of Rating Scale "trials", just get the Stimulus
            % presentation trials
            scaleTrials = find(strcmp(ratingData(:,4),'bid'));
            ratingData(scaleTrials, :) = [];
            trialNum = size(ratingData,1);

            % Verify if TrialNumber matches between EyeTracking file and Behavior
            if trialNum ~= size(eyeData.TrialFix,2)
                error('Trial Number does not match between Behavior and EyeTracking Files!')
            end


            %% Step 2: Define ROIs for each condition and attribute
            verifyROI = 0; %Set to 1 if you want to plot the ROIs on top of the images to see if they make sense.
            [conjROI, summROI] = defineROIs(bids_dataPath, subInfo, verifyROI);


            %% Step 3: Identify each fiation to the corresponding ROI
            [eyeData] = classify_fixationROI(eyeData, ratingData, conjROI, summROI);
            % eyeData.TrialFix now has a fifth row, with 1, 2 or 0 depending on if
            % the fixation falls within ROI 1, 2 or None of them.


            %% Step 4: Get the total number of between-ROI transitions by condition
            [eyeData, trans_conj, trans_summ] = transitionROI(eyeData, ratingData);


            %% Step 5: Get the amount of time spent in each ROI by trial, by condition
            %  and calculate the Symmetrical Viewing Time Index
            [gazeDur_conj, gazeDur_summ] = gazeDuration_ROI(eyeData, ratingData);


            %% Step 6: Get the Average Number of Fix/trial and aveage duration of fixations for each condition
            [numFix_conj, numFix_summ, durFix_conj, durFix_summ] = num_dur_Fixations(eyeData, ratingData);   
            

            %% Finally: Average and Load data in matrices that will hold the subject-level means
            % FOR EACH VALUE-LEVEL
            value_levels = unique(trans_conj(:,4)); % Same values for Conj and Summ
            index_row = (s-1)*length(which_runs) + run;
            for v = 1:length(value_levels)
                val = value_levels(v);
                
                groupTrans_conj(index_row, v) = mean(trans_conj((trans_conj(:,4)==val),2));
                groupTrans_summ(index_row, v) = mean(trans_summ((trans_summ(:,4)==val),2));

%                groupGazeDur_conj(index_row, 1) = mean(gazeDur_conj(:,2)); % ROI-1
%                groupGazeDur_conj(index_row, 2) = mean(gazeDur_conj(:,3)); % ROI-2
%                groupGazeDur_conj(index_row, 3) = mean(gazeDur_conj(:,4)); % No ROI
%                groupGazeDur_conj(index_row, 4) = nanmean(gazeDur_conj(:,5)); % Symmetric viewing index

%                groupGazeDur_summ(end+1, 1) = mean(gazeDur_summ(:,2)); % ROI-1
%                groupGazeDur_summ(end, 2) = mean(gazeDur_summ(:,3)); % ROI-2
%                groupGazeDur_summ(end, 3) = mean(gazeDur_summ(:,4)); % No ROI
%                groupGazeDur_summ(end, 4) = nanmean(gazeDur_summ(:,5)); % Symmetric viewing index

                groupNumFix_conj (index_row, v) = mean(numFix_conj((numFix_conj(:,4)==val),2));
                groupNumFix_summ (index_row, v) = mean(numFix_summ((numFix_summ(:,4)==val),2));

                groupDurFix_conj (index_row, v) = mean(durFix_conj((durFix_conj(:,4)==val),2));
                groupDurFix_summ (index_row, v) = mean(durFix_summ((durFix_summ(:,4)==val),2));
            end

            %% Plot individual subject Scatter plot of all fixations with ROIS overlay
            % Always put conjROI first, then summROI (as inputs).
            %fix_scatter_plots (dataPath, subjectNumber, numRuns, conjROI, summROI);

            subjectID_col(end+1) = subjectNumber;
            runsID_col(end+1) = run;
            
        end % Run loop
    
    else fprintf('\n *******  There is no Eye-Tracking data file for sub-0%d\n', subjectNumber);
    end
end % Subject loop

%% Make a table with the Group Data
groupEyeDerivatives = table();
groupEyeDerivatives.Subject_Num = subjectID_col';
groupEyeDerivatives.Run_Num = runsID_col';
groupEyeDerivatives.TransPerTrial_conj_ValueLevels1to6 = groupTrans_conj;
groupEyeDerivatives.TransPerTrial_summ_ValueLevels1to6 = groupTrans_summ;
groupEyeDerivatives.NumFixPerTrial_conj_ValueLevels1to6 = groupNumFix_conj;
groupEyeDerivatives.NumFixPerTrial_summ_ValueLevels1to6 = groupNumFix_summ;
groupEyeDerivatives.AveFixDur_conj_ValueLevels1to6 = groupDurFix_conj;
groupEyeDerivatives.AveFixDur_summ_ValueLevels1to6 = groupDurFix_summ;
%groupEyeDerivatives.Dur_conj_Att1 = groupGazeDur_conj(:,1);
%groupEyeDerivatives.Dur_conj_Att2 = groupGazeDur_conj(:,2);
%groupEyeDerivatives.Dur_conj_NoAtt = groupGazeDur_conj(:,3);
%groupEyeDerivatives.Dur_conj_Symm = groupGazeDur_conj(:,4);
%groupEyeDerivatives.Dur_summ_Att1 = groupGazeDur_summ(:,1);
%groupEyeDerivatives.Dur_summ_Att2 = groupGazeDur_summ(:,2);
%groupEyeDerivatives.Dur_summ_NoAtt = groupGazeDur_summ(:,3);
%groupEyeDerivatives.Dur_summ_Symm = groupGazeDur_summ(:,4);

end


