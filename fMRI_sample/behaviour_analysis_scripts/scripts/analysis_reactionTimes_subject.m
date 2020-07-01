function [ave_rt_conj, ave_rt_summ] = analysis_reactionTimes_subject(subjectNumber, data, plot_aveRt, handle1, plot_rtByValue, handle2, figRows, figCols, subPloti)


% Extract Only Trials that were evaluated
    ratingInd = find(strcmp(data(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = data(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = data(ratingInd(i), 7:9);
    end
    
%% Clean RTs
% Deal RTs that are Negative: this was dummy coded so not to miss them.
% Negative RTs mean that the maxium RT was exceeded.
% Find these trials
neg_rt_ind = find(cell2mat(ratingTrialsData(:,8)) < 0 | cell2mat(ratingTrialsData(:,8)) > 3);
%fprintf('The subject number %d exceeded maximum response time in %d trials.\nThese trials were removed from RT analysis.\n', subjectNumber, length(neg_rt_ind));

% % Remove these trials
% ratingTrialsData(neg_rt_ind, :) = [];

% Replace these RT by max RT (3s)
ratingTrialsData(neg_rt_ind, 8) = {3};
    

% Split data by Learning condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp(ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp(ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];

    
% Average RT per value level
    values = unique(conjData(:,1),'sorted');
    
    ave_rt_conj = [];
    aveRatingsSumm = [];
    stdRatingsConj = [];
    stdRatingsSumm = [];
    
    for v = 1:length(values)
        ave_rt_conj(v,1) = values(v);
        ave_rt_conj(v,2) = mean(conjData(conjData(:,1) == values(v),3));
        ave_rt_summ(v,1) = values(v);
        ave_rt_summ(v,2) = mean(summData(summData(:,1) == values(v),3));
        
        ave_std_conj(v,1) = values(v);
        ave_std_conj(v,2) = std(conjData(conjData(:,1) == values(v),3));
        ave_std_summ(v,1) = values(v);
        ave_std_summ(v,2) = std(summData(summData(:,1) == values(v),3));
    end



% Reaction Time analysis
    averRTconj = mean(conjData(:,3));
    averRTsumm = mean(summData(:,3));
 
%% PLot stuff    
    
    if plot_aveRt    
        figure(handle1) % RTs
        subplot(figRows, figCols, subPloti);
        bar([averRTconj, averRTsumm]);
        hold on
        errorbar([1, 2], [averRTconj, averRTsumm], [std(conjData(:,3)), std(summData(:,3))], '.', 'Color', 'k');
        % Plot Visual suff
        xlabel('1.CONJUNCTION     --    2.SUMMATION');
        ylabel('RT (s)');
        title(['sub-0' num2str(subjectNumber)]);
        ylim([0 3]);
    end   
    
    if plot_rtByValue
        figure(handle2)
        subplot(figRows, figCols, subPloti);
        errorbar(ave_rt_conj(:,1), ave_rt_conj(:,2), ave_std_conj(:,2));
        hold on
        errorbar(ave_rt_summ(:,1), ave_rt_summ(:,2), ave_std_summ(:,2));
        % Plot Visual suff
        xlabel('Instructed value level')
        ylabel('RT')
        axis([20 100 1 3])
        title(['sub-' num2str(subjectNumber)]);
    end

end