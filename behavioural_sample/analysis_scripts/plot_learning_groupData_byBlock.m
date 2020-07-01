function plot_learning_groupData_byBlock(learning_accuByBlock_group, learning_RtByBlock_group, plot_learning_Acc_RT_byBlock_group)

if plot_learning_Acc_RT_byBlock_group
%% Accuracy

    gcf1 = figure('renderer', 'painters', 'Position',[100 100 450 700], ...
                   'Name', 'Learning - AVERAGE RATING ACCURACY AND RT BY BLOCK');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    subp1 = subplot(2,1,1);
    
    % Single Subjects
    legend_text = {};
    for i = 1:size(learning_accuByBlock_group,1)
    %plot_c = plot([1,2,3,4,5], [learning_accuByBlock_group.learnAccConj_block_1to5(i,1), learning_accuByBlock_group.learnAccConj_block_1to5(i,2), learning_accuByBlock_group.learnAccConj_block_1to5(i,3), learning_accuByBlock_group.learnAccConj_block_1to5(i,4), learning_accuByBlock_group.learnAccConj_block_1to5(i,5)], 'Color', C_color);
    %plot_c.Color(4) = 0.2;
    %hold on
    %plot_e = plot([1,2,3,4,5], [learning_accuByBlock_group.learnAccSumm_block_1to5(i,1), learning_accuByBlock_group.learnAccSumm_block_1to5(i,2), learning_accuByBlock_group.learnAccSumm_block_1to5(i,3), learning_accuByBlock_group.learnAccSumm_block_1to5(i,4), learning_accuByBlock_group.learnAccSumm_block_1to5(i,5)], 'Color', E_color);
    %plot_e.Color(4) = 0.2;
    %hold on
    end

    means_conj = [mean(learning_accuByBlock_group.learnAccConj_block_1to5(:,1)), mean(learning_accuByBlock_group.learnAccConj_block_1to5(:,2)), mean(learning_accuByBlock_group.learnAccConj_block_1to5(:,3)), mean(learning_accuByBlock_group.learnAccConj_block_1to5(:,4)), mean(learning_accuByBlock_group.learnAccConj_block_1to5(:,5))];
    means_summ = [mean(learning_accuByBlock_group.learnAccSumm_block_1to5(:,1)), mean(learning_accuByBlock_group.learnAccSumm_block_1to5(:,2)), mean(learning_accuByBlock_group.learnAccSumm_block_1to5(:,3)), mean(learning_accuByBlock_group.learnAccSumm_block_1to5(:,4)), mean(learning_accuByBlock_group.learnAccSumm_block_1to5(:,5))];
    sd_conj = [std(learning_accuByBlock_group.learnAccConj_block_1to5(:,1)), std(learning_accuByBlock_group.learnAccConj_block_1to5(:,2)), std(learning_accuByBlock_group.learnAccConj_block_1to5(:,3)), std(learning_accuByBlock_group.learnAccConj_block_1to5(:,4)), std(learning_accuByBlock_group.learnAccConj_block_1to5(:,5))];
    sd_summ = [std(learning_accuByBlock_group.learnAccSumm_block_1to5(:,1)), std(learning_accuByBlock_group.learnAccSumm_block_1to5(:,2)), std(learning_accuByBlock_group.learnAccSumm_block_1to5(:,3)), std(learning_accuByBlock_group.learnAccSumm_block_1to5(:,4)), std(learning_accuByBlock_group.learnAccSumm_block_1to5(:,5))];

    % Group average
    pg1 = plot([1,2,3,4,5], means_conj, 'Color', C_color, 'LineWidth', 5);
    hold on
    plot([1,2,3,4,5], means_conj, 'Color', 'w', 'LineWidth', 2);
    hold on
    pg2 = plot([1,2,3,4,5], means_summ, 'Color', E_color, 'LineWidth', 5);
    hold on 
    plot([1,2,3,4,5], means_summ, 'Color', 'w', 'LineWidth', 2);
    hold on
    
    % add errobars
    er_c = errorbar([1,2,3,4,5], means_conj, sd_conj,' ');
    er_c.Color = C_color;                            
    er_c.LineStyle = 'none';  
    er_c.LineWidth = 2;
    er_c.CapSize = 0;
    
    er_c2 = errorbar([1,2,3,4,5], means_conj, sd_conj,' ');
    er_c2.Color = 'w';                            
    er_c2.LineStyle = 'none';  
    er_c2.LineWidth = 0.7;
    er_c2.CapSize = 0;
    
    er_s = errorbar([1,2,3,4,5], means_summ, sd_summ,' ');
    er_s.Color = E_color;                            
    er_s.LineStyle = 'none';  
    er_s.LineWidth = 2;
    er_s.CapSize = 0;

    er_s2 = errorbar([1,2,3,4,5], means_summ, sd_summ,' ');
    er_s2.Color = 'w';                            
    er_s2.LineStyle = 'none';  
    er_s2.LineWidth = 0.7;
    er_s2.CapSize = 0;    
    
    %title ('All participants');
    xlim ([0.5 5.5]);
    xticks([1 2 3 4 5]);

    %xlabel('Learning block'); % x-axis label
    ylabel({'Rating error', '|Instructed value - rating|','(NIS)'}); % y-axis label
    %ylim ([0, 16]);
    %legend([pg1, pg2], 'Configural', 'Elemental');
    
    set(gca,'fontsize', 16)
    
    box off
    
    % Save high-res image in .tiff format
    %print(gcf1, '-dtiff', '../figures/learning_AccbyBlock.tiff', '-r600');
%% Accuracy
    subp2 = subplot(2,1,2);
    %gcf2 = figure('renderer', 'painters', 'Position',[100 100 800 400], ...
    %              'Name', 'Learning - AVERAGE RT BY BLOCK');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    % Single Subjects
    legend_text = {};
    for i = 1:size(learning_RtByBlock_group,1)
    %plot_c = plot([1,2,3,4,5], [learning_accuByBlock_group.learnAccConj_block_1to5(i,1), learning_accuByBlock_group.learnAccConj_block_1to5(i,2), learning_accuByBlock_group.learnAccConj_block_1to5(i,3), learning_accuByBlock_group.learnAccConj_block_1to5(i,4), learning_accuByBlock_group.learnAccConj_block_1to5(i,5)], 'Color', C_color);
    %plot_c.Color(4) = 0.2;
    %hold on
    %plot_e = plot([1,2,3,4,5], [learning_accuByBlock_group.learnAccSumm_block_1to5(i,1), learning_accuByBlock_group.learnAccSumm_block_1to5(i,2), learning_accuByBlock_group.learnAccSumm_block_1to5(i,3), learning_accuByBlock_group.learnAccSumm_block_1to5(i,4), learning_accuByBlock_group.learnAccSumm_block_1to5(i,5)], 'Color', E_color);
    %plot_e.Color(4) = 0.2;
    %hold on
    end

    means_conj = [mean(learning_RtByBlock_group.learnRtConj_block_1to5(:,1)), mean(learning_RtByBlock_group.learnRtConj_block_1to5(:,2)), mean(learning_RtByBlock_group.learnRtConj_block_1to5(:,3)), mean(learning_RtByBlock_group.learnRtConj_block_1to5(:,4)), mean(learning_RtByBlock_group.learnRtConj_block_1to5(:,5))];
    means_summ = [mean(learning_RtByBlock_group.learnRtSumm_block_1to5(:,1)), mean(learning_RtByBlock_group.learnRtSumm_block_1to5(:,2)), mean(learning_RtByBlock_group.learnRtSumm_block_1to5(:,3)), mean(learning_RtByBlock_group.learnRtSumm_block_1to5(:,4)), mean(learning_RtByBlock_group.learnRtSumm_block_1to5(:,5))];
    sd_conj = [std(learning_RtByBlock_group.learnRtConj_block_1to5(:,1)), std(learning_RtByBlock_group.learnRtConj_block_1to5(:,2)), std(learning_RtByBlock_group.learnRtConj_block_1to5(:,3)), std(learning_RtByBlock_group.learnRtConj_block_1to5(:,4)), std(learning_RtByBlock_group.learnRtConj_block_1to5(:,5))];
    sd_summ = [std(learning_RtByBlock_group.learnRtSumm_block_1to5(:,1)), std(learning_RtByBlock_group.learnRtSumm_block_1to5(:,2)), std(learning_RtByBlock_group.learnRtSumm_block_1to5(:,3)), std(learning_RtByBlock_group.learnRtSumm_block_1to5(:,4)), std(learning_RtByBlock_group.learnRtSumm_block_1to5(:,5))];
    means_conj = means_conj/1000;
    means_summ = means_summ/1000;
    sd_conj = sd_conj/1000;
    sd_summ = sd_summ/1000;

    % Group average
    pg1 = plot([1,2,3,4,5], means_conj, 'Color', C_color, 'LineWidth', 5);
    hold on
    plot([1,2,3,4,5], means_conj, 'Color', 'w', 'LineWidth', 2);
    hold on
    pg2 = plot([1,2,3,4,5], means_summ, 'Color', E_color, 'LineWidth', 5);
    hold on
    plot([1,2,3,4,5], means_summ, 'Color', 'w', 'LineWidth', 2);
    hold on
    
    % add errobars
    er_c = errorbar([1,2,3,4,5], means_conj, sd_conj,' ');
    er_c.Color = C_color;                            
    er_c.LineStyle = 'none';  
    er_c.LineWidth = 2;
    er_c.CapSize = 0;
    
    er_c2 = errorbar([1,2,3,4,5], means_conj, sd_conj,' ');
    er_c2.Color = 'w';                            
    er_c2.LineStyle = 'none';  
    er_c2.LineWidth = 0.7;
    er_c2.CapSize = 0;
    
    er_s = errorbar([1,2,3,4,5], means_summ, sd_summ,' ');
    er_s.Color = E_color;                            
    er_s.LineStyle = 'none';  
    er_s.LineWidth = 2;
    er_s.CapSize = 0;

    er_s2 = errorbar([1,2,3,4,5], means_summ, sd_summ,' ');
    er_s2.Color = 'w';                            
    er_s2.LineStyle = 'none';  
    er_s2.LineWidth = 0.7;
    er_s2.CapSize = 0;    
    
    %title ('All participants');
    xlim ([0.5 5.5]);
    xticks([1 2 3 4 5]);
    ylim ([1 5]);
    xlabel('Learning block'); % x-axis label
    ylabel({'Reaction time','(s)', ''}); % y-axis label
    %ylim ([0, 8]);
   %legend([pg1, pg2], 'Configural', 'Elemental');
    
    set(gca,'fontsize', 16)
    
    box off
    
    
    % Save high-res image in .tiff format
    print(gcf1, '-dtiff', '../figures/learning_Acc_Rt_byBlock_behaviorSample.tiff', '-r600');
end
end