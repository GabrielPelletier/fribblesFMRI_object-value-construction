%% Rearrange text data files so the Stimulus and its rating are on the
% same row, treated as the same trial

function organizeBidsDataText(subjectNumber, outFolder, numRuns)


% %% For coding purposes
% subjectNumber = 111;
% numRuns = 1;
% outFolder = [pwd,'/Output/'];


for i = 1:numRuns
    
% Opens Text file to write the new data to
fid = fopen([outFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(i),'_Compact.txt'],'w');
%Header of text file (colums)
fprintf(fid,'SubjecNumber\trun\ttrial\tStimulus\tStimulusValue\tCondition\tRating\tRatingRT\tStartSliderPosition\tstimulusOnset\tStimulusOffset\tRatingScaleOnset\tRatingScaleOffset\n');

data = textscan(fopen([outFolder,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(i),'.txt']), ....
    '%s %s %s %s %s %s %s %s %s %s %s %s %s');
    
trial = 1;
    for t = 2 : 2 : length(data{1})
        fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
           data{1}{t}, data{2}{t}, num2str(trial), data{4}{t}, data{5}{t}, data{6}{t}, data{7}{t+1},...
           data{8}{t+1}, data{9}{t+1}, data{10}{t}, data{11}{t}, data{12}{t+1}, data{13}{t+1});      
       trial = trial + 1; % so one trial now comprises Stimulus + Scale (not one trial for each)
    end
    
% Close the newlys created file
    fclose(fid);
end