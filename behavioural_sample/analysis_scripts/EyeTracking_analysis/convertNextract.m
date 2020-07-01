%% Gabriel Pelletier, January 2018
% Short script to convert eyeTracking data using the EDF2MAT class
% and exctract onyl the relevenat data for our subsequent analysis.

% This script needs to be in the same parent folder as the .edf file and
% the @Edf2Mat class folder.


function convertNextract(subjectNumber, dataFolder, file, run)

edf0 = Edf2Mat(file);

% Keep whats meaningful from data
eyeData.triggers.time=edf0.Events.Messages.time;
eyeData.triggers.type=edf0.Events.Messages.info;
eyeData.trials.startTime = edf0.Events.Start.time;
eyeData.trials.endTime = edf0.Events.End.time;
% This contaitns all the relevant information on all fixations
eyeData.FixInfo = edf0.Events.Efix;

% Save as matlab Structure in subject's data folder
save([dataFolder,num2str(subjectNumber),'_eyeData.mat'],'eyeData');
%save([dataFolder,num2str(subjectNumber),'_eyeData_run',num2str(run),'.mat'],'eyeData');

end