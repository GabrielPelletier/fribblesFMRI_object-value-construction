%% Gabriel Pelletie, March 2019
 
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Plot Group Averages and individual data points

%%

function plotEyeTracking_group(groupEyeData)


% ***************************************************************************
%% Plot Num of Transitions
N = size(groupEyeData,1);
    gcf1 = figure('renderer', 'painters', 'Position', [100 100 800 1200], ...
                   'Name', 'EYE-TRACKING RESULTS');
               
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255];
    
% Single Subjects
    a3 = subplot(3,2,3);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        legend_text{end+1} = num2str(groupEyeData.Subject_Num(i));
        line([1,2], [groupEyeData.mean_TransPerTrial_conj(i), groupEyeData.mean_TransPerTrial_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.mean_TransPerTrial_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.mean_TransPerTrial_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
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
    bar(1, mean(groupEyeData.mean_TransPerTrial_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.mean_TransPerTrial_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    % Error bar = SEM
    %er = errorbar([1,2],[mean(groupEyeData.mean_TransPerTrial_conj), mean(groupEyeData.mean_TransPerTrial_summ)],[std(groupEyeData.mean_TransPerTrial_conj/sqrt(N)),std(groupEyeData.mean_TransPerTrial_summ)/sqrt(N)],' ');
    % Error bar = SD
    er = errorbar([1,2],[mean(groupEyeData.mean_TransPerTrial_conj), mean(groupEyeData.mean_TransPerTrial_summ)],[std(groupEyeData.mean_TransPerTrial_conj),std(groupEyeData.mean_TransPerTrial_summ)],' ');

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
    
% Do Stats (paired sample ttest) to compare condition and display on graph
    [h,p,ci,stats] = ttest(groupEyeData.mean_TransPerTrial_conj, groupEyeData.mean_TransPerTrial_summ);
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
    
%    pos = get(a2, 'position');
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
%    print(gcf1, '-dtiff', '../../figures/eye_numTrans.tiff', '-r600');




% ***************************************************************************
%% Plot Symmetric Viewing Time (ratio Gaze duration to Attribute1 vs Attribute2)
% 
% 
%     gcf2 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
%                    'Name', 'Symmetric Viewing Time Index');
%     C_color = [255/255 168/255 1/255];    
%     E_color = [255/255 82/255 82/255]; 
%     
% % Single Subjects
%     a1 = subplot(1,2,1);
%     legend_text = {};
%     for i = 1:size(groupEyeData,1)
%         legend_text{end+1} = num2str(groupEyeData.Subject_Num(i));
%         line([1,2], [groupEyeData.mean_Dur_conj_Symm(i), groupEyeData.mean_Dur_summ_Symm(i)], 'Color', 'k');
%         hold on
%     end
%     scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.mean_Dur_conj_Symm, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
%     scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.mean_Dur_summ_Symm, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
%     hold off
%     title ('All participants');
%     xlim ([0.5 2.5]);
%     xlim ([0.2 2.8]);
%     xlabel('Configural     Elemental'); % x-axis label
%     ylabel({'Symmetric Vieweing Time Index', '(a.u.)',''}); % y-axis label
%     %ylim ([0, 8]);
%     yl = ylim; % Get the limit that was set automatically based on the data.
%     %legend(legend_text);
% 
%     
% % Group averages
%     a2 = subplot(1,2,2);
%     bar(1, mean(groupEyeData.mean_Dur_conj_Symm), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
%     bar(2, mean(groupEyeData.mean_Dur_summ_Symm), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
%     er = errorbar([1,2],[mean(groupEyeData.mean_Dur_conj_Symm), mean(groupEyeData.mean_Dur_summ_Symm)],[std(groupEyeData.mean_Dur_conj_Symm),std(groupEyeData.mean_Dur_summ_Symm)],' ');
%     
%     title ('Group average');
%     xlabel('Configural     Elemental'); % x-axis label
%     %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
%     %ylim ([0, 8]);
%     ylim(yl); % Set this graph's axis limit to fit the other graph.
%     xlim ([0.2 2.8]);
%    
%     er.Color = [0 0 0];                            
%     er.LineStyle = 'none';  
%     er.LineWidth = 2;
%     er.CapSize = 0;
%     
%     set(a1,'FontSize',16)
%     set(a2,'FontSize',16)
%     set(a1,'xtick',[])
%     set(a2,'xtick',[])
% 
%     box off
%     
%     % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(groupEyeData.mean_Dur_conj_Symm, groupEyeData.mean_Dur_summ_Symm);
%     if p < 0.001
%         sig = '***';
%     elseif p < 0.01
%         sig = '**';
%     elseif p < 0.05
%         sig = '*';
%     else
%         sig = '(n.s.)';
%     end
%     
%     pos = get(a2, 'position');
% %     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
% %         'LineStyle', 'none', 'FontSize', 16);
%     
%     % Save high-res image in .tiff format
%     %print(gcf2, '-dtiff', '../figures/figure_accuracy.tiff', '-r600');
% 
% 
% 



% ***************************************************************************
%% Plot Number of Fixations


    %gcf3 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
    %               'Name', 'Number of Fixation per Trial');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
% Single Subjects
    a1 = subplot(3,2,1);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        legend_text{end+1} = num2str(groupEyeData.Subject_Num(i));
        line([1,2], [groupEyeData.mean_NumFixPerTrial_conj(i), groupEyeData.mean_NumFixPerTrial_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.mean_NumFixPerTrial_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.mean_NumFixPerTrial_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
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
    bar(1, mean(groupEyeData.mean_NumFixPerTrial_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.mean_NumFixPerTrial_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    % Error bar = SEM
    %er = errorbar([1,2],[mean(groupEyeData.mean_NumFixPerTrial_conj), mean(groupEyeData.mean_NumFixPerTrial_summ)],[std(groupEyeData.mean_NumFixPerTrial_conj/sqrt(N)),std(groupEyeData.mean_NumFixPerTrial_summ)/sqrt(N)],' ');
    % Error bar = SD
    er = errorbar([1,2],[mean(groupEyeData.mean_NumFixPerTrial_conj), mean(groupEyeData.mean_NumFixPerTrial_summ)],[std(groupEyeData.mean_NumFixPerTrial_conj),std(groupEyeData.mean_NumFixPerTrial_summ)],' ');

    title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    %ylabel('Average rating error: abs(instructed value - bids)'); % y-axis label
    ylim ([0, 10]);
    yticks ([0 2 4 6 8 10]);
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
    [h,p,ci,stats] = ttest(groupEyeData.mean_NumFixPerTrial_conj, groupEyeData.mean_NumFixPerTrial_summ);
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
    
%    pos = get(a2, 'position');
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
%     print(gcf3, '-dtiff', '../../figures/eye_numFix.tiff', '-r600');




   
% ***************************************************************************
%% Plot Duration of fixations

    %gcf4 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
    %               'Name', 'Average Duration of Invidual Fixations');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
% Single Subjects
    a5 = subplot(3,2,5);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        legend_text{end+1} = num2str(groupEyeData.Subject_Num(i));
        line([1,2], [groupEyeData.mean_AveFixDur_conj(i), groupEyeData.mean_AveFixDur_summ(i)], 'Color', 'k');
        hold on
    end
    scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.mean_AveFixDur_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.mean_AveFixDur_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
    hold off
    %title ('All participants');
    xlim ([0.5 2.5]);
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Duration of single' 'fixations (ms)'}); % y-axis label
    ylim ([0, 700]);
    yticks([0 100 200 300 400 500 600 700]);
    yticklabels({'0','','200','','400','','600',''});
    %legend(legend_text);

    
% Group averages
    a6 = subplot(3,2,6);
    bar(1, mean(groupEyeData.mean_AveFixDur_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color, 'LineWidth', 3); hold on
    bar(2, mean(groupEyeData.mean_AveFixDur_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color, 'LineWidth', 3); hold on
    % Error bat = SEM
    %er = errorbar([1,2],[mean(groupEyeData.mean_AveFixDur_conj), mean(groupEyeData.mean_AveFixDur_summ)],[std(groupEyeData.mean_AveFixDur_conj/sqrt(N)),std(groupEyeData.mean_AveFixDur_summ)/sqrt(N)],' ');
    % Error bar = SD
    er = errorbar([1,2],[mean(groupEyeData.mean_AveFixDur_conj), mean(groupEyeData.mean_AveFixDur_summ)],[std(groupEyeData.mean_AveFixDur_conj),std(groupEyeData.mean_AveFixDur_summ)],' ');

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
    
    % Do Stats (paired sample ttest) to compare condition and display on graph
    [h,p,ci,stats] = ttest(groupEyeData.mean_AveFixDur_conj, groupEyeData.mean_AveFixDur_summ);
    if p < 0.001
        sig = '***';
    elseif p < 0.01
        sig = '**';
    elseif p < 0.05
        sig = '*';
    else
        sig = '(n.s.)';
    end
    
%    pos = get(a2, 'position');
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
 %   print(gcf4, '-dtiff', '../../figures/eye_durFix.tiff', '-r600');

  print(gcf1, '-dtiff', '../../figures/bidding_eyeTrackingVariables_fMRIsample.tiff', '-r600');
  
end