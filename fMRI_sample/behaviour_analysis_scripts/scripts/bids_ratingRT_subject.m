%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% Calculates the rating accuracy for each subject, for each condition.
% Simply takes the absolut difference between the value rating and 
% the real value of the stimlu on each trial.

function bids_ratingRT_subject (dataPath, subs, averageAccPlot)

%% 
% For ploting purposes
numSubs = length (subs);
figRows = 2;
if length(subs) == 1
    figRows = 1;
end
figCols = ceil(numSubs/figRows);
subPloti = 1; %  Index for subplot within figure

% Will hold every subject data
summMeanRT = [];
conjMeanRT = [];
summStdRT = [];
conjStdRT = [];


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
  
    
    %% Clean RTs
    % Deal RTs that are Negative: this was dummy coded so not to miss them.
    % Negative RTs mean that the maxium RT was exceeded.
    neg_rt_ind = find(cell2mat(ratingTrialsData(:,8)) < 0 | cell2mat(ratingTrialsData(:,8)) > 3);
    % Replace these RT by max RT (3s)
    %ratingTrialsData(neg_rt_ind, 8) = {3};
    ratingTrialsData(neg_rt_ind, 8) = {nan}; 
    % Split data by Learning condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp( ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp( ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];     
    
    %% Calculate mean RT
    summMeanRT(end+1,1) = nanmean(summData(:,3));
    conjMeanRT(end+1,1) = nanmean(conjData(:,3));
    summStdRT(end+1,1) = nanstd(summData(:,3));
    conjStdRT(end+1,1) = nanstd(conjData(:,3));
   
end


%% Load data add stats in group table
SubjectID = subs';
ratingRT_group = table(SubjectID, conjMeanRT, summMeanRT, conjStdRT, summStdRT);
save ('bidding_ratingRT_group.mat', 'ratingRT_group');


%% Plot stuff

if averageAccPlot

    gcf1 = figure('renderer', 'painters', 'Position',[100 100 800 325], ...
                   'Name', 'BID PHASE - AVERAGE RATING REACTION TIME');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    % Single Subjects
    a1 = subplot(1,2,1);
    legend_text = {};
    for i = 1:size(ratingRT_group,1)
    legend_text{end+1} = num2str(ratingRT_group.SubjectID(i));
    %plot([1,2],ratingRT_group{i,2:3},'-o');
    line([1,2], ratingRT_group{i,2:3}, 'Color', 'k');
    hold on
    end
    scatter(repmat(1,1,size(ratingRT_group(:,2),1)),ratingRT_group{:,2}, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    scatter(repmat(2,1,size(ratingRT_group(:,3),1)),ratingRT_group{:,3}, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
    hold off
    title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Reaction time', '(s)',''}); % y-axis label
    ylim ([1, 3]);
    yl = ylim; % Get the limit that was set automatically based on the data.
    %legend(legend_text);

    
    % Group averages
    a2 = subplot(1,2,2);
    bar(1, mean(ratingRT_group{:,2}), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color,  'LineWidth', 3); hold on
    bar(2, mean(ratingRT_group{:,3}), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color,  'LineWidth', 3); hold on
    er = errorbar([1,2],[mean(ratingRT_group{:,2}), mean(ratingRT_group{:,3})],[std(ratingRT_group{:,2}),std(ratingRT_group{:,3})],' ');
    
    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    %ylim ([0, 8]);
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
    % Do Stats (paired sample ttest) to compare condition and display on graph
    [h,p,ci,stats] = ttest(ratingRT_group{:,2}, ratingRT_group{:,3});
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
    
    pos = get(a2, 'position');
    %annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
    %    'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    print(gcf1, '-dtiff', '../figures/figure_bidding_meanRt.tiff', '-r600');

end
    
end
