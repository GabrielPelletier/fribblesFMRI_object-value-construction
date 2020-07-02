%% delete level 1 Feat directories

participants = [0309 0311 0402 0403 0405 0406 0407 0408 ...
          0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
          0421 0422 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
          0445 0446 0447 0448 0449 0450 0452 0453 0454];    
      
      participants = [0454 0453 0452];
      
runs = [1 2 3 4];
      
main_path = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))];

    for run_ind = 1 : length(runs)
        RUNNUM = ['0' num2str(runs(run_ind))];
    %
    %    delete ([main_path 'sub-' SUBNUM '/model/model015-ppi-model013_cope6_vmpfc/onsets/task-fribBids_run-' RUNNUM '/ppi_regressor_model013_cope6_vmpfc_SumRate.txt'])
    
    [SUCCESS,MESSAGE,MESSAGEID] = rmdir([main_path 'sub-' SUBNUM '/model/model015-ppi-model013_cope6_vmpfc/task-fribBids_run-' RUNNUM '.feat'], 's')
        
    end
end