%% Rename and Send events (behavior) data files to the BIDS format-complient
%  directory

% Create events.tsv files for each run of each task of each subject.
% == 3 column vector files for neuroimaging analysis

% Adapated for the Fribbles_fMRI experiment
% Gabriel Pelletier
% Last update : April 10, 2019

clear all

%% ======Which subject(s)====== %%
subjects = [447];

%% Where is the data
dataPath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/behav_eye_data/';

% Where are the tvc files going to be sent?
bidDir = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/BIDS/';

% % ========================== % %

%%
% Which runs 
runs = [1 2 3 4];

for subjectNumber = subjects
    
    %% fribBids task files
    
    % Get all the files in this folder     
    subjectFileCode  = ['0',num2str(subjectNumber)];
    currentFolder = [dataPath,'fribBids_bidding/sub-0', num2str(subjectNumber),'/'];
    sub_folders = fdir(currentFolder);
    
    % Check if the data has been converted to the "compact version" before the transfer to dropbox. If not
    % then do it here.
    if ~contains(sub_folders, 'Compact')
        warning('Data was not converted in the Compact format. We will do it here before continuing.');
        organizeBidsDataText(subjectNumber, currentFolder, length(runs));
        sub_folders = fdir(currentFolder);
    end
    
    
    for rr = runs
        
        % Search for this run's file
        for i = 1 : length(sub_folders)            
            if ~isempty(strfind(sub_folders{i},['Run',num2str(rr),'_Compact']))
                currentRunFile = [currentFolder, sub_folders{i}];
            end
        end
        
         % File name and location (BIDS format)
        newRunFile = [bidDir,'sub-',subjectFileCode,'/func/','sub-',subjectFileCode,...
            '_task-fribBids_run-0',num2str(rr),'_events.tsv'];
       % Delete file if already exists
        if exist(newRunFile, 'file')
            warning('/...event.tsv already exist. It was overwritten.');
            delete(newRunFile)
        end

     
        % Open and read text file
        delimiter = '\t';
        startRow = 2; % Because there is a header, skip it
        formatSpec = '%f%f%f%s%f%s%f%f%f%f%f%f%f%[^\n\r]';
        fileID = fopen(currentRunFile,'r');
        if fileID == -1 % If the file could not be opened (probably because it does not exist)
            warning('Could not open compact-format behavior data file.');
        end
        
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines',startRow-1, 'ReturnOnError', false);
        clear currentRunFile;
        % Add Bids compliant Header and select usefull colums
        % CONTAINS a set of REQUIRED and OPTIONAL columns
        %REQUIRED Onset (in seconds) of the event  measured from the beginning of 
        % the acquisition of the first volume in the corresponding task imaging data file.  
        % If any acquired scans have been discarded before forming the imaging data file, 
        % ensure that a time of 0 corresponds to the first image stored. In other words 
        % negative numbers in onset are allowed.
        onset_stim = [dataArray{:, 10}];
        onset_rating = [dataArray{:, 12}];
        
        %REQUIRED. Duration of the event (measured  from onset) in seconds.  
        % Must always be either zero or positive. A "duration" value of zero implies 
        % that the delta function or event is so short as to be effectively modeled as an impulse.
        duration_stim = dataArray{:, 11} - dataArray{:, 10}; 
        duration_rating = dataArray{:, 13} - dataArray{:, 12};
        
        %OPTIONAL Primary categorisation of each trial to identify them as instances 
        % of the experimental conditions
        trial_type_stim = dataArray{:, 6}; % Conditon
        trial_type_rating = repmat({'rating'},length(trial_type_stim),1);

        %OPTIONAL. Response time measured in seconds. A negative response time can be 
        % used to represent preemptive responses and n/a denotes a missed response.
        response_time= [dataArray{:, 8}];

        %OPTIONAL Represents the location of the stimulus file (image, video, sound etc.) 
        % presented at the given onset time
        stim_file = dataArray{:, 4}; 
        
        %OPTIONAL Represents the response (value rating) made on that trial
        value_rating = dataArray{:, 7};     
        
        %OPTIONAL Represents the real value of the stimulus on that trial
        value_real = dataArray{:, 5}; 
        
        % Concatenate Stimulus and Rating Events, and sort by Onset
        trial_type = [trial_type_stim; trial_type_rating];
        value_rating = [value_rating; value_rating];
        response_time = ([response_time; response_time])/1000;
        onset = [onset_stim; onset_rating];
        duration = [duration_stim; duration_rating];
        stim_file = [stim_file; stim_file];
        value_real = [value_real; value_real];
        
        % Save table
        t = table(onset,duration,trial_type,response_time,stim_file,value_rating, value_real);
        t = sortrows(t,'onset');
        writetable(t,newRunFile,'FileType','text','Delimiter','\t');
    end
    
    %% fLoc task files
    % Find the exact name of the subject folder based on subNUM
        currentFolder = [dataPath 'fLoc/sub-0' num2str(subjectNumber) '/'];
        %currentFolder = [dataPath 'fLoc/' subjectDir.name '/'];

    for  rr = runs
        
        if ~exist(currentFolder)
            warning('There is no fLoc folder for this subject : %s', subjectFileCode);
        else
            
        % Get all the files in this folder
        sub_folders = fdir(currentFolder);

            % Search for this run's file
            for i = 1 : length(sub_folders)
                if ~isempty(strfind(sub_folders{i},['run',num2str(rr)]))
                    currentRunFile = [currentFolder sub_folders{i}];
                end
            end

            % File will be copied there (BIDS format), under this new name
            newRunFile = [bidDir 'sub-' subjectFileCode '/func/','sub-' subjectFileCode '_task-fLoc_run-0' num2str(rr) '_events.tsv'];
            % Delete file if already exists
            if exist(newRunFile, 'file')
                warning('/...event.tsv already exist. It was overwritten.');
                delete(newRunFile)
            end


            % Open and read text file
            delimiter = '\t';
            startRow = 1; % Because there is no header
            formatSpec = '%f%f%s%s%[^\n\r]';
            fileID = fopen(currentRunFile,'r');
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines',startRow-1, 'ReturnOnError', false);
            clear currentRunFile;
            % Add Bids compliant Header and select usefull colums
            % CONTAINS a set of REQUIRED and OPTIONAL columns
            %REQUIRED Onset (in seconds) of the event  measured from the beginning of 
            % the acquisition of the first volume in the corresponding task imaging data file.  
            % If any acquired scans have been discarded before forming the imaging data file, 
            % ensure that a time of 0 corresponds to the first image stored. In other words 
            % negative numbers in onset are allowed.
            onset = dataArray{:, 1};

            %REQUIRED. Duration of the event (measured  from onset) in seconds.  
            % Must always be either zero or positive. A "duration" value of zero implies 
            % that the delta function or event is so short as to be effectively modeled as an impulse.
            duration = repmat(11.25, length(onset), 1); 

            %OPTIONAL Primary categorisation of each trial to identify them as instances 
            % of the experimental conditions
            bloc_type = dataArray{:, 3}; % Conditon
            bloc_typeCode = dataArray{:, 2}; % Conditon


            % Save table
            t = table(onset,duration,bloc_type,bloc_typeCode);
            writetable(t,newRunFile,'FileType','text','Delimiter','\t'); 

         end
    end
   fprintf('\nDone creating events.tsv files for sub-%s\n', subjectFileCode); 
end