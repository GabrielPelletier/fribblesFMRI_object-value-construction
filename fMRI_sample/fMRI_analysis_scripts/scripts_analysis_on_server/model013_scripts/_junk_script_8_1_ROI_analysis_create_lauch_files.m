% This creates a .txt file with commands line to lauch analysis.
% It contains one row per ROI, per subject
% It is used to lauch batch analysis from the terminal

%% Featquery command 
% Usage: featquery <N_featdirs> <featdir1> ... <N_stats> <stats1> ... <outputrootname> [-a <atlas>] [-p] [-t <thresh>] [-i <interp_thresh>] [-s] [-w] [-b] <mask> [-vox <X> <Y> <Z>]
% 
% -a : use selected atlas to generate label (etc.) information
% -p : convert PE / COPE values into %
% -t : threshold stats images
% -i : affect size of resampled masks by changing post-interpolation thresholding (default 0.5)
% -s : create time-series plots
% -w : do not binarise mask (allow weighting)
% -b : popup results in browser when finished
% <mask> is necessary even if using co-ordinates, because a co-ordinate frame is needed to refer the co-ordinates to; if it is a relative filename (ie doesn't start with "/") it will be looked for inside each FEAT directory
% -vox can be replaced with -mm


%% Details 
clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

% Model 
modelID = 'model013';

% Which participants do we run?
participants = [0309 0311 0402 0403 0406 0407 0408 0410 0411 ...
                0412 0413 0414 0415 0417 0418 0419 0421 0422 0428 0429 ...
                0430 0431 0432 0433 0434 0435 0436 0437 0438 0439 0440 ...
                0441 0444 0445 0446 0447 0449 0450 0452 0453 0454];
            
%participants = [0311]; % not yet ran

% Which ROI(s)?
rois = {'lOFC' 'vmpfc' 'PRC' 'LOC' 'FFA' 'PPA' 'HIP'};

% which copes?
copes = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];

% Open .txt file to write
launchFileName = [main_path 'scripts/' modelID '_scripts/launch_files/ROI_launch.txt'];

    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file

%%
for roi_ind = 1:length(rois)
    ROINAME = rois{roi_ind};
    
    for sub_ind = 1:length(participants)
        SUBNUM = ['0' num2str(participants(sub_ind))];
        feats_path = [main_path 'sub-' SUBNUM '/model/' modelID '/task-fribBids.gfeat/'];
        ROI_MASK = [main_path 'sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
        output_folder = ['featquery_roi-' ROINAME];
              
        for cope_ind = 1:length(copes)
            COPENUM = num2str(copes(cope_ind));
            % If output older already exists (because featquery was already ran
            % for this ROI and this COPE, then delete the old folder.
            if isfolder([feats_path 'cope' COPENUM '.feat/' output_folder])
                text = sprintf('A "featquery" folder was found inside this .feat folder : %s \n The folder and its content have been deleted', [feats_path 'cope' COPENUM '.feat/' output_folder]);
                disp(text);
                rmdir([feats_path 'cope' COPENUM '.feat/' output_folder], 's');
            end
            
            % Write featquery command to launch file.
            fprintf(fid,'%s\n',['/share/apps/fsl/bin/featquery 1 ' feats_path 'cope' COPENUM '.feat 1 stats/cope1 ' output_folder ' -p ' ROI_MASK]);
        
        end %copes
    end %subs
end %rois

fid=fclose(fid);
