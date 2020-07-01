%% Gabriel Pelletie, March 2019
 
% Analysis of Eye Tracking data from Fribbles_fMRI experiment

% Plot Group Averages and individual data points

%%

function plotEyeTracking_group_byValue(groupEyeData)


% ***************************************************************************
%% Plot Num of Transitions

    gcf1 = figure('renderer', 'painters', 'Position', [100 100 600 400], ...
                   'Name', 'Number of within-object Transitions by Value');
               
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255];
    
% Single Subjects
    %a1 = subplot(1,2,1);
    legend_text = {};
    for i = 1:size(groupEyeData,1)
        legend_text{end+1} = num2str(groupEyeData.Subject_Num(i));
        line([1,2,3,4,5,6], [groupEyeData{i,3}(1), groupEyeData{i,3}(2), groupEyeData{i,3}(3), groupEyeData{i,3}(4), groupEyeData{i,3}(5), groupEyeData{i,3}(6)], 'Color', 'k');
        hold on
    end
    %scatter(repmat(1,1,size(groupEyeData,1)), groupEyeData.mean_TransPerTrial_conj, 70, 'MarkerEdgeColor', C_color, 'MarkerFaceColor', C_color, 'MarkerFaceAlpha', 0.5);
    %scatter(repmat(2,1,size(groupEyeData,1)), groupEyeData.mean_TransPerTrial_summ, 70,'MarkerEdgeColor', E_color, 'MarkerFaceColor', E_color, 'MarkerFaceAlpha', 0.5);
    hold off
    title ('All participants');
    xlim ([0.5 2.5]);
    xlim ([0.2 2.8]);
    xlabel('Configural     Elemental'); % x-axis label
    ylabel({'Average number of transitions', 'per trial',''}); % y-axis label
    %ylim ([0, 8]);
    yl = ylim; % Get the limit that was set automatically based on the data.
    %legend(legend_text);

    
% Group averages
    %a2 = subplot(1,2,2);

    y = [nanmean(groupEyeData{:,3}(:,1)) nanmean(groupEyeData{:,4}(:,1)); 
         nanmean(groupEyeData{:,3}(:,2)) nanmean(groupEyeData{:,4}(:,2));
         nanmean(groupEyeData{:,3}(:,3)) nanmean(groupEyeData{:,4}(:,3)); 
         nanmean(groupEyeData{:,3}(:,4)) nanmean(groupEyeData{:,4}(:,4))
         nanmean(groupEyeData{:,3}(:,5)) nanmean(groupEyeData{:,4}(:,5)); 
         nanmean(groupEyeData{:,3}(:,6)) nanmean(groupEyeData{:,4}(:,6))];

    b = bar(y);
    set(gca, 'xticklabel', {'30'; '40'; '50'; '70'; '80'; '90'});
    b(1).FaceColor = [C_color];
    b(2).FaceColor = [E_color];

    xlabel('Value (NIS)'); % x-axis label
    ylabel('Number of Transitions'); % y-axis label
    %ylim(yl); % Set this graph's axis limit to fit the other graph.

    set(gca,'FontSize',18)
    box off    


%     er = errorbar([1,2],[mean(groupEyeData.mean_TransPerTrial_conj), mean(groupEyeData.mean_TransPerTrial_summ)],[std(groupEyeData.mean_TransPerTrial_conj),std(groupEyeData.mean_TransPerTrial_summ)],' ');
%     er.Color = [0 0 0];                            
%     er.LineStyle = 'none';  
%     er.LineWidth = 2;
%     er.CapSize = 0;


    

    % Save high-res image in .tiff format
    %print(gcf1, '-dtiff', '../../figures/eye_transition.tiff', '-r600');



% ***************************************************************************
%% Plot Number of Fixations


    gcf2 = figure('renderer', 'painters', 'Position',[100 100 600 400], ...
                   'Name', 'Number of Fixation per Trial By Value');
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    y = [nanmean(groupEyeData{:,5}(:,1)) nanmean(groupEyeData{:,6}(:,1)); 
         nanmean(groupEyeData{:,5}(:,2)) nanmean(groupEyeData{:,6}(:,2));
         nanmean(groupEyeData{:,5}(:,3)) nanmean(groupEyeData{:,6}(:,3)); 
         nanmean(groupEyeData{:,5}(:,4)) nanmean(groupEyeData{:,6}(:,4))
         nanmean(groupEyeData{:,5}(:,5)) nanmean(groupEyeData{:,6}(:,5)); 
         nanmean(groupEyeData{:,5}(:,6)) nanmean(groupEyeData{:,6}(:,6))];

    b = bar(y);
    set(gca, 'xticklabel', {'30'; '40'; '50'; '70'; '80'; '90'});
    b(1).FaceColor = [C_color];
    b(2).FaceColor = [E_color];

    xlabel('Value (NIS)'); % x-axis label
    ylabel('Number of Fixations'); % y-axis label
    ylim([0 10]);

    set(gca,'FontSize',18)
    legend({'Configural' 'Elemental'}, 'FontSize', 16);
    box off    

    % Save high-res image in .tiff format
    %print(gcf1, '-dtiff', '../figures/figure_accuracy.tiff', '-r600');




   
% ***************************************************************************
%% Plot Duration of fixations

    gcf3 = figure('renderer', 'painters', 'Position',[100 100 600 400], ...
                   'Name', 'Average Duration of Invidual Fixations By Value');

    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255]; 
    
    y = [nanmean(groupEyeData{:,7}(:,1)) nanmean(groupEyeData{:,8}(:,1)); 
         nanmean(groupEyeData{:,7}(:,2)) nanmean(groupEyeData{:,8}(:,2));
         nanmean(groupEyeData{:,7}(:,3)) nanmean(groupEyeData{:,8}(:,3)); 
         nanmean(groupEyeData{:,7}(:,4)) nanmean(groupEyeData{:,8}(:,4))
         nanmean(groupEyeData{:,7}(:,5)) nanmean(groupEyeData{:,8}(:,5)); 
         nanmean(groupEyeData{:,7}(:,6)) nanmean(groupEyeData{:,8}(:,6))];

    b = bar(y);
    set(gca, 'xticklabel', {'30'; '40'; '50'; '70'; '80'; '90'});
    b(1).FaceColor = [C_color];
    b(2).FaceColor = [E_color];

    xlabel('Value (NIS)'); % x-axis label
    ylabel('Average Fixation Duration'); % y-axis label
    %ylim(yl); % Set this graph's axis limit to fit the other graph.

    set(gca,'FontSize',18)
    box off    

    % Save high-res image in .tiff format
    %print(gcf4, '-dtiff', '../figures/figure_accuracy.tiff', '-r600');


  
end