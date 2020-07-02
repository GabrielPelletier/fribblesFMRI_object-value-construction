%% Organize events in 3-collumns-vectors
%  for fmri data analysis
%
% fLoc (functionnal localizer)
%
%%
% cond001.txt = faces
% cond002.txt = scenes 
% cond003.txt = objects 
% cond004.txt = scrambled objects
%%

subjects = [0309 0310 0401 0402 0403 0404 0406 0407 0408 ...
          0409 0410 0411 0412 0413 0414 0415 0416 0417 0418 0419 ...
          0421 0422 0425 0426 0427 0428 0429 0430 0431 0432 ...
          0433 0434 0435 0436 0437 0438 0439 0440 0441 0442 0443 0444 ...
          0445 0446 0447 0449 0450 0452 0453 0454];
runs = [1 2 3 4];

% main dir
rootDir = '/export2/DATA/FRIB_FMRI/fmri_sample';

% Where are the model .tsv (bids format) files?
bidsDir = [rootDir,'/BIDS/'];

% Where are the model TCV files going to be sent?
derivativesDir = [rootDir,'/derivatives/'];

% Model ID Number
modelNUM = '001';


for subjectNumber = subjects
    
    subjectFileCode  = ['0',num2str(subjectNumber)];
    
    % Create subfolder for subject (if already exists it will just be
    % skip)
    if ~exist([derivativesDir,'fLoc/sub-',subjectFileCode],'dir') mkdir([derivativesDir,'fLoc/sub-',subjectFileCode]); end
    if ~exist([derivativesDir,'fLoc/sub-',subjectFileCode,'/model'],'dir') mkdir([derivativesDir,'fLoc/sub-',subjectFileCode,'/model']); end
    if ~exist([derivativesDir,'fLoc/sub-',subjectFileCode,'/model/model' modelNUM],'dir') mkdir([derivativesDir,'fLoc/sub-',subjectFileCode,'/model/model' modelNUM]); end
    if ~exist([derivativesDir,'fLoc/sub-',subjectFileCode,'/model/mode' modelNUM '/onsets'],'dir') mkdir([derivativesDir,'fLoc/sub-',subjectFileCode,'/model/model' modelNUM '/onsets']); end
    
    for rr = runs
        
        filename = [bidsDir,'sub-',subjectFileCode,'/func/','sub-',subjectFileCode,'_task-fLoc_run-0',num2str(rr),'_events.tsv'];

        % The onsets TCV files will land there:
        endFolder = [derivativesDir 'fLoc/sub-' subjectFileCode '/model/model' modelNUM '/onsets/task-fLoc_run-0' num2str(rr)];
        mkdir(endFolder);

        T = tdfread(filename);
        bloc_type = cellstr(T.bloc_type); % Format conversion for condition

        % Get each blocks durations: roughly all the same
        for bb = 1:length(T.onset)-1
            durations(bb,1) = T.onset(bb+1)-T.onset(bb);
        end
        
        % Get onsets separately for each condition and write txt files
            for i = 1:4
                % e.g. Cond001, faces
                ind = find(T.bloc_typeCode == i);
                M = [T.onset(ind), durations(ind), ones(length(ind),1)];
                dlmwrite([endFolder,'/cond00', num2str(i), '.txt'], M , 'delimiter','\t');
                %dlmwrite(['cond00', num2str(i), '.txt'], M , 'delimiter','\t');
            end
    
    end
end