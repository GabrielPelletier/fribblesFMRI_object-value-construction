%% Details

clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';


% What is the model indentifier?
modelID = 'model014-ppi';

% Which contrasts?
copes = [1 2 3];

% which seed
seeds = {'model013_cope6_vmpfc'};

%%

for seed_ind = 1:length(seeds)
    SEEDNAME = seeds{seed_ind};
    
    % Create folder for group analysis.
    group_folder = [main_path 'group/model/' modelID '-' SEEDNAME];
    if ~isfolder(group_folder); mkdir(group_folder); end

    for cope_ind = 1:length(copes)


        COPENUM=num2str(copes(cope_ind));

        fsf_name=['group_design_task-fribBids_ppi_seed-' SEEDNAME '_cope' COPENUM '.fsf'];


        template_in = fopen([main_path 'scripts/' modelID '_scripts/lvl3_task-fribBids_template_n42_3.1_wholeBrain.fsf']);
        fsf_out = fopen([main_path 'scripts/' modelID '_scripts/fsfs/lvl3/',fsf_name],'w');

        % Create folder if does not exist
        if ~exist([main_path 'scrips/' modelID '_scripts/fsfs/lvl3/'],'dir') 
            mkdir([main_path 'scripts/' modelID '_scripts/fsfs/lvl3/']);
        end    

        while ~feof(template_in)
            s = fgetl(template_in);
            s = strrep(s, 'COPENUM', COPENUM);
            s = strrep(s, 'MODELID', [modelID '-' SEEDNAME]);
            s = strrep(s, 'SEEDNAME', SEEDNAME);
            fprintf(fsf_out,'%s\n',s);
        end
        template_in=fclose(template_in);
        fsf_out=fclose(fsf_out);


    end %cope
end % seed