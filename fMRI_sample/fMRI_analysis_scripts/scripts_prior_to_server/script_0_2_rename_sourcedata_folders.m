%% This script does nothing for now. Should be completed when you have 
%% some free time, renaming file is done by hand for now.


%% Rename files after retrieved from the Brain Imaging Center
%
% Uses the date/time in the folder-name after it was retrieved from the MRI center
% and
% the date/time from the sub_num excel file located on the lab's Dropbox
% (which contains the exepriment subject-number and should be manually
% updated after each subject was run.
% Tries to match the date/time with subNumber. It asks if this is right, and if confirmed then
% changes the folder name to SUBNUM_dicom.
%

clear

% Paths
dbpath = dropboxPath;
full_dbpath = [dbpath 'experimentsOutput/gabriel/'];
sub_key_file = [full_dbpath, 'sub_num_2019.xlsx'];
localpath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/source_data/';

% Read the excel file with sub_num, data, and time of testing.
[Sig, TStr, Raw] = xlsread(sub_key_file, 1);

% Sum the date Number with the Time Number
DateTime = sum(Sig(:,2:3), 2);
% Remove NaN (empty) rows
DateTime = DateTime(all(~isnan(DateTime),2),:); % for nan - rows


% Get all the newly copied dicom folders from the MRI center
filelist = dir([localpath '*TS_lab_*']);
if isempty(filelist)
    fprintf('\nThere was no new mri folder detected on the local computer source_data path.\n');
end

% Loop through the mri files
for i = 1:length(filelist)
    
    % Convert The Sub date/time to get real date and time as string and as numerical
    sub_DateTime_code = DateTime+datenum('30-Dec-1899'); % This is because matlab starts the date counter from this date.
    sub_DateTime_text = datestr(sub_DateTime_code);
    
    % Extract the date/time from the mri file name
    mri_Time = filelist(i).name(end-3:end);
    mri_Date = filelist(i).name(end-12:end-5);
    mri_Date_code = datenum(mri_Date, 'yyyymmdd');
    mri_Time = datetime(mri_Time, 'Format', 'HHmm');
    mri_Time_code = datenum(timeofday(mri_Time));
    mri_DateTime_code = mri_Date_code + mri_Time_code;
    
    % Finds the closest date/time in the sub_num list to this mri file
    % that is also SMALLER than the mri date/time. This is because the
    % sub_num time is about an hour before the actual scanning starts.
    impossible_subs = find(sub_DateTime_code > mri_DateTime_code); % Find/remove the subs that were scanned Before the sub_num time.
    sub_DateTime_code(impossible_subs) = NaN;
    [c index] = min(abs(sub_DateTime_code - mri_DateTime_code)); % Find the closest of those subs
    
    % Get the subject number that corresponds to this index
    sub_num = Sig(index, 1);

    % Ask if this is right
    fprintf('\nIt appears that this folder: %s\n', filelist(i).name)
    fprintf('Is associated with the subject number: %d\n', sub_num)
    str = input('Is this correct (y/n)? The folder will have to be renamed manually.\nYour answer:', 's');
    if strcmp(str, 'y') == 0
        fprintf('\nYou did not confirm the correspondance between the subject number and the date of testing so the script was aborted.\n');
        return
    end
    
    % Verify that this subject folder does not already exists.
    %if isdir([localpath num2str(sub_num) '_dicom']) == 1
        %error('A _dicom folder with this subject number already exists. There must be an error somewhere.');
    %elseif isdir([localpath num2str(sub_num) '_dicom']) == 0
        % Is all is good, then rename the folder as SUNBUM_dicom
        %movefile([localpath filelist(i).name], [localpath num2str(sub_num) '_dicom']);
        fprintf('The folder:\n%s\nShould be renamed MANUALLY to: \n%s.\n\n', filelist(i).name, [num2str(sub_num) '_dicom']);
        
    %end
    
end



