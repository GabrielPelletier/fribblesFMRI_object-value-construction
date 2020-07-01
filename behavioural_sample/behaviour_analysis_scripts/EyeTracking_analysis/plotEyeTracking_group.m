%% Gabriel Pelletie, March 2019
 
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Plot Group Averages

%%

function plotEyeTracking_group(groupEyeData)

% Sample size 
N = size(groupEyeData,1);

gcf1 = figure('renderer', 'painters', 'Position', [100 100 800 1200], ...
                   'Name', 'EYE-TRACKING RESULTS');
               
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255];

%% Plot Num of Transitions

% Single Subjects
    a3 = subplot(3,2,3);
    for i = 1:size(groupEyeData,1)
        line([1,2], [groupEyeData.groupTrans_conj(i), groupEyeData.groupTrans_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.groupTrans_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.groupTrans_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    hold off
    %title ('All participants');
    xlim ([0.5 2.5]);
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Transitions', 'per trial',''}); % y-axis label
    yl = ylim; % Get the limit that was set automatically based on the data.
    %legend(legend_text);

    
% Group averages
    a4 = subplot(3,2,4);
    bar(1, mean(groupEyeData.groupTrans_conj), 0.8, 'FaceColor', 'w', 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.groupTrans_summ), 0.8, 'FaceColor', 'w', 'EdgeColor', E_color, 'LineWidth', 3); hold on
    
    % Error bars SEM
    %er = errorbar([1,2],[mean(groupEyeData.groupTrans_conj), mean(groupEyeData.groupTrans_summ)],[std(groupEyeData.groupTrans_conj)/sqrt(N),std(groupEyeData.groupTrans_summ)/sqrt(N)],' ');
    
    % Error bar SD
    er = errorbar([1,2],[mean(groupEyeData.groupTrans_conj), mean(groupEyeData.groupTrans_summ)],[std(groupEyeData.groupTrans_conj),std(groupEyeData.groupTrans_summ)],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    %ylim ([0, 8]);
    ylim(yl); % Set this graph's axis limit to fit the other graph.
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a3,'FontSize',16)
    set(a4,'FontSize',16)
    set(a3,'xtick',[])
    set(a4,'xtick',[])    
    %set(a2,'YTickLabel',[]);
    box off

%% Plot Number of Fixations

% Single Subjects
    a1 = subplot(3,2,1);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        line([1,2], [groupEyeData.groupNumFix_conj(i), groupEyeData.groupNumFix_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.groupNumFix_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.groupNumFix_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    hold off
    title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Fixations', 'per trial', ''}); % y-axis label
    ylim ([0, 10]);
    yticks([0 2 4 6 8 10]);
    %legend(legend_text);

    
% Group averages
    a2 = subplot(3,2,2);
    bar(1, mean(groupEyeData.groupNumFix_conj), 0.8, 'FaceColor', 'w', 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.groupNumFix_summ), 0.8, 'FaceColor', 'w', 'EdgeColor', E_color, 'LineWidth', 3); hold on
    % Error bars = SEM
    %er = errorbar([1,2],[mean(groupEyeData.groupNumFix_conj), mean(groupEyeData.groupNumFix_summ)],[std(groupEyeData.groupNumFix_conj)/sqrt(N),std(groupEyeData.groupNumFix_summ)/sqrt(N)],' ');
    % Error bars = SD
    er = errorbar([1,2],[mean(groupEyeData.groupNumFix_conj), mean(groupEyeData.groupNumFix_summ)],[std(groupEyeData.groupNumFix_conj),std(groupEyeData.groupNumFix_summ)],' ');
    
    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    ylim ([0, 10]);
    yticks([0 2 4 6 8 10])
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


%% Plot Duration of fixations

    %gcf4 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
    %               'Name', 'Average Duration of Invidual Fixations');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
% Single Subjects
    a5 = subplot(3,2,5);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        line([1,2], [groupEyeData.groupDurFix_conj(i), groupEyeData.groupDurFix_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.groupDurFix_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.groupDurFix_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.01, 'LineWidth', 1.5);
    hold off
    %title ('All participants');
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Duration of single' 'fixations (ms)'}); % y-axis label
    ylim ([0, 700]);
    yticks([0 100 200 300 400 500 600 700]);
    yticklabels({'0','','200','','400','','600',''});
    %legend(legend_text);
    
% Group averages
    a6 = subplot(3,2,6);
    bar(1, mean(groupEyeData.groupDurFix_conj), 0.8, 'FaceColor', 'w', 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.groupDurFix_summ), 0.8, 'FaceColor', 'w', 'EdgeColor', E_color, 'LineWidth', 3); hold on
    % Error bars = SEM
    %er = errorbar([1,2],[mean(groupEyeData.groupDurFix_conj), mean(groupEyeData.groupDurFix_summ)],[std(groupEyeData.groupDurFix_conj)/sqrt(N),std(groupEyeData.groupDurFix_summ)/sqrt(N)],' ');
    % Error bars = SD
    er = errorbar([1,2],[mean(groupEyeData.groupDurFix_conj), mean(groupEyeData.groupDurFix_summ)],[std(groupEyeData.groupDurFix_conj),std(groupEyeData.groupDurFix_summ)],' ');
    
   %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    ylim ([0, 700]);
    yticks([0 100 200 300 400 500 600 700]);
    yticklabels({'0','','200','','400','','600',''});
    
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a5,'FontSize',16)
    set(a6,'FontSize',16)
    set(a5,'xtick',[])
    set(a6,'xtick',[])
box off


%% code for stats
    % Do Stats (paired sample ttest) to compare condition and display on graph
    [h,p,ci,stats] = ttest(groupEyeData.groupTrans_conj, groupEyeData.groupTrans_summ)
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
%     
%    pos = get(a2, 'position');
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    

 % Sve high-res figure
 print(gcf1, '-dtiff', 'eyeTracking_variables_BehavSameple.tiff', '-r600');
 
end