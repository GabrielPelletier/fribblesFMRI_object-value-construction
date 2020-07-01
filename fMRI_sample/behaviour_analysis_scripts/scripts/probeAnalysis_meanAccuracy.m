%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function probeAnalysis_meanAccuracy (dataPath, subs, plotData, plot_probe_group_data)

matC =[];
matS=[];


% Will hold all subjects data
conjMeanAcc_group = [];
summMeanAcc_group = [];
conjStdAcc_group = [];
summStdAcc_group = [];

conjMeanRt_group = [];
summMeanRt_group = [];
conjStdRt_group = [];
summStdRt_group = [];

for s = 1 : length(subs)
    subjectNumber = subs(s);
    
    %% Organize data
    dataDir = [dataPath '/' 'sub-0' num2str(subjectNumber) '/'];

    % Conjunction

        load([dataDir,num2str(subjectNumber),'_LearningProbeRatingConjunction_1.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAccConj = mean(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        stdAccConj = std(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        meanRtConj = mean(cell2mat(ratingData(:,7)));
        stdRtConj = std(cell2mat(ratingData(:,7)));
        
    % Summation

        load([dataDir,num2str(subjectNumber),'_LearningProbeRatingSingleAttribute_1.mat']);
        % Get the average accuracy by averageing the absolute difference of
        % the rating and the real item value for each trial.
        meanAccSumm = mean(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        stdAccSumm = std(abs(cell2mat(ratingData(:,6)) - cell2mat(ratingData(:,12))));
        meanRtSumm = mean(cell2mat(ratingData(:,7)));
        stdRtSumm = std(cell2mat(ratingData(:,7)));       
        
        matC(end+1,1) =  meanAccConj;
        matC(end,2) =  subjectNumber;   
     	matS(end+1,1) =  meanAccSumm;
        matS(end,2) =  subjectNumber;  
  
        conjMeanAcc_group(end+1,1) = meanAccConj;
        summMeanAcc_group(end+1,1) = meanAccSumm;
        conjStdAcc_group(end+1,1) = stdAccConj;
        summStdAcc_group(end+1,1) = stdAccSumm;
        
        conjMeanRt_group(end+1,1) = meanRtConj;
        summMeanRt_group(end+1,1) = meanRtSumm;
        conjStdRt_group(end+1,1) = stdRtConj;
        summStdRt_group(end+1,1) = stdRtSumm;
        
end

if plotData
    %% Plot stuff
    legend_text = {};
    figure
    for i = 1:length(subs)
        legend_text{end + 1} = num2str(subs(i));
        plot([1,2], [matC(i,1), matS(i,1)], '-o');
    hold on
    end
    
    ylabel('Mean Rating Error (Real value - Trial rating)')
    xlabel('CONJUNCTION (1)   -    SUMMATION (2)')
    %legend();
    title ('Accuracy during Learning Probe');
    xlim([0 3]);
    %xticks([0 1 2 3]);
    legend(legend_text);
        
end 

%% Load and save data in group table
SubjectID = subs';
learningProbe_Acc_group = table(SubjectID, conjMeanAcc_group, summMeanAcc_group, conjStdAcc_group, summStdAcc_group);
%save ('learningProbe_Acc_group.mat', 'learningProbe_Acc_group');
learningProbe_Rt_group = table(SubjectID, conjMeanRt_group, summMeanRt_group, conjStdRt_group, summStdRt_group);
%save ('learningProbe_Rt_group.mat', 'learningProbe_Rt_group');

%% Plot group data
if plot_probe_group_data
    
%% ACCURACY
    gcf1 = figure('renderer', 'painters', 'Position',[100 100 800 800], ...
                   'Name', 'LEARNING PROBE - AVERAGE RATING ACCURACY AND RT');
   
               
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    % Single Subjects
    a1 = subplot(2,2,1);
    legend_text = {};
    for i = 1:size(learningProbe_Acc_group,1)
    %legend_text{end+1} = num2str(ratingAcc_group.SubjectID(i));
    %plot([1,2],ratingAcc_group{i,2:3},'-o');
    line([1,2], [learningProbe_Acc_group.conjMeanAcc_group(i), learningProbe_Acc_group.summMeanAcc_group(i)], 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(learningProbe_Acc_group.conjMeanAcc_group,1)), learningProbe_Acc_group.conjMeanAcc_group(:), 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(learningProbe_Acc_group.summMeanAcc_group,1)),learningProbe_Acc_group.summMeanAcc_group(:), 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'LineWidth', 1.5);
    hold off
    title ('All participants');
    xlim ([0.5 2.5]);
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average rating error', '(|Instructed value - Value ratings|)',''}); % y-axis label
    ylim ([0, 15]);
    yl = ylim; % Get the limit that was set automatically based on the data.
    %legend(legend_text);

    
    % Group averages
    a2 = subplot(2,2,2);
    bar(1, mean(learningProbe_Acc_group.conjMeanAcc_group(:)), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(learningProbe_Acc_group.summMeanAcc_group(:)), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(learningProbe_Acc_group.conjMeanAcc_group(:)), mean(learningProbe_Acc_group.summMeanAcc_group(:))],[std(learningProbe_Acc_group.conjMeanAcc_group(:)),std(learningProbe_Acc_group.summMeanAcc_group(:))],' ');
    
    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
   % ylim ([0, 15]);
    ylim(yl); % Set this graph's axis limit to fit the other graph.
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
   %% RT
   % gcf2 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
   %                'Name', 'LEARNING PROBE - AVERAGE RT');
   
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    % Single Subjects
    a3 = subplot(2,2,3);
    legend_text = {};
    for i = 1:size(learningProbe_Rt_group,1)
    %legend_text{end+1} = num2str(ratingAcc_group.SubjectID(i));
    %plot([1,2],ratingAcc_group{i,2:3},'-o');
    line([1,2], [learningProbe_Rt_group.conjMeanRt_group(i), learningProbe_Rt_group.summMeanRt_group(i)], 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(learningProbe_Rt_group.conjMeanRt_group,1)), learningProbe_Rt_group.conjMeanRt_group(:), 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(learningProbe_Rt_group.summMeanRt_group,1)),learningProbe_Rt_group.summMeanRt_group(:), 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'LineWidth', 1.5);
    hold off
    %title ('All participants');
    xlim ([0.5 2.5]);
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Reaction time', '(s)'}); % y-axis label
    ylim ([1, 7]);
    yl = ylim; % Get the limit that was set automatically based on the data.
    %legend(legend_text);

    
    % Group averages
    a4 = subplot(2,2,4);
    bar(1, mean(learningProbe_Rt_group.conjMeanRt_group(:)), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(learningProbe_Rt_group.summMeanRt_group(:)), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(learningProbe_Rt_group.conjMeanRt_group(:)), mean(learningProbe_Rt_group.summMeanRt_group(:))],[std(learningProbe_Rt_group.conjMeanRt_group(:)),std(learningProbe_Rt_group.summMeanRt_group(:))],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
   % ylim ([0, 15]);
    ylim(yl); % Set this graph's axis limit to fit the other graph.
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',16)
    set(a2,'FontSize',16)
    set(a1,'xtick',[])
    set(a2,'xtick',[])
    set(a3,'FontSize',16)
    set(a4,'FontSize',16)
    set(a3,'xtick',[])
    set(a4,'xtick',[])
    
    box off
     
    
    % Save high-res image in .tiff format
    print(gcf1, '-dtiff', '../figures/learningProbe_accuracy_rt_fMRIsample.tiff', '-r600');

    
end


end