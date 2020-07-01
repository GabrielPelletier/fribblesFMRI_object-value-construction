%% learningAnalysis_ratings

function learningAnalysis_ratings(dataPath, subjectNumber, numBlocks, learningRatingsRaw, learningRtRaw, learningRtMean)

%% Load and format learning (Rating) data per condition

learnDataConj = cell(1,numBlocks);
learnDataSumm = cell(1,numBlocks);

for block = 1: numBlocks
    load([dataPath,'/',num2str(subjectNumber),'/',num2str(subjectNumber),'_Learning_Conjunction_',num2str(block),'.mat']);
    learnDataConj{block} = learningBlockData;
    lengthBlock = length(learningBlockData);
     load([dataPath,'/',num2str(subjectNumber),'/',num2str(subjectNumber),'_Learning_SingleAttribute_',num2str(block),'.mat']);
     learnDataSumm{block} = learningBlockData;
end 

conjData = {};
summData = {};
for i = 1:numBlocks
conjData = [conjData;learnDataConj{i}];
summData = [summData ;learnDataSumm{i}];
end

% Convert relevant cells into Matrices
% Rating = col5, RT = col4, Real Ave Value = col3
conjDataMat = [cell2mat(conjData(:,2)),cell2mat(conjData(:,4)),...
    cell2mat(conjData(:,5)),cell2mat(conjData(:,6)),cell2mat(conjData(:,7))];

summDataMat = [cell2mat(summData(:,2)),cell2mat(summData(:,4)),...
    cell2mat(summData(:,5)),cell2mat(summData(:,6)),cell2mat(summData(:,7))];

% Difference between value Rating and real Aveage value (learning index)
conjDataMat(:,6) = abs(conjDataMat(:,3) - conjDataMat(:,5));
summDataMat(:,6) = abs(summDataMat(:,3) - summDataMat(:,5));

% Add trial number (regardless of blocks)
for i = 1:length(conjDataMat)
conjDataMat(i,7) = i;
summDataMat(i,7) = i;
end

% Get average RTs
averRTconj = mean(conjDataMat(:,4));
averRTsumm = mean(summDataMat(:,4));

%% Plot stuff

    if learningRatingsRaw
        figure
        plot(conjDataMat(:,7),conjDataMat(:,6));
        hold on
        plot(summDataMat(:,7),summDataMat(:,6));
        xlabel('Trial');
        ylabel('abs(valueRating - realValue)');
        title([num2str(subjectNumber),'  LEARNING RATINGS: VALUE PREDICTION DIFFERENCE (0 = PERFECT)']);
        line([lengthBlock,lengthBlock],[0,45], 'linewidth',1,'color',[0,0,0]);
        line([lengthBlock*2,lengthBlock*2],[0,45], 'linewidth',1,'color',[0,0,0]);
        line([lengthBlock*3,lengthBlock*3],[0,45], 'linewidth',1,'color',[0,0,0]);
        line([lengthBlock*4,lengthBlock*4],[0,45], 'linewidth',1,'color',[0,0,0]);
        legend('CONJUCTION', 'SUMMATION', 'BLOCK 1-2','BLOCK 2-3','BLOCK 3-4','BLOCK 4-5');
    end

    if learningRtRaw
        % RT as function of Trial num
        figure
        plot(conjDataMat(:,7),conjDataMat(:,4));
        hold on
        plot(summDataMat(:,7),summDataMat(:,4));
        legend('CONJUCTION', 'SUMMATION');
        xlabel('Trial');
        ylabel('Reaction Timte (s)');
        title([num2str(subjectNumber),'  LEARNING RATINGS: RT OVER TIME']);
    end

    if learningRtMean
        % average RT
        figure
        bar([averRTconj,averRTsumm]);
        xlabel('1.CONJUNCTION     --    2.SUMMATION');
        ylabel('RT (s)');
        title([num2str(subjectNumber),'  LEARNING RATINGS: AVERAGE RT']);
    end

end % End function