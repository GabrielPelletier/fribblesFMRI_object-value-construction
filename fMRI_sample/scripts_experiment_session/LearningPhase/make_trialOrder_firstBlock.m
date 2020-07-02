% make trialOrder_Summ_Stim[stimulus set number]
% and trialOrder_Conj_Stim[stimulus set number]

% Manually changing and double-checking every stimulus-value.
% Triple-check please after changes.

load('trialOrder_Conj_Stim4.mat');
save('trialOrder_Conj_Stim4_v1.mat', 'trialOrder');



for i = 1 : length(trialOrder)
    
    if trialOrder{i,2} == 10
        trialOrder{i,1} = 'Fa3_1331_Y.jpg';
    end
        
end


save('trialOrder_Conj_Stim4_v2.mat', 'trialOrder');