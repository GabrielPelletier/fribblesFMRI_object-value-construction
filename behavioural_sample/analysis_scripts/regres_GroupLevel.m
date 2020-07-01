function regres_GroupLevel(group_data, plot_groupRegression)

    if plot_groupRegression
         
          gcf1 = figure('renderer', 'painters', 'Position',[100 100 700 350], ...
                        'Name', 'BIDS - GROUP REGRESSION BY CONDITION');

        
        % Change data to long format (and loosing Subject-ID)
        value_rating_conj = [];
        value_rating_summ = [];
        %value_rt_conj = [];
        %value_rt_summ = [];
        true_value = [];
        for i = 1 : size(group_data.conj_Acc, 2)
            value_rating_conj = [value_rating_conj ; group_data.conj_Acc(:,i)];
            value_rating_summ = [value_rating_summ ; group_data.summ_Acc(:,i)];
            true_value = [true_value ; 30; 40; 50; 70; 80; 90];
            %value_rt_conj = [value_rt_conj ; group_data.conj_Rt(:,i)];
            %value_rt_summ = [value_rt_summ ; group_data.summ_Rt(:,i)];
        end
        
        value_rating = [value_rating_conj ; value_rating_summ]; % Conj then summ
        %rt_rating = [value_rt_conj ; value_rt_summ];
        condition = [repmat({'Configural'} ,length(value_rating_conj), 1) ; repmat({'Elemental'} ,length(value_rating_summ), 1)]; % Conj then Summ
        true_value = [true_value ; true_value];
        
        %% Accuracy plot
        % Create the gramm object
        g = gramm('x', true_value, 'y', value_rating, 'color', condition);

        
        % Make one sub-plot for each condition
        g.facet_grid([], condition);
        % Plot the individual data points
        g.geom_point('alpha', 0.5);
        g.set_point_options('base_size', 8, 'markers', {'o'});

        % Make the linear regression with CI
        g.stat_glm();
        
        
        % Visual stuff
        % Set appropriate names for legends
        g.set_names('column', '', 'x','Instructed value (NIS)','y','Value Ratings (NIS)', 'color', 'condition');
        g.set_layout_options('legend', false);
        
        g.set_color_options('map', [1,0.6588,0.0039;
                            1,0.6588,0.0039;
                            1,0.3216,0.3216;
                            1,0.3216,0.3216], 'n_color', 2, 'n_lightness', 2);
        
        g.set_text_options('base_size', 16);
        
        g.axe_property('YLim', [25 95], 'YTick', [30, 40, 50, 60, 70, 80, 90], 'XLim', [25 95], 'XTick', [30, 40, 50, 60, 70, 80, 90]);
        
        % Draw the figure
        g.draw();
        
        set(g.results.geom_point_handle(1),'MarkerEdgeColor', [255/255 168/255 1/255]);
        set(g.results.geom_point_handle(1),'MarkerFaceColor', 'none');
        set(g.results.geom_point_handle(2),'MarkerEdgeColor', [255/255 82/255 82/255]);
        set(g.results.geom_point_handle(2),'MarkerFaceColor', 'none');
        
        % Save high-res image in .tiff format
        print(gcf1, '-dtiff', 'bidding_RatingByValue_behaviorSample.tiff', '-r600');
        
       
        
        
        
        
        
        
%         %% Reacton times plot
%         gcf2 = figure('renderer', 'painters', 'Position',[100 100 700 350], ...
%                         'Name', 'BIDS - GROUP REGRESSION BY CONDITION');
%         gg = gramm('x', true_value, 'y', rt_rating, 'color', condition);
%         % Make one sub-plot for each condition
%         gg.facet_grid([], condition);
%         % Plot the individual data points
%         gg.geom_point('alpha', 0.5);
%         gg.set_point_options('base_size', 8);
%         
%         gg.stat_boxplot()
%         
%         % Visual stuff
%         % Set appropriate names for legends
%         gg.set_names('column', '', 'x','Instructed value (NIS)','y','Reaction time (s)', 'color', 'condition');
%         gg.set_layout_options('legend', false);
%         
%         gg.set_color_options('map', [1,0.6588,0.0039;
%                             1,0.6588,0.0039;
%                             1,0.3216,0.3216;
%                             1,0.3216,0.3216], 'n_color', 2, 'n_lightness', 2);
%         
%         gg.set_text_options('base_size', 16);        
%         
%         gg.axe_property('YLim', [1 3], 'YTick', [1, 1.5, 2, 2.5, 3], 'XLim', [25 95], 'XTick', [30, 40, 50, 60, 70, 80, 90]);
%         
%         % Draw the figure
%         gg.draw();
%         % Save high-res image in .tiff format
%         print(gcf2, '-dtiff', '../figures/bidding_RTByValue_fMRIsample.tiff', '-r600');
    end
    
    
end