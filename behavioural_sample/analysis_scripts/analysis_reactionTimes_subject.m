function [sub_rt_by_value] = analysis_reactionTimes_subject(subjectNumber, data, plot_aveRt, plot_rtByValue)


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
neg_rt_ind = find(cell2mat(ratingTrialsData(:,8)) < 0);
fprintf('The subject number %d exceeded maximum response time in %d trials.\nThese trials were removed from RT analysis.\n', subjectNumber, length(neg_rt_ind));
% Remove these trials
ratingTrialsData(neg_rt_ind,:) = [];
    

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
        figure % RTs
        bar([averRTconj,averRTsumm]);
        % Plot Visual suff
        xlabel('1.CONJUNCTION     --    2.SUMMATION');
        ylabel('RT (s)');
        title([num2str(subjectNumber),'  BIDS AVERAGE RT']);
    end   
    
    if plot_rtByValue
        figure % RTs
        errorbar(ave_rt_conj(:,1), ave_rt_conj(:,2), ave_std_conj(:,2));
        hold on
        errorbar(ave_rt_summ(:,1), ave_rt_summ(:,2), ave_std_summ(:,2));
        % Plot Visual suff
        xlabel('Instructed value level')
        ylabel('RT')
        axis([20 100 1 3])
        title(['sub-' num2str(subjectNumber),'  BIDS ReactionTimes by VALUE']);
    end

    
    % ALL RT by value levels regardless of condition (output of function)
    sub_rt_by_value = [];
    ratingData = [cell2mat(ratingTrialsData(:,5)),cell2mat(ratingTrialsData(:,7)),cell2mat(ratingTrialsData(:,8))];
    for v = 1:length(values)
        sub_rt_by_value(v,1) = values(v);
        sub_rt_by_value(v,2) = mean(ratingData(ratingData(:,1) == values(v),3));
    end
end