function plotEyeTracking_by_run(lvl1_derivatives)

% Colors for plotting Configural and Elemental Condition
    C_color = [255/255 168/255 1/255];    
    E_color = [255/255 82/255 82/255];

%% Plot Num of Transitions

    gcf1 = figure('renderer', 'painters', 'Position',[100 100 600 450], ...
                   'Name', 'Number of within-object Transitions By Run');
                
% Group averages
    a1 = subplot(1,1,1);
    mean_conj1 =  mean(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 1));
    mean_conj2 =  mean(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 2));
    mean_conj3 =  mean(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 3));
    mean_conj4 =  mean(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 4));
    
    mean_summ1 =  mean(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 1));
    mean_summ2 =  mean(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 2));
    mean_summ3 =  mean(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 3));
    mean_summ4 =  mean(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 4));
    
    bar(1, mean_conj1, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean_summ1, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(4, mean_conj2, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(5, mean_summ2, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(7, mean_conj3, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(8, mean_summ3, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(10, mean_conj4, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(11, mean_summ4, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
% Error bars (SEM)      
    sem_conj1 = std(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 1)));
    sem_conj2 = std(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 2)));
    sem_conj3 = std(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 3)));
    sem_conj4 = std(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.TransPerTrial_conj(lvl1_derivatives.Run_Num == 4)));
    sem_summ1 = std(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 1)));
    sem_summ2 = std(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 2)));
    sem_summ3 = std(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 3)));
    sem_summ4 = std(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.TransPerTrial_summ(lvl1_derivatives.Run_Num == 4)));
  
    er = errorbar([1,2,4,5,7,8,10,11],[mean_conj1, mean_summ1, mean_conj2, mean_summ2, mean_conj3, mean_summ3, mean_conj4, mean_summ4], ...
        [sem_conj1, sem_summ1, sem_conj2, sem_summ2, sem_conj3, sem_summ3, sem_conj4, sem_summ4], ' ');
    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
%title ('Group average');
ylabel({'Average number of transitions', 'per trial per run'}); % y-axis label
%ylim ([0, 3]);
%xlim ([0.2 2.8]);
set(a1,'FontSize',20)
set(a1,'xtick',[1.5 4.5 7.5 10.5], 'xticklabels', {'Run1', 'Run2', 'Run3', 'Run4'})  
box off


%% Plot Num of Fixations

    gcf2 = figure('renderer', 'painters', 'Position',[100 100 600 450], ...
                   'Name', 'Number of Fixations by Trial by Run');
                
% Group averages
    a1 = subplot(1,1,1);
    mean_conj1 =  mean(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 1));
    mean_conj2 =  mean(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 2));
    mean_conj3 =  mean(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 3));
    mean_conj4 =  mean(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 4));
    
    mean_summ1 =  mean(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 1));
    mean_summ2 =  mean(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 2));
    mean_summ3 =  mean(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 3));
    mean_summ4 =  mean(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 4));
    
    bar(1, mean_conj1, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean_summ1, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(4, mean_conj2, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(5, mean_summ2, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(7, mean_conj3, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(8, mean_summ3, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(10, mean_conj4, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(11, mean_summ4, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
% Error bars (SEM)      
    sem_conj1 = std(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 1)));
    sem_conj2 = std(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 2)));
    sem_conj3 = std(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 3)));
    sem_conj4 = std(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.NumFixPerTrial_conj(lvl1_derivatives.Run_Num == 4)));
    sem_summ1 = std(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 1)));
    sem_summ2 = std(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 2)));
    sem_summ3 = std(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 3)));
    sem_summ4 = std(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.NumFixPerTrial_summ(lvl1_derivatives.Run_Num == 4)));
  
    er = errorbar([1,2,4,5,7,8,10,11],[mean_conj1, mean_summ1, mean_conj2, mean_summ2, mean_conj3, mean_summ3, mean_conj4, mean_summ4], ...
        [sem_conj1, sem_summ1, sem_conj2, sem_summ2, sem_conj3, sem_summ3, sem_conj4, sem_summ4], ' ');
    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
%title ('Group average');
ylabel({'Average number of Fixations', 'per trial per run'}); % y-axis label
%ylim ([0, 3]);
%xlim ([0.2 2.8]);
set(a1,'FontSize',20)
set(a1,'xtick',[1.5 4.5 7.5 10.5], 'xticklabels', {'Run1', 'Run2', 'Run3', 'Run4'})  
box off

%% Plot Duration of fixations

    gcf3 = figure('renderer', 'painters', 'Position',[100 100 600 450], ...
                   'Name', 'Average Duration of Invidual Fixations by Run');
                
% Group averages
    a1 = subplot(1,1,1);
    mean_conj1 =  mean(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 1));
    mean_conj2 =  mean(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 2));
    mean_conj3 =  mean(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 3));
    mean_conj4 =  mean(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 4));
    
    mean_summ1 =  mean(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 1));
    mean_summ2 =  mean(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 2));
    mean_summ3 =  mean(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 3));
    mean_summ4 =  mean(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 4));
    
    bar(1, mean_conj1, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(2, mean_summ1, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(4, mean_conj2, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(5, mean_summ2, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(7, mean_conj3, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(8, mean_summ3, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
    bar(10, mean_conj4, 0.8, 'FaceColor', C_color, 'EdgeColor', C_color); hold on
    bar(11, mean_summ4, 0.8, 'FaceColor', E_color, 'EdgeColor', E_color); hold on
% Error bars (SEM)      
    sem_conj1 = std(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 1)));
    sem_conj2 = std(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 2)));
    sem_conj3 = std(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 3)));
    sem_conj4 = std(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.AveFixDur_conj(lvl1_derivatives.Run_Num == 4)));
    sem_summ1 = std(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 1))/sqrt(length(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 1)));
    sem_summ2 = std(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 2))/sqrt(length(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 2)));
    sem_summ3 = std(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 3))/sqrt(length(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 3)));
    sem_summ4 = std(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 4))/sqrt(length(lvl1_derivatives.AveFixDur_summ(lvl1_derivatives.Run_Num == 4)));
  
    er = errorbar([1,2,4,5,7,8,10,11],[mean_conj1, mean_summ1, mean_conj2, mean_summ2, mean_conj3, mean_summ3, mean_conj4, mean_summ4], ...
        [sem_conj1, sem_summ1, sem_conj2, sem_summ2, sem_conj3, sem_summ3, sem_conj4, sem_summ4], ' ');
    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    er.LineWidth = 2;
    er.CapSize = 0;
    
%title ('Group average');
ylabel({'Average duration' 'of individual fixations by Run (ms)'});
%ylim ([0, 3]);
%xlim ([0.2 2.8]);
set(a1,'FontSize',20)
set(a1,'xtick',[1.5 4.5 7.5 10.5], 'xticklabels', {'Run1', 'Run2', 'Run3', 'Run4'})  
box off

end