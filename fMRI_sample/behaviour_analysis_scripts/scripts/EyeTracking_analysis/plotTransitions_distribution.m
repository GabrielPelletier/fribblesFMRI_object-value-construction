function plotTransitions_distribution(lvl2_derivatives)

C_color = [255/255 168/255 1/255];    
E_color = [255/255 82/255 82/255]; 
%%
gcf1 = figure('renderer', 'painters', 'Position',[100 100 500 450], ...
                   'Name', 'Distributions for Number of Fixations');

h1 = histogram(lvl2_derivatives.mean_NumFixPerTrial_conj, 7, 'FaceColor', C_color);
hold on
histogram(lvl2_derivatives.mean_NumFixPerTrial_summ, h1.BinEdges, 'FaceColor', E_color);

xlabel('Average Number of Fixations', 'FontSize', 18); % x-axis label
ylabel('Numer of Participants', 'FontSize', 18); % y-axis label
legend({'Configural', 'Elemental'}, 'FontSize', 16);
box off
%%
gcf2 = figure('renderer', 'painters', 'Position',[100 100 500 450], ...
                   'Name', 'Distributions for Number of Transitions');

h1 = histogram(lvl2_derivatives.mean_TransPerTrial_conj, 7, 'FaceColor', C_color);
hold on
histogram(lvl2_derivatives.mean_TransPerTrial_summ, h1.BinEdges, 'FaceColor', E_color);

xlabel('Average Number of Transitions', 'FontSize', 18); % x-axis label
ylabel('Numer of Participants', 'FontSize', 18); % y-axis label
legend({'Configural', 'Elemental'}, 'FontSize', 16);
box off
%%
gcf3 = figure('renderer', 'painters', 'Position',[100 100 500 450], ...
                   'Name', 'Distributions for Fixations Duration');

h2 = histogram(lvl2_derivatives.mean_AveFixDur_conj, 7, 'FaceColor', C_color);
hold on
histogram(lvl2_derivatives.mean_AveFixDur_summ, h2.BinEdges, 'FaceColor', E_color);

xlabel('Average Fixation Duration (ms)', 'FontSize', 18); % x-axis label
ylabel('Numer of Participants', 'FontSize', 18); % y-axis label
legend({'Configural', 'Elemental'}, 'FontSize', 16);
box off
    
end
