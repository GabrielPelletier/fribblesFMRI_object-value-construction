%%
% Script to Run fmriprep on one or several subjects.
%
% - Provide Which subjects and how many cores to use for the preprocessing,
% and this code imply prints the command in the Matlab's command window.
% This command should the be copy/paste in the terminal.
%
% - REQUIRES fmriprep.sge (or its fmriprep.sge_noSTC).
%
%  qsub -pe smp<# of cores> <path to fmriprep.sge>/fmriprep.sge <"subX" "subY" ... "subN"> 
%%

% Which subjects to run?
    % If multiple subjects, should be = '"SUB1 SUB2 SUB3"'
SUBJECTS = '"0435" "0436" "0437" "0438" "0439" "0440" "0441" "0442" "0443" "0444" "0445" "0446" "0447" "0448" "0449" "0450" "0451" "0452" "0453" "0454"';

% How many cores to use ?
NCORES = '5';

% Print the command taht should be copied and run from the terminal.

    %%% Skip Slice timing correction
fprintf('\nqsub -pe smp %s /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/fmriprep_noSTC.sge %s\n', NCORES, SUBJECTS);
 
    %%% Skip both Slice timing correction AND field maps (susceptibility distroction correction)
%fprintf('\nqsub -pe smp %s /export2/DATA/FRIB_FMRI/fmri_sample/derivatives/scripts/fmriprep_noSTC_noFMAP.sge %s\n', NCORES, SUBJECTS);


