%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%

                % Main script for Fribbles_fMRI experiment %      
                          % FMRI BIDING PHASE %
                                %=%%=%%=% 
                                   
%=%%=%%             Script by Gabriel Pelletier, 2018               %=%%=%%
%                      (Last update Feb, 2018)                         %

                                %=%%=%%=%    
%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%
%%%%%                                                                 %%%%%    
%                    %%% === Script structure === %%%                     % 

%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%%=%=%%=%%=%%=%%=%%=%%=%%=%%=%%


rng('shuffle');


ListenChar();


%% How many runs?
numRuns = 4;


% Are we scanning (1=yes, 0=no)
Scan = 1;


%% Psychtoolbox stuff
Screen('Preference', 'SkipSyncTests', 0); % For laptop, skip sync test (-1).
Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
commandwindow;


%% Session parameters


% Ask for subject Number and get subject Information
subjectNumber =  input('\nSubject number: ');
okID = subjectNumber < 999 && subjectNumber > 100;
while okID==0
    disp('ERROR: Subject number must contain only numbers between 100 and 999. Please try again.');
    subjectNumber = input('Subject number:');
    okID = subjectNumber < 999 && subjectNumber > 100;
end


% What language for instructions?
oklang = [1 0];
ask_what_language = input('\nWhat language for the instructions? 1-HEB, 0-ENG : ');
    while isempty(ask_what_language) || sum(oklang == ask_what_language) ~=1
        disp('ERROR: input must be 0(HEB) or 1(ENG). Please try again.');
        ask_what_language = input('\nWhat language for the instructions? 1-HEB, 0-ENG : ');
    end
if ask_what_language == 1
   language = 'Hebrew';
elseif ask_what_language == 0 
   language = 'English';
end


okhow_many_runs = [1 2 3 4];
how_many_runs = input('\nHow many RUNS do you want to run (normally 4)? Enter 1 to 4: ');
while isempty(how_many_runs) || sum(okhow_many_runs == how_many_runs) ~=1
      disp('ERROR: input must be 1 to 4. Please try again.');
      how_many_runs = input('Enter run 1 to 4:');
end
numRuns = how_many_runs;


%
fprintf('\nNow loading files, pleas wait...\n');

% Output folder
outFolder = [pwd,'/Output/'];


% Folder for Instruction (depends on Language)
instructionFolder = [pwd,'/Instructions/',language,'/'];


% Stimuli folder
stimFolder = [pwd,'/Stimuli/RatingTask/'];
 

% Load the subject's predefined stimulus sequences (1 per run)
load('runSequences_v5.mat');
stimSequences = runSequences_v5{subjectNumber,1}.runs;


% Load one OnsetTime list for each run
onsetLists = [];
randNums = randperm(6); % We have 8 pre-defined sequences to choose from
for nr = 1 : numRuns
    % Choose a random onsetTime list from the pre-defined ones
    load([pwd,'/onset_lists/bids_onset_length_48_',num2str(randNums(nr)),'.mat']);
    onsetlist = onsetlist';
    onsetLists = [onsetLists, onsetlist];
end



%% Run task
for runCount = 1 : numRuns
    
    checkInfo = 0;
    while checkInfo ~= 1 
    % Which run to do next?
     okRun = [1 2 3 4];
     fprintf('\nNext, we would normally be running RUN # %d out of %d .\n', runCount, numRuns);
     which_run = input('Which run # do you want to run next? Enter run 1 to 4: ');
        while isempty(which_run) || sum(okRun == which_run) ~=1
            disp('ERROR: input must be 1 to 4. Please try again.');
            which_run = input('Enter run 1 to 4:');
        end
     run = which_run;
    
    % Do we use EyeTraking during this run?
     okEyetracker = [1 0];
     ask_if_want_eyetracker = input('\nDo you want eyetracking (1 - yes, 0 - no): ');
        while isempty(ask_if_want_eyetracker) || sum(okEyetracker == ask_if_want_eyetracker) ~=1
            disp('ERROR: input must be 1 or 0. Please try again.');
            ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
        end
      eyeTracking=ask_if_want_eyetracker; % set to 1/0 to turn on/off eyetracker functions
      
    % Double-check if this Infomration is ok before we run
    okCheck = [1 0];
    fprintf('\n\nVerify the following information:\n');
    fprintf('Subject number is : %d \n', subjectNumber);
    fprintf('Are we Scanning? %d \n', Scan);
    fprintf('We are now runnin RUN # %d on a total of %d \n', run, numRuns);
    fprintf('Eye-Tracking: %d.\n', eyeTracking);
    checkInfo = input('If this Information correct? (1 - yes, 0 - no): ');
    end
    
    % Stim and onset lists for this run
    runSeq = stimSequences(run).stimList;
    runOnsetTimes = onsetLists(:,run);

    % Run the task
    ListenChar(-1);
    BB_bidTask_run(subjectNumber, language, run, runSeq, runOnsetTimes, stimFolder, outFolder, eyeTracking, Scan);
    ListenChar(1);
    
end

% Experiment is over
sca;
ShowCursor();
PsychHID('KbQueueStop');


% Shutdown the Eyetracker
if eyeTracking == 1
    Eyelink('Shutdown');
end
% % 
% % 
% % % Resolve the Auctions and show Bonus amount
% % auctionResolve(subjectNumber, numRuns);

% Re-enable all keys
DisableKeysForKbCheck([]);
% Re-Organize text datafiles
organizeBidsDataText(subjectNumber, outFolder, numRuns);
% Copy file to dropbox
try
    send_data_to_dropbox(num2str(subjectNumber), outFolder)
catch
    fprintf('Failed to move the data files to Dropbox');
end