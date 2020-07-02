%%
% This script takes the template from the Feat GUI second level analysis
% (averaging runs within each subject)
% It changes the relevant files and folder names for each participant
% number.
% 

%% Details

clear

% What is the model indentifier?
modelID = 'model014-ppi';

% Which participant(s)
participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];

% Which seeds
seeds = {'model013_cope6_vmpfc'};

% Which task?
tasknames = {'fribBids'};

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

%%
%! delete previous files
for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    
    for task_ind = 1: length(tasknames)
        TASKNAME = tasknames{task_ind}
        
        for seed_ind = 1:length(seeds)
            SEEDNAME = seeds{seed_ind}
            
            fsf_name=['design_sub-' SUBNUM '_task-' TASKNAME '_ppi_seed-' SEEDNAME '.fsf'];
            
            template_in = fopen([main_path,'scripts/',modelID, '_scripts/lvl2_task-',TASKNAME,'_ppi_template.fsf']);
            
            % Create folder if does not exist
             if ~exist([main_path,'scrips/',modelID,'_scripts/fsfs/lvl2/'],'dir') 
                 mkdir([main_path,'scripts/',modelID,'_scripts/fsfs/lvl2/']); 
             end    
             
            fsf_out = fopen([main_path,'scripts/' modelID,'_scripts/fsfs/lvl2/' fsf_name],'w');
                
            while ~feof(template_in)
                s = fgetl(template_in);
                s = strrep(s, 'SUBNUM', SUBNUM);
                s = strrep(s, 'SEEDNAME', SEEDNAME);
                fprintf(fsf_out,'%s\n',s);
            end
            template_in=fclose(template_in);
            fsf_out=fclose(fsf_out);
            
        end %seed  
    end %task
end %sub