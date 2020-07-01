
function spss_rm_format = create_spss_csv(lvl1_derivatives)

all_runs = [1 2 3 4];
all_subs = unique(lvl1_derivatives(:,1));
var_names = lvl1_derivatives.Properties.VariableNames;
var_names = var_names(3:end); % Remove subject and run num

% Will hold the data in the new format
spss_rm_format = zeros(height(all_subs), 2+length(all_runs)*length(var_names));

for s = 1:height(all_subs)
    subject = all_subs{s,1};
    spss_rm_format(s,1) = subject;
    
    for v = 1:length(var_names)
        for run = all_runs  
        index_row = find(lvl1_derivatives.Subject_Num == subject & lvl1_derivatives.Run_Num == run);
        index_column = 2 + (v-1)*4 + run;   
        spss_rm_format(s, index_column) = lvl1_derivatives{index_row, v+2};
        
        end
    end
end

csvwrite('eyeTrackingData_spss_rm_format.csv', spss_rm_format);

end
