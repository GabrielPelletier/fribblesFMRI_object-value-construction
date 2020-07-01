%% Gabriel Pelletie, March 2019
 
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Plot Group Averages and individual data points

%%

function plotEyeTracking_group(groupEyeData)


% ***************************************************************************
%% Plot Num of Transitions

    gcf1 = figure('renderer', 'painters', 'Position',[100 100 400 350], ...
                   'Name', 'Number of within-object Transitions');
               
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255];
    
    
% Group averages
    a1 = subplot(1,1,1);
    bar(1, mean(groupEyeData.mean_TransPerTrial_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean(groupEyeData.mean_TransPerTrial_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    sem_conj = std(groupEyeData.mean_TransPerTrial_conj)/sqrt(length(groupEyeData.mean_TransPerTrial_conj));
    sem_summ = std(groupEyeData.mean_TransPerTrial_summ)/sqrt(length(groupEyeData.mean_TransPerTrial_summ));
    er = errorbar([1,2],[mean(groupEyeData.mean_TransPerTrial_conj), mean(groupEyeData.mean_TransPerTrial_summ)],[sem_conj, sem_summ],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average number of transitions', 'per trial'}); % y-axis label
    ylim ([0, 3]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',20)
    set(a1,'xtick',[])  
    box off
    
% % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(groupEyeData.mean_TransPerTrial_conj, groupEyeData.mean_TransPerTrial_summ);
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
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    print(gcf1, '-dtiff', '../../figures/figure_eye_trans.tiff', '-r600');




% ***************************************************************************
%% Plot Symmetric Viewing Time (ratio Gaze duration to Attribute1 vs Attribute2)


    gcf2 = figure('renderer', 'painters', 'Position',[100 100 400 350], ...
                   'Name', 'Symmetric Viewing Time Index');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    

% Group averages
    a1 = subplot(1,1,1);
    bar(1, mean(groupEyeData.mean_Dur_conj_Symm), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean(groupEyeData.mean_Dur_summ_Symm), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    sem_conj = std(groupEyeData.mean_Dur_conj_Symm)/sqrt(length(groupEyeData.mean_Dur_conj_Symm));
    sem_summ = std(groupEyeData.mean_Dur_summ_Symm)/sqrt(length(groupEyeData.mean_Dur_summ_Symm));
    er = errorbar([1,2],[mean(groupEyeData.mean_Dur_conj_Symm), mean(groupEyeData.mean_Dur_summ_Symm)],[sem_conj, sem_summ],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Symmetric Vieweing Time Index', '(a.u.)'}); % y-axis label
    %ylim ([0, 8]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',20)
    set(a1,'xtick',[])

    box off
    
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
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    %print(gcf2, '-dtiff', '../figures/figure_accuracy.tiff', '-r600');






% ***************************************************************************
%% Plot Number of Fixations


    gcf3 = figure('renderer', 'painters', 'Position',[100 100 400 350], ...
                   'Name', 'Number of Fixation per Trial');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    

% Group averages
    a1 = subplot(1,1,1);
    bar(1, mean(groupEyeData.mean_NumFixPerTrial_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean(groupEyeData.mean_NumFixPerTrial_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    sem_conj = std(groupEyeData.mean_NumFixPerTrial_conj)/sqrt(length(groupEyeData.mean_NumFixPerTrial_conj));
    sem_summ = std(groupEyeData.mean_NumFixPerTrial_summ)/sqrt(length(groupEyeData.mean_NumFixPerTrial_summ));
    er = errorbar([1,2],[mean(groupEyeData.mean_NumFixPerTrial_conj), mean(groupEyeData.mean_NumFixPerTrial_summ)],[sem_conj, sem_summ],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average number of fixations', 'per trial'}); % y-axis label
    ylim ([0, 9]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',20)
    set(a1,'xtick',[])

    box off
    
% % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(groupEyeData.mean_NumFixPerTrial_conj, groupEyeData.mean_NumFixPerTrial_summ);
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
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    print(gcf3, '-dtiff', '../../figures/figure_eye_numFix.tiff', '-r600');




   
% ***************************************************************************
%% Plot Duration of fixations



    gcf4 = figure('renderer', 'painters', 'Position',[100 100 400 350], ...
                   'Name', 'Average Duration of Invidual Fixations');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 

    
% Group averages
    a1 = subplot(1,1,1);
    bar(1, mean(groupEyeData.mean_AveFixDur_conj), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean(groupEyeData.mean_AveFixDur_summ), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    sem_conj = std(groupEyeData.mean_AveFixDur_conj)/sqrt(length(groupEyeData.mean_AveFixDur_conj));
    sem_summ = std(groupEyeData.mean_AveFixDur_summ)/sqrt(length(groupEyeData.mean_AveFixDur_summ));
    er = errorbar([1,2],[mean(groupEyeData.mean_AveFixDur_conj), mean(groupEyeData.mean_AveFixDur_summ)],[sem_conj, sem_summ],' ');
    
    %title ('Group average');
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average duration' 'of individual fixations (ms)'}); % y-axis label
    ylim ([0, 500]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',20)
    set(a1,'xtick',[])

    box off
    
%     % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(groupEyeData.mean_AveFixDur_conj, groupEyeData.mean_AveFixDur_summ);
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
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    % Save high-res image in .tiff format
    print(gcf4, '-dtiff', '../../figures/figure_eye_durFix.tiff', '-r600');


  
end