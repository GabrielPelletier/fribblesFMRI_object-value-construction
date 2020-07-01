%%
%
% This function summarizes quality of Eye-Tracking data for all
% participants.
% 
% Trials for which less than X% of samples are "fixations"
% will be excluded from further eye-tracking anlaysis due to insufficient
% data quality. Participants with more than 50% excluded trials will be
% removed from eye-tracking analysis altogether.
%
% Gabriel Pelletier, August 2019
% 
%%

function QC_summary = data_quality_check(dataPath, subs, runs, cutoff_proportion)

QC_summary = [];

for ss = 1 : length(subs)
    subjectNumber = subs(ss);
    
    try eyeTrackingFiles = fdir([dataPath '/sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_eyeData_run*.mat']); catch eyeTrackingFiles = 0; end
    if size(eyeTrackingFiles,1) == 4 % If we have 4 god runs of eye tracking data
        temp_sub_mat = [];
    
        for rr = 1 : runs
            eyeDataFile = [dataPath '/sub-0' num2str(subjectNumber) '/' num2str(subjectNumber) '_eyeData_run' num2str(rr) '.mat'];
            load(eyeDataFile);
            samplingRate = eyeData.RecInfo.sample_rate; % Get sampling rate from data info
            
            for t = 1:size(eyeData.TrialFix,2)
                % Flag poor-data trials (identify the trials where less than 70% of the
                % samples are labeleld as fixations)
                if ~isempty(eyeData.TrialFix{1,t})
                    num_samples_trial = eyeData.TimeOfInterest(3,t)/1000 * samplingRate;
                    dur_fix = sum(eyeData.TrialFix{1,t}(4,:)); 
                    % Convert duration into number of samples (based on sampling rate)
                    num_samples_fix = (dur_fix/1000) * samplingRate;
                    % Proportion of samples labelled as fixation?
                    prop_sample_fix = num_samples_fix/num_samples_trial;
                    if prop_sample_fix < cutoff_proportion
                        bad_trials(t) = 1;
                    else bad_trials(t) = 0;
                    end
                else bad_trials(t) = 1; %If there is no fixation in this trial, trial should be discarded
                end
            end
            eyeData.bad_trials = bad_trials;
    
            % Save eyeData after adding this new stuff to it
            save(eyeDataFile,'eyeData');
    
            temp_sub_mat(rr) = sum(eyeData.bad_trials);

        end % run loop
    
        QC_summary(end+1).subject_number = subjectNumber;
        QC_summary(end).prop_bad_trials = sum(temp_sub_mat) / (runs * length(eyeData.bad_trials));
    
    else
        warning(['There are no, or missing eyeData_ .mat files for SUBEJCT %d.'... 
            '\nEither there is no, or missing, eye-tracking runs for this subject, or edf data have not been converted yet.'], subjectNumber);
        continue
    end
    
end % subject loop

end