%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function exclusions = bids_ratingAccuracy_subject (dataPath, subs, accuracyHistogram, averageAccPlot)

%% 
% For ploting purposes
if accuracyHistogram
    figure('Name','Value Rating Accuracy');
end
numSubs = length (subs);
figRows = 2;
if length(subs) == 1
    figRows = 1;
end
figCols = ceil(numSubs/figRows);
subPloti = 1; %  Index for subplot within figure

% Will hold every subject data
summMeanAccuracy = [];
conjMeanAccuracy = [];
summStdAccuracy = [];
conjStdAccuracy = [];

% Will hold the excluded subjects
exclusions = [];

for subjectNumber = subs
    
    %% Organize data
    dataDir = [dataPath '/sub-0' num2str(subjectNumber) '/'];
    runNums = 4;
    
    % Concatenate runs data
    fullSubData = [];
    for r = 1 : runNums
        load([dataDir num2str(subjectNumber) '_fmri_RatingTask_Run' num2str(r) '.mat']);
        fullSubData = [fullSubData;ratingData];
    end

    % Merge stimuli trials with the folowing rating trial
    ratingInd = find(strcmp(fullSubData(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = fullSubData(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = fullSubData(ratingInd(i), 7:9);
    end

    % Split data by Learning condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp(ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp(ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];   
    
    %% Calculate absolute value difference (rating accuracy)
    conjData(:,4) = abs(conjData(:,1)-conjData(:,2));
    summData(:,4) = abs(summData(:,1)-summData(:,2));
    summMeanAccuracy(end+1,1) = mean(summData(:,4));
    conjMeanAccuracy(end+1,1) = mean(conjData(:,4));
    summStdAccuracy(end+1,1) = std(summData(:,4));
    conjStdAccuracy(end+1,1) = std(conjData(:,4));
 
    if accuracyHistogram    
        %% Plot stuff
        subplot(figRows,figCols,subPloti)
        histogram(summData(:,4),'BinWidth',1,'FaceColor','r');
        hold on
        histogram(conjData(:,4),'BinWidth',1,'FaceColor','b');
        xlabel('Rating error (Real value - Trial rating)')
        ylabel('Number of observations')
        axis([0 60 0 30])
        legend('SUMM','CONJ');
        title (num2str(subjectNumber));

        subPloti = subPloti + 1;
    end
   
    if mean(summData(:,4)) > 15 | mean(conjData(:,4)) > 15
        exclusions(end + 1) = subjectNumber;
    end
    
end


%% Load data ad stats in group table
SubjectID = subs';
ratingAcc_group = table(SubjectID, conjMeanAccuracy, summMeanAccuracy, conjStdAccuracy, summStdAccuracy);
save('bidding_ratingAcc_group.mat', 'ratingAcc_group');


%% Plot stuff

if averageAccPlot

    gcf1 = figure('renderer', 'painters', 'Position',[100 100 800 325], ...
                   'Name', 'BID PHASE - AVERAGE RATING ACCURACY');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    % Single Subjects
    a1 = subplot(1,2,1);
    legend_text = {};
    for i = 1:size(ratingAcc_group,1)
    legend_text{end+1} = num2str(ratingAcc_group.SubjectID(i));
    %plot([1,2],ratingAcc_group{i,2:3},'-o');
    line([1,2], ratingAcc_group{i,2:3}, 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(ratingAcc_group(:,2),1)),ratingAcc_group{:,2}, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    scatter(repmat(2,1,size(ratingAcc_group(:,3),1)),ratingAcc_group{:,3}, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
    hold off
    title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average rating error', '(|Instructed value - rating|)',''}); % y-axis label
    ylim ([0, 14]);
    yticks([0, 2, 4, 6, 8, 10, 12, 14]);
    %legend(legend_text);

    
    % Group averages
    a2 = subplot(1,2,2);
    bar(1, mean(ratingAcc_group{:,2}), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(ratingAcc_group{:,3}), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(ratingAcc_group{:,2}), mean(ratingAcc_group{:,3})],[std(ratingAcc_group{:,2}),std(ratingAcc_group{:,3})],' ');
    
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
    % Do Stats (paired sample ttest) to compare condition and display on graph
    [h,p,ci,stats] = ttest(ratingAcc_group{:,2}, ratingAcc_group{:,3});
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
    
   %pos = get(a2, 'position');
    %annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
    %    'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    print(gcf1, '-dtiff', '../figures/figure_accuracy.tiff', '-r600');

end
    
end
