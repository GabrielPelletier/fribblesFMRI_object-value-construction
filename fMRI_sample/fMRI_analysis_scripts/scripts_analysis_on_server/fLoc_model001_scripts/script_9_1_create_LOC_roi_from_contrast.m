%%
% Create sperical ROI around the Voxel of peak activity from a zmap of a
% contrast obtained with a Functionnal Localizer task, using FSL commands.
%
% It thresholds the zmap to an uncorrected value (z = 3.1), and then find
% the peak within and atlas-based region.
% 
% Creates one ROR per hemisphere, and also creates a bilateral ROI.
%
% The scripts is written for Lateral Occipital Complex (ROI) fomr the
% Hardvardoxford atals and the Objects > ScrambledObjects contrats. It can
% be adapted to all sorts of Regions and contrasts.
%
% Gabriel Pelletier
% April 2019
%
% *** As of April 2019, it does not deal with cases when the ROI
% cannot be found on one side or the other. In this case it will crash. ***
%
%%

%% Details

% Model
modelID = 'model001';

% Participants
% participants = [0309 0311 0402 0403 0406 0407 0408 ...
%           0410 0411 0412 0413 0414 0415 0417 0418 0419 ...
%           0421 0422 0428 0429 0430 0431 0432 ...
%           0433 0434 0435 0436 0437 0438 0439 0440 0441 0444 ...
%           0445 0446 0447 0449 0450 0452 0453 0454];

participants = [0437];

% Set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

mainPATH = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';


%%

for sub_ind = 1:length(participants)
    SUBNUM = ['0' num2str(participants(sub_ind))]
    
    % Step 1. Threshold the z-map and create a new file.
     THRESHOLD = '3.1';
     INPUTimage = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/zstat1.nii.gz'];
     STATSimage= [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/zstat1_thresholded.nii.gz'];
        % Command
        system(['fslmaths ' INPUTimage ' -thr ' THRESHOLD ' ' STATSimage]);

    % Step 2.1 Tranform the Atlas' LOC ROI to fit the subject's registered stats image (dimensions and Voxel size)
     INPUTimage = [mainPATH '/ROI_standard_masks/harvardoxford_LOC-inf_bin_mask.nii.gz']; % The Atlas ROI image to resample (transform)
     OUTPUTimage = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/harvardoxford-bin_LOC_INF_mask_RS.nii.gz'];
        % Command
        system(['flirt -in ' INPUTimage ' -ref ' STATSimage ' -applyxfm -usesqform -out ' OUTPUTimage]);
    
    
    % Step 2.2 Binarise the newly created image, because the transormation made the
     % edges of the ROI not binary.
    your_output_from_the_previous_command = OUTPUTimage;
    % Output name:
    atlas_derived_LOC = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/harvardoxford_LOC_mask.nii.gz'];
        % Command
         system(['fslmaths ' your_output_from_the_previous_command ' -thr 0.5 -bin ' atlas_derived_LOC]);
    
    
    % Step 3. Create an image which is a conjunction between the atlas LOC
     % and the thresholded zmap. (multiply the thresholded image by the
     % binary atlas-derived LOC).
     atlas_derived_LOC = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/harvardoxford_LOC_mask.nii.gz'];
     temp_output = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/zstat1_conj_LOC.nii.gz'];

     % Multiply thresholded image by the binarized Atlas LOC
        % Command
        system(['fslmaths ' STATSimage ' -mul ' atlas_derived_LOC ' ' temp_output]);
    

    % Step 4. Get the clusters information within the LOC mask.
     % The zstats image was already thresh at 3.1, so the clustering
     % threshold here can be anything below 3.1 and it will be fine.
     % Will save the info in a .txt file here:
     cluster_info_output = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/LOC_cluster_info.txt'];
     
        % Command
        % The FSL 'cluster' command needs to be specified with the FSL
        % path, to disambiguate from the existing matlab 'cluster' command.
        % note; the option --mm will give the peak coord in MNI space.
        system(['/share/apps/fsl/bin/cluster -i ' temp_output ' -t 0.1 > ' cluster_info_output]);
        
        
   % Step 5. Get coordinates of the PEAK VOXEL in each Hemisphere.
    % Load the cluster infor .txt file
    cluster_info = readtable(cluster_info_output);
    
    % Get the value of the midline in the subjects' registered space (not
    % exactly the same as MNI)
    [status, info] = system(['fslinfo ' temp_output]);
    TEMP=strsplit(info);
    midline=str2num(TEMP{1,4})/2;
    % Find one maximum z-value per hemisphere and the corresponding [X,Y,Z]
    % note; in Voxel space, 
    val_peak_left = max(cluster_info.MAX(cluster_info.MAXX_vox_ < midline));
    ind_peak_left = find(cluster_info.MAX == val_peak_left & cluster_info.MAXX_vox_ < midline);
    val_peak_right = max(cluster_info.MAX(cluster_info.MAXX_vox_ > midline));
    ind_peak_right = find(cluster_info.MAX == val_peak_right & cluster_info.MAXX_vox_ > midline);
    coord_peak_left = [cluster_info.MAXX_vox_(ind_peak_left) cluster_info.MAXY_vox_(ind_peak_left) cluster_info.MAXZ_vox_(ind_peak_left)];
    coord_peak_right = [cluster_info.MAXX_vox_(ind_peak_right) cluster_info.MAXY_vox_(ind_peak_right) cluster_info.MAXZ_vox_(ind_peak_right)];
    
    
   % [...]
   % Step 6. Draw a Sphere around the peaks and save as final LOC ROIs for 
    % this subject, using flsmaths
    % Save the coordinates as .nii   
    template = temp_output; % Canvas to draw the ROI is the stats image
    leftPointName = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/LOC_left_peak.nii.gz'];
    rightPointName = [mainPATH '/fLoc/sub-' SUBNUM '/model/' modelID '/task-fLoc.gfeat/cope1.feat/stats/LOC_right_peak.nii.gz'];
        % Command
        system(['fslmaths ' temp_output ' -mul 0 -add 1 -roi ' num2str(coord_peak_left(1)) ' 1 ' num2str(coord_peak_left(2)) ' 1 ' num2str(coord_peak_left(3)) ' 1 0 1 ' leftPointName ' -odt float']);
        system(['fslmaths ' temp_output ' -mul 0 -add 1 -roi ' num2str(coord_peak_right(1)) ' 1 ' num2str(coord_peak_right(2)) ' 1 ' num2str(coord_peak_right(3)) ' 1 0 1 ' rightPointName ' -odt float']);
    
    % Draw a sphere around the points
    sphere_roi_radius = '10'; % 10mm
    leftRoiName = [mainPATH '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-LOC_left_mask.nii.gz'];
    rightRoiName = [mainPATH '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-LOC_right_mask.nii.gz'];
    
        % Command
        system(['fslmaths ' leftPointName ' -kernel sphere ' sphere_roi_radius ' -fmean ' leftRoiName ' -odt float']);   % Creates the ROI 
        system(['fslmaths ' rightPointName ' -kernel sphere ' sphere_roi_radius ' -fmean ' rightRoiName ' -odt float']);
        system(['fslmaths ' leftRoiName ' -bin ' leftRoiName]); % Binarises the voxel intensities
        system(['fslmaths ' rightRoiName ' -bin ' rightRoiName]);
        
   % Combine the two ROIs in a bilateral LOC ROI
   bilatRoiName = [mainPATH '/fLoc/sub-' SUBNUM '/sub-' SUBNUM '_desc-LOC_mask.nii.gz'];
   
        % Command§
        system(['fslmaths ' leftRoiName ' -add ' rightRoiName ' ' bilatRoiName]);
        
end

