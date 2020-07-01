% little loop to regroup some data


main_path = 'C:\Users\Labuser\Desktop\GabrielP\fribbles_fmri\fmri_sample\behav_eye_data/';
bids_dataPath = [main_path 'fribBids_bidding/'];

subs = [402 405 406 407 408 410 411 412 413 417 418 419 421 428 429 430 ...
      431 432 433 434 435 436 437 438 439 440 441 443 444 446 447 448 454];
%subs = 407
runs = [1 2 3 4];

all_trials_eyeData = [];

for s = 1 : length(subs)
     subID = ['sub-0' (num2str(subs(s)))];
    
    for r = 1 : length(runs)
        this_run = runs(r);
    
        eyeDataFile = [bids_dataPath subID '/' num2str(subs(s)) '_eyeData_run' num2str(this_run) '.mat'];
        load(eyeDataFile);
        
        all_trials_eyeData = [all_trials_eyeData; eyeData.trial_fixation_summary];
    end
end