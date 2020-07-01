%% Gabriel Pelletier, January 2018
% Short script to convert eyeTracking data using the EDF2MAT class
% and exctract onyl the relevenat data for our subsequent analysis.

% This script needs to be in the same parent folder as the .edf file and
% the @Edf2Mat class folder.


function failed_run_edf = convertNextract(subjectNumber, dataFolder, file, run)

try
    edf0 = Edf2Mat(file);
catch
    warning('Could not Convert the .edf file for SUBJECT %d for RUN %d', subjectNumber, run);
    failed_run_edf = 1;
    return
end
    
%% Keep whats meaningful from the converted Data
eyeData.triggers.time=edf0.Events.Messages.time;
eyeData.triggers.type=edf0.Events.Messages.info;
%eyeData.trials.startTime = edf0.Events.Start.time; % Useless
%eyeData.trials.endTime = edf0.Events.End.time; % Useless
% This contaitns all the relevant information on all fixations
eyeData.FixInfo = edf0.Events.Efix;
eyeData.RecInfo.sample_rate = edf0.RawEdf.RECORDINGS(1).sample_rate;

%% Save as matlab Structure in subject's data folder
save([dataFolder,num2str(subjectNumber),'_eyeData_run',num2str(run),'.mat'],'eyeData');
failed_run_edf = 0;
end