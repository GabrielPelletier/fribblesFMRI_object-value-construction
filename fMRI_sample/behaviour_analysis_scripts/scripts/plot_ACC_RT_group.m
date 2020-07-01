    


load('ratingAcc_group.mat');
load('ratingRT_group.mat');

gcf1 = figure('renderer', 'painters', 'Position',[100 100 700 300], ...
                   'Name', 'BID PHASE - AVERAGE RATING ACCURACY AND REACTION TIME');
               
C_color = [255/255 168/255 1/255];    
E_color = [255/255 82/255 82/255]; 
    

%% Accuracy

% % % Group averages
    a1 = subplot(1,2,1);
    bar(1, mean(ratingAcc_group{:,2}), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean(ratingAcc_group{:,3}), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    er = errorbar([1,2],[mean(ratingAcc_group{:,2}), mean(ratingAcc_group{:,3})],... 
        [std(ratingAcc_group{:,2})/sqrt(length(ratingAcc_group{:,2})),std(ratingAcc_group{:,3})/sqrt(length(ratingAcc_group{:,2}))],' ');
    
    %title ('Rating accuracy');
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average rating error', '(|Instructed value - Value ratings|)'}); % y-axis label
    ylim ([0, 10]);
    xlim ([0.2 2.8]);
   
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
    set(a1,'FontSize',16)
    set(a1,'FontSize',16)
    set(a1,'xtick',[])
    set(a1,'xtick',[])

    box off
%     % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(ratingAcc_group{:,2}, ratingAcc_group{:,3});
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
%     pos = get(a1, 'position');
%     annotation('textbox', 'String', ['p = ' num2str(p, 3) '  ' sig], 'Position', pos,...
%         'LineStyle', 'none', 'FontSize', 16);
    
    
 %% Reaction time
   % Group averages
%     a2 = subplot(1,2,2);
%     bar(1, mean(ratingRT_group{:,2}), 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
%     bar(2, mean(ratingRT_group{:,3}), 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
%     er = errorbar([1,2],[mean(ratingRT_group{:,2}), mean(ratingRT_group{:,3})],... 
%         [std(ratingRT_group{:,2})/sqrt(length(ratingRT_group{:,2})), std(ratingRT_group{:,3})/sqrt(length(ratingRT_group{:,2}))],' ');
%     
%     %title ('Reaction time');
%     xlabel('Configural     Elemental'); % x-axis label
%     ylabel({'Average rating reaction time (s)'}); % y-axis label
%     ylim ([1.5, 3]);
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
    
    
%     % Do Stats (paired sample ttest) to compare condition and display on graph
%     [h,p,ci,stats] = ttest(ratingRT_group{:,2}, ratingRT_group{:,3});
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
    %print(gcf1, '-dtiff', '../figures/figure_ACC_RT.tiff', '-r600');

 