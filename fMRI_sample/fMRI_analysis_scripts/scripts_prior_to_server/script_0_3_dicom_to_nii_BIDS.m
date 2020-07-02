%% Converts DICOMS into NIFTI

% and organize the NIFTI files according to BIDS format
% also creates (I think... .json BIDS compliant sidecar files containing
% important infomation for fmriprep prepocessing (and surely other stuff)

% Adapted for fribbles_fMRI experiment 
% Gabriel Pelletier, April 2019

% dicom folders should be named SUBID_dicom (e.g. 102_dicom)

%%

clear

inpath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/source_data/';
outpath = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/BIDS/';

% Creata the log file. If it already exists, do not add the header again . %%%%%%%%%%%%%%%%%%%%%%%
logFileName = '/Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/scripts/logs/LOGS_dicom_2_nii_BIDS.csv';
if isfile(logFileName)
     fid_dataTrack= fopen(logFileName,'a');
     fprintf(fid_dataTrack,'\n');
else
     fid_dataTrack= fopen(logFileName,'a');
     % Header of the .csv log file
    fprintf(fid_dataTrack,['subID,anat#dir,anat#dcm,task-fribBids#runs_sbref,task-fribBids#runs_bold,run1_sbref#dcm,run1_bold#dcm,run2_sbref#dcm,run2_bold#dcm,'...
    'run3_sbref#dcm,run3_bold#dcm,run4_sbref#dcm,run4_bold#dcm,task-fLoc#runs_sbref,task-fLoc#runs_bold,run1_sbref#dcm,run1_bold#dcm,run2_sbref#dcm,run2_bold#dcm,'...
    'run3_sbref#dcm,run3_bold#dcm,run4_sbref#dcm,run4_bold#dcm, fmap_dir-AP#folder, fmap_dir-AP#dcm, fmap_dir-PA#folder,fmap_dir-PA#dcm, comments \n']);
        %%%%%%%%%%%%%%%%%%%%%%%
end

filesToConv=dir(inpath);

% Find and remove files/folders that are not SUBID_dicom folders
junkInd = [];
for i = 1:length(filesToConv) 
    if contains(filesToConv(i).name, '_dicom')==0
        junkInd(end+1) = i;
    end
end
filesToConv(junkInd) = [];

% for i=1:length(filesToConv)
%     filesToConv(i).date=filesToConv(i).name(18:30);
% end
filesToConvT=struct2table(filesToConv);
filesToConvT=sortrows(filesToConvT,'datenum'); % Sort the files by date/time (not sure why?)


%%
for SubInd = 1 : height(filesToConvT)
    comnt=[];
    
    % Get subject number from folder name
    if height(filesToConvT) == 1
        subID = str2double(filesToConvT.name(1:end-6));
        subInFold=filesToConvT.name;
    elseif height(filesToConvT) > 1
        subID = str2double(filesToConvT{SubInd, 'name'}{1}(1:end-6));
        subInFold=filesToConvT{SubInd, 'name'}{1};
    end
    
    if subID<10; fillZeros='000';
    elseif subID>9 && subID<100; fillZeros='00';
    elseif  subID>99 && subID<1000; fillZeros='0';
    elseif  subID>999; fillZeros='';
    end
    
    subID= ['sub-' fillZeros num2str(subID)];
    
    fprintf('\nNow running subject: %s\n', subID);
    
    fprintf(fid_dataTrack,[subID ',']);%%%%%%%%%%%%%%%%%%%%%%%
    
    % sub dir
    if ~isdir([outpath subID])
        mkdir([outpath subID]); % create a new folder for this subject
    end
    
    %% anat
    
    if ~isdir([outpath subID '/anat' ])
        mkdir([outpath subID '/anat' ]); % create a new folder for this subject
    end
    
    T1dir=dir([inpath subInFold '/*MPRAGE_EnchancedContrast']);
    fprintf(fid_dataTrack,[num2str(length(T1dir)) ',']);%%%%%%%%%%%%%%%%%%%%%%%

    if ~isempty(T1dir)
        if length(T1dir)>1 comnt=[comnt ' - had ' num2str(length(T1dir)) 'T1 dirs: used the last one ,' ] ; end % !!!!!!!!!!!!!!!!!!!!
        T1_dcms=(dir([inpath subInFold '/' T1dir(length(T1dir)).name '/*.dcm'])); % Removes junk, only keeps the .dcms
        fprintf(fid_dataTrack,[num2str(length(T1_dcms)) ',']);%%%%%%%%%%%%%%%%%%%%%%%
        %Ans=system(['/usr/local/bin/dcm2niix -o ' outpath subID '/anat/ -f ' subID '_T1w -g y ' inpath subInFold '/*MPRAGE_EnchancedContrast/'] )
        Ans=system(['/anaconda/bin/dcm2niix -o ' outpath subID '/anat/ -f ' subID '_T1w -g y ' inpath subInFold '/*MPRAGE_EnchancedContrast/'] )

    else fprintf(fid_dataTrack,' ,');%%%%%%%%%%%%%%%%%%%%%%%

    end
    
    %% func fribBids
    
    if ~isdir([outpath subID '/func' ])
        mkdir([outpath subID '/func' ]); % create a new folder for this subject
    end
    
    %task
    fribBids_taskdir=dir([inpath subInFold '/*cmrr_mbep2d_365vol*']);
    fprintf(fid_dataTrack,[num2str(length(fribBids_taskdir)/2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
    fprintf(fid_dataTrack,[num2str(length(fribBids_taskdir)/2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
    
    taskrun_bold=0;
    taskrun_sbref=0;
    for i=1:length(fribBids_taskdir)
         
        curdir=dir([inpath subInFold '/' fribBids_taskdir(i).name '/']);
        
        while contains(curdir(1).name, '.dcm') == 0 ; curdir(1)=[];end
        
        % Is this a dir containing all the BOLD TRs, of is it a SBREF dir?
         if contains(fribBids_taskdir(i).name, 'SBRef')
             dirLengthShouldBe = 1; % Is SBREF, there is only one scan
             
             if length(curdir)==dirLengthShouldBe
                 if taskrun_sbref>4
                     comnt=[comnt ' - had more than 4 valid task runs:decide which to keep ,'];% !!!!!!!!!!!!!!!!!!!!
                 else
                     taskrun_sbref=taskrun_sbref+1;
                     fprintf(fid_dataTrack,[num2str(length(curdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
                     % Runs the conversion using dcm2niix
                     outFileName = [subID, '_task-fribBids_run-0',num2str(taskrun_sbref),'_sbref'];
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/func/ -f ' outFileName ' -g y ' inpath subInFold '/' fribBids_taskdir(i).name '/'] )
                 end
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 comnt=[comnt ' - bad fribBids SBREF task run with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
             
         else % This is the BOLD folder for this run
             dirLengthShouldBe = 365; % For this task, we have this number of TRs
             
             if length(curdir)==dirLengthShouldBe
                 if taskrun_bold>4
                     comnt=[comnt ' - had more than 4 valid task runs:decide which to keep ,'];% !!!!!!!!!!!!!!!!!!!!
                 else
                     taskrun_bold=taskrun_bold+1;
                     fprintf(fid_dataTrack,[num2str(length(curdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
                     % Runs the conversion using dcm2niix
                     outFileName = [subID, '_task-fribBids_run-0',num2str(taskrun_bold),'_bold'];
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/func/ -f ' outFileName ' -g y ' inpath subInFold '/' fribBids_taskdir(i).name '/'] )
                 end
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 fprintf(fid_dataTrack,[num2str(length(curdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
                 comnt=[comnt ' - bad fribBids BOLD task run with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
             
         end

    end
    
    % Check that we have the right number of run files for each file type
    if taskrun_bold<4
        comnt=[comnt ' - missing fribBids BOLD file task runs: has' num2str(taskrun_bold) 'instead of 4,' ];% !!!!!!!!!!!!!!!!!!!!
        for i=1:4-taskrun_bold
            fprintf(fid_dataTrack,' ,'); %%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    if taskrun_sbref<4
        comnt=[comnt ' - missing fribBids SBREF file task runs: has' num2str(taskrun_sbref) 'instead of 4,' ];% !!!!!!!!!!!!!!!!!!!!
        for i=1:4-taskrun_sbref
            fprintf(fid_dataTrack,' ,'); %%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    
   %% func fLoc (functional localizer)
    
    if ~isdir([outpath subID '/func' ])
        mkdir([outpath subID '/func' ]); % create a new folder for this subject
    end
    
    %task
    fLoc_taskdir=dir([inpath subInFold '/*cmrr_mbep2d_165vol*']);
    fprintf(fid_dataTrack,[num2str(length(fLoc_taskdir)/2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
    fprintf(fid_dataTrack,[num2str(length(fLoc_taskdir)/2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
    
    taskrun_bold=0;
    taskrun_sbref=0;
    for i=1:length(fLoc_taskdir)
         
        curdir=dir([inpath subInFold '/' fLoc_taskdir(i).name '/']);
        
        while contains(curdir(1).name, '.dcm') == 0 ; curdir(1)=[];end
        
        % Is this a dir containing all the BOLD TRs, of is it a SBREF dir?
         if contains(fLoc_taskdir(i).name, 'SBRef')
             dirLengthShouldBe = 1; % Is SBREF, there is only one scan
             
             if length(curdir)==dirLengthShouldBe
                 if taskrun_sbref>4
                     comnt=[comnt ' - had more than 4 valid task runs:decide which to keep ,'];% !!!!!!!!!!!!!!!!!!!!
                 else
                     taskrun_sbref=taskrun_sbref+1;
                     fprintf(fid_dataTrack,[num2str(length(curdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
                     % Runs the conversion using dcm2niix
                     outFileName = [subID, '_task-fLoc_run-0',num2str(taskrun_sbref),'_sbref'];
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/func/ -f ' outFileName ' -g y ' inpath subInFold '/' fLoc_taskdir(i).name '/'] )
                 end
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 comnt=[comnt ' - bad fLoc SBREF task run with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
             
         else % This is the BOLD folder for this run
             dirLengthShouldBe = 165; % For this task, we have this number of TRs
             
             if length(curdir)==dirLengthShouldBe
                 if taskrun_bold>4
                     comnt=[comnt ' - had more than 4 valid task runs:decide which to keep ,'];% !!!!!!!!!!!!!!!!!!!!
                 else
                     taskrun_bold=taskrun_bold+1;
                     fprintf(fid_dataTrack,[num2str(length(curdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
                     % Runs the conversion using dcm2niix
                     outFileName = [subID, '_task-fLoc_run-0',num2str(taskrun_bold),'_bold'];
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/func/ -f ' outFileName ' -g y ' inpath subInFold '/' fLoc_taskdir(i).name '/'] )
                 end
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 comnt=[comnt ' - bad BOLD fLoc task run with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
             
         end

    end
    
    % Check taht we have the right number of run files for each file type
    if taskrun_bold<4
        comnt=[comnt ' - missing BOLD file fLoc task runs: has' num2str(taskrun_bold) 'instead of 4,' ];% !!!!!!!!!!!!!!!!!!!!
        for i=1:4-taskrun_bold
            fprintf(fid_dataTrack,' ,'); %%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    if taskrun_sbref<4
        comnt=[comnt ' - missing SBREF file fLoc task runs: has' num2str(taskrun_sbref) 'instead of 4,' ];% !!!!!!!!!!!!!!!!!!!!
        for i=1:4-taskrun_sbref
            fprintf(fid_dataTrack,' ,'); %%%%%%%%%%%%%%%%%%%%%%%
        end
    end    
   

    %% field map / fmap
   
    % We use the technique used by HCP. This corresponds to "Case 4" in
    % BIDS documentation for fmap.
    % This technique combines two (or more) Spin Echo EPI scans with different 
    % phase encoding directionsSpin Echo EPI scans with different phase
    % encoding directions.
    % In our case (GP) we use 2 encoding directions: AP and PA.
    

    if ~isdir([outpath subID '/fmap' ])
        mkdir([outpath subID '/fmap' ]); % create a new folder for this subject
    end
    
    
    % For Phase Encoding Direction AP ('j-' in BIDS language)
    dir_label = 'AP';
    fmapdir=dir([inpath subInFold '/*FieldMap_' dir_label]);
        fprintf(fid_dataTrack,[num2str(length(fmapdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
    if length (fmapdir)~=1; disp('There is not the right number of fmap. Should be one for each encoding direction');return;end

        curdir=dir([inpath subInFold '/' fmapdir.name '/']);
        
        while contains(curdir(1).name, '.dcm') == 0 ; curdir(1)=[];end
             dirLengthShouldBe = 3; % 3 images.dcm
             if length(curdir)==dirLengthShouldBe

                     % Runs the conversion using dcm2niix (do not procude
                     % .json sidecar files (we will do this separately)
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/fmap/ -f ' subID '_dir-' dir_label '_epi -g y ' inpath subInFold '/' fmapdir.name '/'] )
                     fprintf(fid_dataTrack,[num2str(length(dir([inpath subInFold '/' fmapdir.name '/']))-2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
             
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 comnt=[comnt ' - bad field map acquisition with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
             
        % Create the JSON file for this fmap              
        % Read the json automatically created by dcm2niix
        fname = [outpath subID '/fmap/' subID '_dir-' dir_label '_epi.json'];
        autoJson = jsondecode(fileread(fname));
        % Exctract the TotalReadoutTime from it
        TotalReadoutTime = autoJson.TotalReadoutTime;
        newJson.TotalReadoutTime = TotalReadoutTime;
        % Manually code PhaseEncodingDirection (this info in the automatically created json
        % is not accurate for the fmap).
        newJson.PhaseEncodingDirection = 'j-'; % FOR AP ONLY
        % Create the IntendedFor field
        newJson.IntendedFor = {['func/' subID '_task-fLoc_run-01_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-02_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-03_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-04_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-01_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-02_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-03_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-04_bold.nii.gz']};
        % Delete the automatically created json file
        delete(fname);
        % Write the relevant info to a json file
        json_options.indent = '    '; % this just makes the json file look prettier
        jsonwrite(fname, newJson, json_options);

                              
        
%     % For Phase Encoding Direction PA ('j' in BIDS language)
        dir_label = 'PA';
        fmapdir=dir([inpath subInFold '/*FieldMap_' dir_label]);
        fprintf(fid_dataTrack,[num2str(length(fmapdir)) ',']); %%%%%%%%%%%%%%%%%%%%%%%
        if length (fmapdir)~=1; disp('There is not the right number of fmap. Should be one for each encoding direction');return;end

        curdir=dir([inpath subInFold '/' fmapdir.name '/']);
        
        while contains(curdir(1).name, '.dcm') == 0 ; curdir(1)=[];end
             dirLengthShouldBe = 3; % 3 images.dcm
             if length(curdir)==dirLengthShouldBe
                     % Runs the conversion using dcm2niix
                     Ans=system(['/anaconda/bin/dcm2niix -z y -o ' outpath subID '/fmap/ -f ' subID '_dir-' dir_label '_epi -g y ' inpath subInFold '/' fmapdir.name '/'] )
                     fprintf(fid_dataTrack,[num2str(length(dir([inpath subInFold '/' fmapdir(1).name '/']))-2) ',']); %%%%%%%%%%%%%%%%%%%%%%%
             
             elseif length(curdir)~=dirLengthShouldBe % Check that we have the right number of files (TRs)
                 comnt=[comnt ' - bad field map acquisition with ' num2str(length(curdir)) ' dcm,' ];% !!!!!!!!!!!!!!!!!!!!
             end
 
        % Create the JSON file for this fmap
        % Read the json automatically created by dcm2niix
        fname = [outpath subID '/fmap/' subID '_dir-' dir_label '_epi.json'];
        autoJson = jsondecode(fileread(fname));
        % Exctract the TotalReadoutTime from it
        TotalReadoutTime = autoJson.TotalReadoutTime;
        newJson.TotalReadoutTime = TotalReadoutTime;
        % Manually code PhaseEncodingDirection (this info in the automatically created json
        % is not accurate for the fmap).
        newJson.PhaseEncodingDirection = 'j'; % FOR AP ONLY
        % Create the IntendedFor field
        newJson.IntendedFor = {['func/' subID '_task-fLoc_run-01_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-02_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-03_bold.nii.gz'],...
            ['func/' subID '_task-fLoc_run-04_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-01_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-02_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-03_bold.nii.gz'],...
            ['func/' subID '_task-fribBids_run-04_bold.nii.gz']};
        % Delete the automatically created json file
        delete(fname);
        % Write the relevant info to a json file
        json_options.indent = '    '; % this just makes the json file look prettier
        jsonwrite(fname, newJson, json_options);

   % Log all the comments gathered for this subject.
   if isempty(comnt)
       comnt=[comnt ' All good' ];% !!!!!!!!!!!!!!!!!!!!
   end
   
   fprintf(fid_dataTrack,[comnt '\n']);
   
   % After conversion, move subject fodler to already_converted folder.
   %movefile([inpath filesToConv(SubInd).name], [inpath 'already_converted/' filesToConv(SubInd).name])
   fprintf('\nThe raw DICOM folder named: %s was converted \n and should now be MANUALLY moved to:\n%s\n', filesToConv(SubInd).name, [inpath 'already_converted/']);
   
end % End of subject Loop

% Close log .csv file
fclose(fid_dataTrack);
