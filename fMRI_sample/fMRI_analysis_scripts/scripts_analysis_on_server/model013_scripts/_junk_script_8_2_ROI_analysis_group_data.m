% Thvis get the information from the Featquery .txt output for each
% subject
% and puts it in one file for the entire group, for statistics and graphs.



%% Details 
clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

% Model
modelID = 'model013';

% Which ROIs?
rois = {'lOFC' 'vmpfc' 'PRC' 'LOC' 'FFA' 'PPA' 'HIP'};

% Which contrasts?
copes = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];

% Which participants
participants = [0309 0311 0402 0403 0406 0407 0408 0410 0411 ...
                0412 0413 0414 0415 0417 0418 0419 0421 0422 0428 0429 ...
                0430 0431 0432 0433 0434 0435 0436 0437 0438 0439 0440 ...
                0441 0444 0445 0446 0447 0449 0450 0452 0453 0454];

% Featquery header
featquery_head = {'stats_image_id' 'stats_image' 'num_voxels' 'stats_min' 'stats_10percent' 'stats_mean' 'stats_median'...
    'stats_90percent' 'stats_max' 'stats_stddev' 'max_voxel_x' 'max_voxel_y' 'max_voxel_z' 'max_MNI_x' ...
    'max_MNI_y' 'max_MNI_z'};

dataheader = ['sub_id' featquery_head];


%%
for roi_ind = 1:length(rois)
    ROINAME = rois{roi_ind};
    
    for cope_ind = 1:length(copes)
        COPENUM = num2str(copes(cope_ind));

        % Create file that will hold Group data
        groupData = dataheader;
        
        % Create destination folder if it does not exist
        if ~exist([main_path, 'group/model/' modelID],'dir') mkdir([main_path, 'group/model/' modelID]); end
        
        groupFileDir = [main_path, 'group/model/' modelID '/ROI_analysis/'];
        
        if ~isfolder(groupFileDir); mkdir(groupFileDir); end
        
        groupFileName = ['task-fribBids_roi-' ROINAME '_cope-' COPENUM];

        for sub_ind = 1:length(participants)
            SUBNUM = ['0' num2str(participants(sub_ind))];

            reportFile = [main_path 'sub-' SUBNUM '/model/' modelID '/task-fribBids.gfeat/cope' COPENUM '.feat/featquery_roi-' ROINAME '/report.txt'];
            fid = fopen(reportFile, 'r');
            subData = textscan(fid, '%s', 'Delimiter', ' ');
            subData = [SUBNUM subData{1}'];
            groupData = [groupData; subData];
            fid=fclose(fid);
        end % subs

       % Save the group data for this cope (or PE), for this ROI
       writecell(groupData, [groupFileDir groupFileName '.txt']); % Save as a csv/txt files
       groupDataTable = cell2table(groupData(2:end, :), 'VariableNames', dataheader); % Save as a matlab file
       save([groupFileDir, groupFileName '.mat'], 'groupDataTable');
       
    end %copes
end % rois

fclose all;
