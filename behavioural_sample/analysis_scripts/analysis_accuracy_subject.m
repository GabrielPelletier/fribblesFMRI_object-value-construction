function [aveRatingsConj, aveRatingsSumm] = analysis_accuracy_subject(data, subjectNumber, bidMainAveRatings, bidMainRawRatings)


% Extract Only Trials that were evaluated
    ratingInd = find(strcmp(data(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = data(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = data(ratingInd(i), 7:9);
    end
    
% Split data by Learning condition (Conjunction and Independent atributes=Summation)
    conjInd = find(strcmp(ratingTrialsData(:,6),'conj'));
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
    
    

    
 %% Plot stuff
    if bidMainAveRatings
        figure % Average Ratings per value level
        %plot(aveRatingsConj(:,1),aveRatingsConj(:,2),'-o');
        err = stdRatingsConj(:,2);
        errorbar(aveRatingsConj(:,1), aveRatingsConj(:,2), err);
        hold on
        %plot(aveRatingsSumm(:,1),aveRatingsSumm(:,2),'-o');
        err = stdRatingsSumm(:,2);
        %hold on
        % Error bars
        errorbar(aveRatingsSumm(:,1), aveRatingsSumm(:,2), err);
        % Plot Visual suff
        line([20,100],[20,100], 'linewidth',1,'color',[0,0,0]);
        xlabel('Instructed value')
        ylabel('Mean ratings')
        axis([20 100 20 100])
        legend('CONJ','SUMM');
        title([num2str(subjectNumber),'  BIDS AVERAGE RATINGS BY VALUE LEVEL']);
    end
    
    if bidMainRawRatings
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