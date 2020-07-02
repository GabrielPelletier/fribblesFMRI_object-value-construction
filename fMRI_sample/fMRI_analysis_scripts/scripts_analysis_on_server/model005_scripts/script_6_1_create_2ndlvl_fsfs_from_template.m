%%
% This script takes the template from the Feat GUI second level analysis
% (averaging runs within each subject)
% It changes the relevant files and folder names for each participant
% number.
% 

%% Details

clear

% What is the model indentifier?
modelID = 'model005';

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

% Which participant(s)
participants = [454];

% Which task?
% Change this depending on the task you are building the .fsf files for.
%taskname = 'fribBids';
tasknames = {'fribBids'};


%%
%! delete previous files
for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    
    for task_ind = 1: length(tasknames)
        TASKNAME = tasknames{task_ind}

            fsf_name=['design_sub-',SUBNUM,'_task-',TASKNAME,'.fsf'];
%           %WITH FMAP            
%           template_in = fopen([main_path,'scripts/',modelID, '_scripts/lvl2_task-',TASKNAME,'_template.fsf']);

%           WITHOUT FMAP
            template_in = fopen([main_path,'scripts/',modelID, '_scripts/lvl2_task-',TASKNAME,'_template_noFMAP.fsf']);
            
            % Create folder if does not exist
             if ~exist([main_path,'scrips/',modelID,'_scripts/fsfs/lvl2/'],'dir') 
                 mkdir([main_path,'scripts/',modelID,'_scripts/fsfs/lvl2/']); 
             end    
             
            fsf_out = fopen([main_path,'scripts/',modelID,'_scripts/fsfs/lvl2/',fsf_name],'w');
                
            while ~feof(template_in)
                s = fgetl(template_in);
                s = strrep(s, 'SUBNUM', SUBNUM);

                fprintf(fsf_out,'%s\n',s);
            end
            template_in=fclose(template_in);
            fsf_out=fclose(fsf_out);
            
    end %task
end %sub