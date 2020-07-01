%% Gabriel Pelletier, March 2018
% This script analyze data from the Bid (rating) task of
% the fribbles_fmri experiment

% For every subject, it carries out a simple linear reression analysis
% on data from Conjuntion and Summation trials separately.
% IV = Instucted, "true" value
% DV = Value ratings (bids)

% It plots the data with overlapping regression fit line
% Also plots residuals of the model.

% Coeficient estimates and model fits are compiled for further group
% analysis.


% NOTE: Accross this file Conjunction coded as 1, Summation = 2
%       Conjunction is plotted in Blue, Summation in Red.

function regres_SubLevel(dataPath, subs, bidsMainRawRatings_linReg, bidsMainLinReg_CI, residualsPlot)

%% 
    
% For ploting purposes (multi-plot Figures)
if bidsMainRawRatings_linReg
    hdat = figure('Name','Raw Ratings with Linead Regression Lines by Condition'); % For data plots
end
if residualsPlot
    hres = figure('Name','Residuals'); % For residual plots
end
if bidsMainLinReg_CI
    hci = figure('Name','Linear Regression and 95% Confidence Intervals');
end
subPloti = 1; %  Index for subplot within figure
numSubs = length (subs);
figRows = 2;
if length(subs) == 1
    figRows = 1;
end
figCols = ceil(numSubs/figRows);


for subjectNumber = subs
    
    %% Organize data
    dataDir = [dataPath,'/sub-0',num2str(subjectNumber),'/'];
    runNums = 4;

    % Concatenate runs data
    fullSubData = [];
    for r = 1 : runNums
        load([dataDir,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(r),'.mat']);
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
    conjInd = find(strcmp( ratingTrialsData(:,6),'conj'));
    conjData =  ratingTrialsData(conjInd,:);
    conjData = [cell2mat(conjData(:,5)),cell2mat(conjData(:,7)),cell2mat(conjData(:,8))];
    summInd = find(strcmp( ratingTrialsData(:,6),'summ'));
    summData =  ratingTrialsData(summInd,:);
    summData = [cell2mat(summData(:,5)),cell2mat(summData(:,7)),cell2mat(summData(:,8))];

    x1 = conjData(:,1);
    y1 = conjData(:,2);

    x2 = summData(:,1);
    y2 = summData(:,2);

    % Matalb function for Linear regression analysis
    mdl1 = LinearModel.fit(x1,y1);
    modelData1 = x1 * mdl1.Coefficients.Estimate(2) + mdl1.Coefficients.Estimate(1); % x*b1 + b0  
    r1 = mdl1.Residuals{:,3};
    mdl2 = LinearModel.fit(x2,y2);
    modelData2 = x2 * mdl2.Coefficients.Estimate(2) + mdl2.Coefficients.Estimate(1); 
    r2 = mdl2.Residuals{:,3}; 
    
    % Calculate Confidence intervals
    CI1 = coefCI(mdl1, 0.05);
    CI2 = coefCI(mdl2, 0.1);
    
    if bidsMainRawRatings_linReg
    %% Plot Data and model fit
        set(0,'CurrentFigure',hdat);
        subplot(figRows,figCols,subPloti)
        scatter(x1,y1,'b')
        hold on
        plot(x1,modelData1,'b');
        scatter(x2,y2,'r')
        hold on
        plot(x2,modelData2,'r');
        line([20 100],[20 100],'color','k', 'lineStyle', '--')
        title(['sub-',num2str(subjectNumber)]);
        xlabel('Instructed Value');
        ylabel('Value ratings');
    end  
    
    if residualsPlot   
    %% Plot residuals
        set(0,'CurrentFigure',hres);
        subplot(figRows,figCols,subPloti)
        scatter(x1,r1,'b')
        hold on
        scatter(x2,r2,'r')
        line([20 100],[0 0],'color','k', 'lineStyle', '--')
        xlabel('Instructed Value');
        ylabel('Residuals (Studentized)');
        title(['sub-',num2str(subjectNumber),'- Linear regression residuals']);
    end
    
    if bidsMainLinReg_CI  
    
    %% CI regression plots 
        set(0,'CurrentFigure',hci);
        subplot(figRows,figCols,subPloti)

         X = [ones(size(x1)) x1];
         [b,bint] = regress(y1,X); 
         xval = min(x1):0.01:max(x1);
         yhat = b(1)+b(2)*xval;
         ylow = bint(1,1)+bint(2,1)*xval;
         yupp = bint(1,2)+bint(2,2)*xval;
         y3 = [yhat', ylow', yupp'];
         plot_ci(xval,y3, 'PatchColor', 'b', 'PatchAlpha', 0.2, ...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'b', ...
            'LineWidth', 1.5, 'LineStyle','--', 'LineColor', 'b'); 
        hold on
         X = [ones(size(x2)) x2];
         [b,bint] = regress(y2,X); 
         xval = min(x2):0.01:max(x2);
         yhat = b(1)+b(2)*xval;
         ylow = bint(1,1)+bint(2,1)*xval;
         yupp = bint(1,2)+bint(2,2)*xval;
         y3 = [yhat', ylow', yupp'];
         plot_ci(xval,y3, 'PatchColor', 'r', 'PatchAlpha', 0.2, ...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'r', ...
            'LineWidth', 1.5, 'LineStyle','--', 'LineColor', 'r');
         line([20 100],[20 100],'color','k')
         axis([20 100 20 100])
         title(['sub-',num2str(subjectNumber),'- Linear regression CI']);
         xlabel('Instructed Value');
         ylabel('Value ratings');

    end
    regres_SubLevel_models(subPloti).Subject = subjectNumber;
    regres_SubLevel_models(subPloti).Conjunction = mdl1;
    regres_SubLevel_models(subPloti).Summation = mdl2;
    
    subPloti = subPloti + 1;
end

if bidsMainRawRatings_linReg
    set(0,'CurrentFigure',hdat);
    legend('Conj','ConjFit','Summ','SummFit', 'Location', 'best');
end
if residualsPlot
    set(0,'CurrentFigure',hres);
    legend('Conj', 'Summ', 'Location', 'best');
end
if bidsMainLinReg_CI
    set(0,'CurrentFigure',hci);
    legend('Conj', 'Location', 'best');
end
save('regres_SubLevel_models.mat', 'regres_SubLevel_models');

end