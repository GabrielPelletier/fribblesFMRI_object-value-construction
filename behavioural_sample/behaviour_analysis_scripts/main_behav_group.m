%% Group-level Analysis
%
% Gabriel Pelletier,
% April 2018
%
% Last update March 2019
%

%% Where is the Data ?
dataPath = ['../data'];

%% Which-subject(s)

% All
all_subs = [23,24,25,26,27,28,29,30,101,102,103,104,105,106,107,108,109,110,...
         111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,201,...
         202, 203, 204, 205, 206, 207, 208, 209];
     
% Excluding those with poor accuracy
exclusions = [26, 29, 104, 117, 124, 209, 110, 204, 106];

% exlusion because of No EyeTracking Data
% exclusions = [exclusions, 102, 107, 108];

% Remove them
[c,out_ind] = intersect(all_subs, exclusions);
subs = all_subs;
subs(out_ind) = [];


% % sample 2018
%  subs = [23,24,25,26,27,28,29,30,101,102,103,104,105,106,107,108,109,110,...
%            111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,];
% % sample 2019
% subs = [201, 202, 203, 204, 205, 206, 207, 208, 209];


%% What do you want to plot?
plot_learningBlocks_accuracy_rt = 0;
plot_learningProbes_accuracy_rt = 1;

plot_bidding_accuracy = 1;
plot_bidding_reactionTimes = 1;
plot_bidding_RT_by_value = 0;
plot_bidding_groupRegression = 0;

% Custom colors for ploting
    C_color = [255/255 168/255 1/255];
    E_color = [255/255 82/255 82/255]; 

%% Learning phase - rating accuracy by block
numBlocks = 5;

learning_accuByBlock_group = learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocks);
learning_RtByBlock_group = learningAnalysis_meanBlockRT(dataPath, subs, numBlocks);

%[learning_accuByBlock_group, learning_RtByBlock_group] = learningAnalysis_meanBlockAccuracy(dataPath, subs, numBlocksLearn, learningAccuracyMeanBlock);
    
% % Compute Group Average Accuracy
% for b = 1:numBlocks
%     groupAveSumm(b) = mean(learning_accuByBlock_group.learnAccSumm(:,b));
%     groupStdSumm(b) = std(learning_accuByBlock_group.learnAccSumm(:,b));
%     groupAveConj(b) = mean(learning_accuByBlock_group.learnAccConj(:,b));
%     groupStdConj(b) = std(learning_accuByBlock_group.learnAccConj(:,b));
% end

if plot_learningBlocks_accuracy_rt
    
    plot_learning_groupData_byBlock(learning_accuByBlock_group, learning_RtByBlock_group, 1);
    
end

%% Learning probes (accuracy and RT by condition)

% Accuracy and RT
[learningProbe_Acc_Rt_group] = probeAnalysis_meanAccuracy(dataPath, subs, 0, plot_learningProbes_accuracy_rt);



%% Bids task (accuracy and RT by condition)
accuracyHistogram = 0; % Plot data (1) or not (0)
averageAccPlot = 0; % Plot data (1) or not (0)

% ACCURACY
[bids_acc_rt_group, group_accu_byValue] = bids_ratingAccuracy_subject(dataPath, subs, accuracyHistogram, averageAccPlot);

 % Run Reaction time analysis, by value level
 group_rt_by_value = [30; 40; 50; 70; 80; 90];
 for ss = 1:length(subs)
     subjectNumber = subs(ss);
     full_subject_data = [];
     for r = 1 : 4 % 4 runs
         load([dataPath '/' num2str(subjectNumber) '/' num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(r) '.mat']);
         full_subject_data = [full_subject_data;ratingData];
     end
    [sub_rt_by_value] = analysis_reactionTimes_subject(subjectNumber, full_subject_data, 0, 0);
    group_rt_by_value = [group_rt_by_value, sub_rt_by_value(:,2)];
 end
 
if plot_bidding_groupRegression
    regres_GroupLevel(group_accu_byValue, 1);
end

if plot_bidding_accuracy
    % Individual Subjects
    gcf1 = figure('renderer', 'painters', 'Position',[100 100 800 325], ...
                   'Name', 'BID PHASE - AVERAGE RATING ACCURACY');
    
    % Single Subjects
    a1 = subplot(1,2,1);
    legend_text = {};
    for i = 1:size(bids_acc_rt_group,1)
    %plot([1,2],ratingAcc_group{i,2:3},'-o');
    line([1,2], bids_acc_rt_group{i,2:3}, 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(bids_acc_rt_group(:,2),1)),bids_acc_rt_group{:,2}, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(bids_acc_rt_group(:,3),1)),bids_acc_rt_group{:,3}, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    hold off
    title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average rating error', '(|Instructed value - rating|)',''}); % y-axis label
    ylim ([0, 14]);
    yticks([0, 2, 4, 6, 8, 10, 12, 14]);
        
    
    % Group averages
    a2 = subplot(1,2,2);
    bar(1, mean(bids_acc_rt_group{:,2}), 0.8, 'FaceColor', 'w', 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(bids_acc_rt_group{:,3}), 0.8, 'FaceColor', 'w', 'EdgeColor', E_color, 'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(bids_acc_rt_group{:,2}), mean(bids_acc_rt_group{:,3})],[std(bids_acc_rt_group{:,2}),std(bids_acc_rt_group{:,3})],' ');
    
    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    ylim ([0, 14]);
    yticks([0, 2, 4, 6, 8, 10, 12, 14]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',16)
    set(a2,'FontSize',16)
    set(a1,'xtick',[])
    set(a2,'xtick',[])

    box off
    print(gcf1, '-dtiff', 'bidding_accuracy_behaviorSample.tiff', '-r600');
end

if plot_bidding_reactionTimes

      % Individual Subjects
    gcf2 = figure('renderer', 'painters', 'Position',[100 100 800 325], ...
                   'Name', 'BID PHASE - AVERAGE RT');
    
    % Single Subjects
    a1 = subplot(1,2,1);
    legend_text = {};
    for i = 1:size(bids_acc_rt_group,1)
    %plot([1,2],ratingAcc_group{i,2:3},'-o');
    line([1,2], bids_acc_rt_group{i,6:7}, 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(bids_acc_rt_group(:,6),1)),bids_acc_rt_group{:,6}, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(bids_acc_rt_group(:,7),1)),bids_acc_rt_group{:,7}, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    hold off
    title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Reaction time', '(s)',''}); % y-axis label
    ylim ([1, 3]);
    yticks([1, 1.5, 2, 2.5, 3]);
        
    
    % Group averages
    a2 = subplot(1,2,2);
    bar(1, mean(bids_acc_rt_group{:,6}), 0.8, 'FaceColor', 'w', 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(bids_acc_rt_group{:,7}), 0.8, 'FaceColor', 'w', 'EdgeColor', E_color, 'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(bids_acc_rt_group{:,6}), mean(bids_acc_rt_group{:,7})],[std(bids_acc_rt_group{:,6}),std(bids_acc_rt_group{:,7})],' ');
    
    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    ylim ([1, 3]);
    yticks([1, 1.5, 2, 2.5, 3]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',16)
    set(a2,'FontSize',16)
    set(a1,'xtick',[])
    set(a2,'xtick',[])

    box off
    
    % Save high-res image in .tiff format
    print(gcf2, '-dtiff', 'bidding_RT_behaviorSample.tiff', '-r600');  
end

if plot_bidding_RT_by_value    
    % RT by Value plot
    figure
    for i = 1:size(group_rt_by_value, 2)-1
        plot(group_rt_by_value(:, 1), group_rt_by_value(:, i+1));
        hold on
    end
    errorbar(group_rt_by_value(:, 1), mean(group_rt_by_value(:,2:end),2), std(group_rt_by_value(:,2:end),0, 2),'k', 'LineWidth', 3);
    title ('BIDDING PHASE Reaction Times by Value Level');
    xlabel('Value Level'); % x-axis label
    ylabel('Reaction Time (s)'); % y-axis label
    ylim([1.5,3]); 
    
end   

    
fclose all;

%% Stats
% 
% % 1. LEARNING: Paired Sample t-test comparing accuracy on last learning block
% [h1,p1,ci1,stats1] = ttest(learningAcc_group.learnAccConj(:,5), learningAcc_group.learnAccSumm(:,5));
% 
% % 2. LEARNING PROBE (ACCURACY): Paired Sample t-test comparing average accuracy by
% % condition
% [h2,p2,ci2,stats2] = ttest(probe_acc_group.conjMeanAccuracy, probe_acc_group.summMeanAccuracy)
% 
% % 3. BIDDING Phase (ACCURACY): Paired Sample t-test comparing average accuracy by
% % condition
% [h3,p3,ci3,stats3] = ttest(bids_acc_rt_group.conjMeanAccuracy, bids_acc_rt_group.summMeanAccuracy);
% 
% % 4. BIDDING Phase (RT): Paired Sample t-test comparing average RT by
% % condition
% [h4,p4,ci4,stats4] = ttest(bids_acc_rt_group.conjMeanRT, bids_acc_rt_group.summMeanRT);