% Thvis get the information from the Featquery .txt output for each
% subject
% and puts it in one file for the entire group, for statistics and graphs.



%% Details 
clear

main_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/';

% Model
modelID = 'model005';

% Which ROIs?
rois = {'lOFC' 'vmpfc'};

% Which contrasts?
copes = [3 4 5];

% Which participants
participants = [309	311	402	403	405	406	407	408	410	411	412	413	414	415	...
    417	418	419	421	422	428	429	430	431	432	433	434	435	436	437	438	439	...
    440	441	444	445	446	447	448	449];


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

            reportFile = [main_path 'sub-' SUBNUM '/model/' modelID '/task-fribBids_noFMAP.gfeat/cope' COPENUM '.feat/featquery_roi-' ROINAME '/report.txt'];
            fid = fopen(reportFile, 'r');
            subData = textscan(fid, '%s', 'Delimiter', ' ');
            subData = [SUBNUM subData{1}'];
            groupData = [groupData; subData];

        end % subs

       % Save the group data for this cope (or PE), for this ROI
       writecell(groupData, [groupFileDir groupFileName '.txt']); % Save as a csv/txt files
       fid=fclose(fid);
       groupDataTable = cell2table(groupData(2:end, :), 'VariableNames', dataheader); % Save as a matlab file
       save([groupFileDir, groupFileName '.mat'], 'groupDataTable');
       
    end %copes
end % rois
