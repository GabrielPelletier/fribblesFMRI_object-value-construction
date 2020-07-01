%% 
function analysis_bids_subject(dataPath, subjectNumber, bidMainAveRt, bidMainAveRatings, bidMainRawRatings)

%subjectNumber = 30;
%dataPath = '';

dataDir = [dataPath,'/',num2str(subjectNumber),'/'];
runNums = 4;

%% Re-arange Data

% load data
    fullSubData = [];
    for r = 1 : runNums
    load([dataDir,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(r),'.mat']);
    fullSubData = [fullSubData;ratingData];
    end
    
% Extract Only Trials that were evaluated
    ratingInd = find(strcmp(fullSubData(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = fullSubData(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = fullSubData(ratingInd(i), 7:9);
    end
    
% Split data by Learning condition (Conjunction and Independent atributes=Summation)
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
% Average RTs
    averRTconj = mean(conjData(:,3));
    averRTsumm = mean(summData(:,3));
    
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
    
    if bidMainAveRt    
        figure % RTs
        bar([averRTconj,averRTsumm]);
        % Plot Visual suff
        xlabel('1.CONJUNCTION     --    2.SUMMATION');
        ylabel('RT (s)');
        title([num2str(subjectNumber),'  BIDS AVERAGE RT']);
    end  
    
end