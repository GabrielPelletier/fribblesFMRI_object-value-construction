%% Check if EyeTracker stimulus onset times and 
% task stimulus onset times correspond

subjectNumber = 115;
run = 1;


eyefilename = [num2str(subjectNumber),'_eyeData_run',num2str(run),'.mat'];
taskfilename = [num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(run),'.mat'];
load([pwd,'/Data/',num2str(subjectNumber),'/',num2str(subjectNumber),'_subRunInfo_',num2str(run),'.mat']);

load([pwd,'/Data/',num2str(subjectNumber),'/',eyefilename]);
load([pwd,'/Data/',num2str(subjectNumber),'/',taskfilename]);


runOnInd = find(strcmp(eyeData.triggers.type, 'RUNSYNCTIME'));
eyeRunOnset = eyeData.triggers.time(runOnInd);

eyeStimOnsets_refRun = eyeData.TimeOfInterest(1,:) - eyeRunOnset; % In millisec

% Extract Only Trials that were evaluated
    ratingInd = find(strcmp(ratingData(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = ratingData(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,10:11) = ratingData(ratingInd(i)-1, 10:11);
        ratingTrialsData(end,7:9) = ratingData(ratingInd(i), 7:9);
        ratingTrialsData(end,12:13) = ratingData(ratingInd(i), 12:13);
    end

taskStimOnsets = cell2mat(ratingTrialsData(:,10))'; % IN sec
taskStimOnsets = taskStimOnsets * 1000 ;% in millisec

%eyeTrialInd = find(contains(eyeData.triggers.type, 'TrialID'));
%eyeTrialOnset = eyeData.triggers.time(eyeTrialInd);
%eyeTrialOnset1 = eyeTrialOnset(1:2:end); % Skip the rating trials

%eyeStimOnsets_refTrial = eyeData.TimeOfInterest(1,:) - eyeTrialOnset1; % In millisec

diff = taskStimOnsets - eyeStimOnsets_refRun;

