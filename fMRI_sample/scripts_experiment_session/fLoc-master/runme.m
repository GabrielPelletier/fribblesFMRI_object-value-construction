function runme(name, trigger, stim_set, num_runs, task_num, start_run, language)
% Prompts experimenter for session parameters and executes functional
% localizer experiment used to define regions in high-level visual cortex
% selective to faces, places, bodies, and printed characters.
%
% Inputs (optional):
%   1) name -- session-specific identifier (e.g., particpant's initials)
%   2) trigger -- option to trigger scanner (0 = no, 1 = yes)
%   3) stim_set -- stimulus set (1 = standard, 2 = alternate, 3 = both)
%   4) num_runs -- number of runs (stimuli repeat after 2 runs/set)
%   5) task_num -- which task (1 = 1-back, 2 = 2-back, 3 = oddball)
%   6) start_run -- run number to begin with (if sequence is interrupted)
%
% Version 3.0 8/2017
% Anthony Stigliani (astiglia@stanford.edu)
% Department of Psychology, Stanford University

% Psychtoolbox stuff
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebuglevel', 0); % No PTB intro screen, no sync warning
ListenChar();

%% add paths and check inputs

addpath('functions');
if nargin < 2
    
% Ask for subject Number and get subject Information
subjectNumber =  input('\nSubject number: ');
okID = subjectNumber < 999 && subjectNumber > 100;
while okID==0
    disp('ERROR: Subject number must contain only numbers between 100 and 999. Please try again.');
    subjectNumber = input('Subject number:');
    okID = subjectNumber < 999 && subjectNumber > 100;
end
name = num2str(subjectNumber);
end


% option to trigger scanner
if nargin < 2
    trigger = -1;
    while ~ismember(trigger, 0:1)
        trigger = input('\nTrigger scanner? (0 = no, 1 = yes) : ');
    end
end

% which stimulus set/s to use == 4, custom
if nargin < 3
    stim_set = 4;
    %while ~ismember(stim_set, 1:4)
    %    stim_set = input('Which stimulus set? (1 = standard, 2 = alternate, 3 = both, 4 = custom) : ');
    %end
end

% number of runs to generate
if nargin < 4
    num_runs = -1;
    while ~ismember(num_runs, 1:24)
        num_runs = input('\nHow many runs? : ');
    end
end

% which task to use, always 1-back in our case (GP march 2018)
if nargin < 5
%     task_num = -1;
%     while ~ismember(task_num, 1:3)
%         task_num = input('\nWhich task? (1 = 1-back, 2 = 2-back, 3 = oddball) : ');
%     end
    task_num = 1;     
end

% which run number to begin executing (default = 1)
if nargin < 6
    start_run = input('\nWhich run to begin? : ');
end

% which language for the instructions
if nargin < 7
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
end


%% initialize session object and execute experiment

% setup fLocSession and save session information
session = fLocSession(name, trigger, stim_set, num_runs, task_num);
session = load_seqs(session);
session_dir = (fullfile(session.exp_dir, 'data', session.id));
if ~exist(session_dir, 'dir') == 7
    mkdir(session_dir);
end
fpath = fullfile(session_dir, [session.id '_fLocSession.mat']);
save(fpath, 'session', '-v7.3');

% execute all runs from start_run to num_runs and save parfiles
fname = [session.id '_fLocSession.mat'];
fpath = fullfile(session.exp_dir, 'data', session.id, fname);


%% Verify all information before we  start
    checkInfo = 0; okCheck = [1 0];
    fprintf('\n\nVerify the following information:\n');
    fprintf('Subject number is : %d \n', subjectNumber);
    fprintf('Language is : %s \n', language);
    fprintf('Are we triggering scaner? : %d \n',  trigger);
    fprintf('How many runs are we running? : %d \n', num_runs);
    fprintf('Which run are we starting from? : %d.\n', start_run);
    checkInfo = input('If this Information correct? (1 - yes, 0 - no): ');
    if checkInfo ~= 1 % If not ok start the code again with the right info
        error('The information was not as you wanted. Restart code with the right info.');
        return
    end
    
%% Run all the runs
for rr = start_run:num_runs
    session = run_exp(session, rr, language);
    save(fpath, 'session', '-v7.3');
    fprintf('\nLocalizer run # %d of %d is done.', rr, num_runs);
end

write_parfiles(session);
fprintf('\nAll the runs have been ran. Experiment is over.');
DisableKeysForKbCheck([]);
sca;
ShowCursor;
end
