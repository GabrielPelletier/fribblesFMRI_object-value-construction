%%
% This script is ran after level-1 analysis, and before level-2 analysis.
% 
% Only use if the data was pre-processed using FMRIPrep before doing 
% anything in FSL.
% 
% It deletes and changes some files to "trick" FSL into skipping the
% registration, which was already done with FMRIPrep.
%
% Nadav Aridan, 2018
% Apadted by Gabriel Pelletier, April 2019
% -- Added a bit to delete any reg_standard folders if there are any.
%%

%clear
%%

% What is the model indentifier?
modelID = 'model013';

% Which participants do we run
participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];

%participants = [0408];
      
% Which task?
task_names = {'fribBids'};

% Which runs?
runs = [1 2 3 4];

%%

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    
    for task_ind = 1:length(task_names)
        TASKNAME=task_names{task_ind}
        
        for run_ind=runs
           RUNNUM=['0' num2str(runs(run_ind))]
           
          % WITH FMAP
          featpath=[main_path 'sub-' SUBNUM '/model/' modelID '/' 'task-',TASKNAME,'_run-' RUNNUM '.feat/' ];
%           % WITHOUT FMAP
%           featpath=[main_path 'sub-' SUBNUM '/model/' modelID '/' 'task-',TASKNAME,'_run-' RUNNUM '_noFMAP.feat/' ];           
           %delete reg_standar folder, if present
           if isfolder([featpath 'reg_standard'])
               text = sprintf('A "reg_standard" folder was found inside this .feat folder : %s \n The folder and its content have been deleted', featpath);
               disp(text);
               rmdir([featpath 'reg_standard'], 's');
           end
           
           %delete all mat files
           files=dir([featpath 'reg/*.mat']);
           for i=1: length(files)
           delete([featpath 'reg/' files(i).name])
           end

           %copy ident.mat to replace local 
           syscom=['cp /export/apps/fsl/etc/flirtsch/ident.mat ' featpath 'reg/example_func2standard.mat'];
           system(syscom);
                    
           %copy mean_func with standard
           syscom=['cp ' featpath 'mean_func.nii.gz ' featpath 'reg/standard.nii.gz'];
           system(syscom);
          
        end %run
    end %task
end %sub