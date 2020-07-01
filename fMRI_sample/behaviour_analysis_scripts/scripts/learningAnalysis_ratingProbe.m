%% 

function learningAnalysis_ratingProbe(dataPath, subs, numBlocks, learningProbeMeanRatings)

%% For ploting purposes

numSubs = length(subs);

if learningProbeMeanRatings
    gci = figure('Name','EXCTINCTION RATING PROBE -- Average Ratings (6 trials/data point)');
end

figRows = 2;
if numSubs == 1
    figRows = 1;
end

figCols = ceil(numSubs/figRows);
subPloti = 1; %  Index for subplot within figure


%% Subject loop
for sub_ind = 1:length(subs)
    
    subjectNumber = subs(sub_ind);

    
    ratingDataConj = cell(1,numBlocks);
    ratingDataSumm = cell(1,numBlocks);
    
    %% load data
    for block = 1: numBlocks
        load([dataPath '/' 'sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_LearningProbeRatingConjunction_' num2str(block) '.mat']);
        ratingDataConj{block} = ratingData;
        load([dataPath '/' 'sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_LearningProbeRatingSingleAttribute_' num2str(block) '.mat']);
        ratingDataSumm{block} = ratingData;
    end

    conjData = {};
    summData = {};

    for i = 1:numBlocks
        conjData = [conjData;ratingDataConj{i}];
        summData = [summData ;ratingDataSumm{i}];
    end

    % Get data in matrices
    % Rating / RT / Real Average Value
        conjData = [cell2mat(conjData(:,6)), cell2mat(conjData(:,7)), cell2mat(conjData(:,12))];
        summData = [cell2mat(summData(:,6)), cell2mat(summData(:,7)), cell2mat(summData(:,12))];

    %% Average Ratings per value level
        values = unique(conjData(:,3),'sorted');

        aveRatingsConj = [];
        aveRatingsSumm = [];
        stdRatingsConj = [];
        stdRatingsSumm = [];

        for v = 1:length(values)

            aveC = mean(conjData((conjData(:,3) == values(v))),1);
            aveS = mean(summData((summData(:,3) == values(v))),1);
            aveRatingsConj(v,1) = values(v);
            aveRatingsConj(v,2) = aveC;
            aveRatingsSumm(v,1) = values(v);
            aveRatingsSumm(v,2) = aveS;

            stdC = std(conjData((conjData(:,3) == values(v))),1);
            stdS = std(summData((summData(:,3) == values(v))),1);
            stdRatingsConj(v,1) = values(v);
            stdRatingsConj(v,2) = stdC;
            stdRatingsSumm(v,1) = values(v);
            stdRatingsSumm(v,2) = stdS;

        end

        if learningProbeMeanRatings

            figure(gci)
            subplot(figRows, figCols, subPloti);
            err = stdRatingsConj(:,2);
            errorbar(aveRatingsConj(:,1), aveRatingsConj(:,2), err);
            hold on
            err = stdRatingsSumm(:,2);
            errorbar(aveRatingsSumm(:,1), aveRatingsSumm(:,2), err);

            title(['sub-0' num2str(subjectNumber)])
            line([20, 100],[20,100], 'linewidth',1,'color',[0,0,0]);
            xlabel('Instructed Average Value')
            ylabel('Mean ratings')
            axis([20 100 20 100])
            legend('CONJUNCTION', 'SUMMATION');

            subPloti = subPloti + 1;
        end
        
end % Sub loop
        
end % end func