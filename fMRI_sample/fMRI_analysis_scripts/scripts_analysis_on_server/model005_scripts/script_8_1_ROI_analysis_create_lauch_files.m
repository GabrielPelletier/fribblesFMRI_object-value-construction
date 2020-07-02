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
modelID = 'model005';

% Which participants do we run?
participants = [309	311	402	403	405	406	407	408	410	411	412	413	414	415	... 
    417	418	419	421	422	428	429	430	431	432	433	434	435	436	437	438	439	...
    440	441	444	445	446	447	448	449];


% Which ROI(s)?
rois = {'lOFC' 'vmpfc'};

% Open .txt file to write
launchFileName = [main_path '/scripts/' modelID '_scripts/launch_files/ROI_launch.txt'];

    if isfile(launchFileName)
        warning('This file already existed, it was Overwritten: \n %s', launchFileName)
    end
    
    fid = fopen(launchFileName,'w'); % Create the lauch file

%%
for roi_ind = 1:length(rois)
    ROINAME = rois{roi_ind};
    
    for sub_ind = 1:length(participants)
        SUBNUM = ['0' num2str(participants(sub_ind))];
        feats_path = [main_path 'sub-' SUBNUM '/model/' modelID '/task-fribBids_noFMAP.gfeat/'];
        ROI_MASK = [main_path 'sub-' SUBNUM '/sub-' SUBNUM '_roi-' ROINAME '_space-standard_desc-mask.nii.gz'];
        output_folder = ['featquery_roi-' ROINAME];

        fprintf(fid,'%s\n',['/share/apps/fsl/bin/featquery 3 ' feats_path 'cope3.feat ' feats_path 'cope4.feat ' feats_path 'cope5.feat 1 stats/cope1 ' output_folder ' -w ' ROI_MASK]);
   
    end %subs
end %rois

fid=fclose(fid);
