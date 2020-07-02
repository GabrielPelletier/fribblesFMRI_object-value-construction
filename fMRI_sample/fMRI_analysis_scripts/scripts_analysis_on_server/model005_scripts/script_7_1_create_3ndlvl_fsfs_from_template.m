%% Details

clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';


% What is the model indentifier?
modelID = 'model005';

% Which contrasts?
copes = [1 3 4 5 7 8 9 10];

%%

for cope_ind = 1:length(copes)
    
    
    COPENUM=num2str(copes(cope_ind));

    fsf_name=['group_design_task-fribBids_cope' COPENUM '.fsf'];

    
    template_in = fopen([main_path '/scripts/' modelID '_scripts/lvl3_task-fribBids_template_n43_2.3_noFMAP_wholeBrain.fsf']);
    fsf_out = fopen([main_path '/scripts/' modelID '_scripts/fsfs/lvl3/',fsf_name],'w');
    
    % Create folder if does not exist
    if ~exist([main_path 'scrips/' modelID '_scripts/fsfs/lvl3/'],'dir') 
        mkdir([main_path 'scripts/' modelID '_scripts/fsfs/lvl3/']);
    end    
            
    while ~feof(template_in)
        s = fgetl(template_in);
        s = strrep(s, 'COPENUM', COPENUM);
        fprintf(fsf_out,'%s\n',s);
    end
    template_in=fclose(template_in);
    fsf_out=fclose(fsf_out);
    
    
end %cope
