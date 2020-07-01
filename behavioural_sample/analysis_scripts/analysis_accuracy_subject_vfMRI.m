function [excluded, aveRatingsConj, aveRatingsSumm] = analysis_accuracy_subject(data, subjectNumber, plot_aveRatingByValue, figHandle, plot_rawRatings, figRows, figCols, subPloti)
excluded = 0;
exclusion_tresh = 15;

% Extract Only Trials that were rated (actually, all of them)
    ratingInd = find(strcmp(data(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = data(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = data(ratingInd(i), 7:9);
    end
    
% Split data by condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp( ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp( ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];

% Average Ratings per value level
    values = unique(conjData(:,1),'sorted');
    
    aveRatingsConj = [];
    aveRatingsSumm = [];
    stdRatingsConj = [];
    stdRatingsSumm = [];
    
    for v = 1:length(values)
        aveC = mean(conjData(conjData(:,1) == values(v),2));
        aveS = mean(summData(summData(:,1) == values(v),2));
        aveRatingsConj(v,1) = values(v);
        aveRatingsConj(v,2) = aveC;
        aveRatingsSumm(v,1) = values(v);
        aveRatingsSumm(v,2) = aveS;
        
        stdC = std(conjData(conjData(:,1) == values(v),2));
        stdS = std(summData(summData(:,1) == values(v),2));
        stdRatingsConj(v,1) = values(v);
        stdRatingsConj(v,2) = stdC;
        stdRatingsSumm(v,1) = values(v);
        stdRatingsSumm(v,2) = stdS;
    end
    
% Calculate the average rating error and find if it exceeds the exclusion
% threshold for any stimulus
rating_err_conj = abs(aveRatingsConj(:,1) - aveRatingsConj(:,2));
rating_err_summ = abs(aveRatingsSumm(:,1) - aveRatingsSumm(:,2));

if any(rating_err_conj > exclusion_tresh)
   excluded = 1; 
end

if any(rating_err_summ > exclusion_tresh)
   excluded = 1; 
end

    
 %% Plot stuff
    if plot_aveRatingByValue
        figure(figHandle) % Average Ratings per value level
        subplot(figRows, figCols, subPloti);
        err = stdRatingsConj(:,2);
        errorbar(aveRatingsConj(:,1), aveRatingsConj(:,2), err);
        hold on
        err = stdRatingsSumm(:,2);
        % Error bars
        errorbar(aveRatingsSumm(:,1), aveRatingsSumm(:,2), err);
        % Plot Visual suff
        line([20,100],[20,100], 'linewidth',1,'color',[0,0,0]);
        xlabel('Instructed value')
        ylabel('Mean ratings')
        axis([20 100 20 100])
        legend('CONJ','SUMM');
        title(['sub-0' num2str(subjectNumber)]);
    end
    
    if plot_rawRatings
        figure % Raw rating data
        scatter(conjData(:,1),conjData(:,2));
        hold on
        scatter(summData(:,1),summData(:,2));
        % Plot Visual suff
        line([20,100],[20,100], 'linewidth',1,'color',[0,0,0]);
        xlabel('Instructed value')
        ylabel('Raw ratings')
        axis([20 100 20 100])
        legend('CONJ','SUMM');
        title([num2str(subjectNumber),'  BIDS RAW RATINGS']);
    end
    
    
end