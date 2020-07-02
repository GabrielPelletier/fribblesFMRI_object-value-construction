% This script will use Harvard-Oxford atlas (HOA), join both cortical and
% subcortical files and save a joint map of both.
% Only need to run once.
% Creates by Tom Salomon, February 2019.

clear

% define these variables
HOA_cortical = '/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-1mm.nii.gz';
HOA_sub = '/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-sub-maxprob-thr25-1mm.nii.gz';
MNI_map = '/share/apps/fsl/data/atlases/MNI/MNI-maxprob-thr50-1mm.nii.gz';
output_HOA = [pwd,'/HOA']; % name of the output map
% example nifty in the desired resolution
%target_nifti = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/models/model001/ses-01/group_analysis/group_task-probe_2019_01_17_Zthresh_2_3/cope1.gfeat/cope1.feat/thresh_zstat1.nii.gz';
target_nifti = '/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/group/model/model013/n42_3.1_wholeBrain/group_task-fribBids_cope1.gfeat/cope1.feat/thresh_zstat1.nii.gz';
% text file with the names of indexed ROI (same order as the atlas original xml files)
cortical_labs_path = './HOA_cortical_labels.txt';
subcortical_labs_path ='./HOA_subcortical_labels.txt';
% Exclude specific anatomical regions
HOA_cortical_ROI_2_exclude = [];
HOA_sub_ROI_2_exclude = [1:3,8,12:14]; % ignore white matter, ventricle, cortex and brainstem in the subcortical map

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Read a list of HO anatomical labels. Subcortical regions.
% Space and hyphen strings were replaced with '_', commas were removed
cortical_labs = readtable(cortical_labs_path,'delimiter',' ','ReadVariableNames',false);
sub_labs =  readtable(subcortical_labs_path,'delimiter',' ','ReadVariableNames',false);
cortical_labs.Properties.VariableNames = {'label'};
sub_labs.Properties.VariableNames = {'label'};
cortical_labs.ind = (1:numel(cortical_labs))';
sub_labs.ind = (1:numel(sub_labs))'+ 100;
joint_labs = [cortical_labs;sub_labs];

HOA_cortical_nii = single(niftiread(HOA_cortical));
HOA_sub_nii = single(niftiread(HOA_sub));
MNI_map_nii = single(niftiread(MNI_map));

HOA_cortical_nii(ismember(HOA_cortical_nii,HOA_cortical_ROI_2_exclude))=0;
HOA_sub_nii(ismember(HOA_sub_nii,HOA_sub_ROI_2_exclude))=0;
HOA_sub_nii(HOA_cortical_nii>0)=0; % avoid small overlap near hippocampus

% preallocations
merged_HOA = niftiread(target_nifti)*0; % final map to be saved
merged_HOA_prob = merged_HOA; % final probablistic map to decide between competing ROIs
undecided_duplicates = []; % iteratingly growing list of undecided voxels

%% Decide allocation - Subcortical
% save each region, transform to the zstat resolution and then merge all
% files
nii_info_origin = niftiinfo(HOA_sub);
nii_info_target = niftiinfo(target_nifti);
tmp_filename = [pwd,'/tmp'];
h = waitbar(0,'Going over Subcortical ROI');
for roi_i = 1: max(HOA_sub_nii(:))
    if ismember(roi_i,HOA_sub_ROI_2_exclude)
        continue
    end
    dat_tmp_i = single(HOA_sub_nii==roi_i);
    roi_i_unique = roi_i+100;
    
    % Same for both cortical and subcortical
    niftiwrite(dat_tmp_i,tmp_filename,nii_info_origin,'Compressed',1)
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        tmp_filename,target_nifti,tmp_filename));
    tmp_data_prob = niftiread(tmp_filename);
    system(sprintf('fslmaths %s -thr 0.5 -bin %s',...
        tmp_filename,tmp_filename));
    tmp_datat2=single(niftiread(tmp_filename))*(roi_i_unique);
    duplicates = find((tmp_datat2>0) & (merged_HOA>0));
    if ~isempty(duplicates) % voxles which were previously identified
        update_ROI = tmp_data_prob(duplicates) > merged_HOA_prob(duplicates);
        undecided_duplicates = [undecided_duplicates;duplicates( tmp_data_prob(duplicates) == merged_HOA_prob(duplicates))];
        % for voxels to be replace - delete previous ROI allocation
        merged_HOA(duplicates(update_ROI)) = 0;
        merged_HOA_prob(duplicates(update_ROI)) = 0;
        % for voxels not to be replace - delete current ROI allocation
        tmp_datat2(duplicates(~update_ROI)) = 0;
        tmp_data_prob(duplicates(~update_ROI)) = 0;
        
    end
    merged_HOA = merged_HOA + tmp_datat2;
    merged_HOA_prob = merged_HOA_prob + tmp_data_prob;
    waitbar(roi_i/max(HOA_sub_nii(:)),h)
end
close (h)

%% decide allocation for undecided voxels - Subcortical
undecided_duplicates = unique(undecided_duplicates);
atlas_name = 'Harvard-Oxford Subcortical Structural Atlas';
h = waitbar(0,'Correcting unclear Subcortical voxels');
for voxel_i = 1:numel(undecided_duplicates)
    voxel = undecided_duplicates(voxel_i);
    voxel_mask = merged_HOA*0;
    voxel_mask(voxel) = 1;
    
    niftiwrite(voxel_mask,tmp_filename,nii_info_target,'Compressed',1)
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        tmp_filename,HOA_cortical,tmp_filename));
    [~,atlasquery] = system(sprintf('atlasquery -a "%s" -m %s',...
        atlas_name,tmp_filename));
    atlasquery = (strsplit(atlasquery,{':','\n'}))';
    proportions = str2double(atlasquery);
    [~,best_ROI_prop_loc] = max(proportions);
    best_ROI = atlasquery{best_ROI_prop_loc-1};
    % Match with labels - Space and hyphen strings were replaced with '_', commas were removed
    best_ROI_new = strrep(strrep(strrep(best_ROI,' ','_'),...
        '-','_'),...
        ',','');
    best_ROI_ind = joint_labs.ind(strcmp(best_ROI_new,joint_labs.label));
    if ismember(best_ROI_ind - 100,HOA_sub_ROI_2_exclude)
        best_ROI_ind=0;
    end
    merged_HOA(voxel) = best_ROI_ind;
    waitbar(voxel_i/numel(undecided_duplicates),h)
end
undecided_duplicates=[];
close(h)

%% Decide allocation - Cortical
h = waitbar(0,'Going over Cortical ROI');
for roi_i = 1: max(HOA_cortical_nii(:))
    if ismember(roi_i,HOA_cortical_ROI_2_exclude)
        continue
    end
    dat_tmp_i = single(HOA_cortical_nii==roi_i);
    roi_i_unique = roi_i;
    
    
    % Same for both cortical and subcortical
    niftiwrite(dat_tmp_i,tmp_filename,nii_info_origin,'Compressed',1)
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        tmp_filename,target_nifti,tmp_filename));
    tmp_data_prob = niftiread(tmp_filename);
    system(sprintf('fslmaths %s -thr 0.5 -bin %s',...
        tmp_filename,tmp_filename));
    tmp_datat2=single(niftiread(tmp_filename))*(roi_i_unique);
    duplicates = find((tmp_datat2>0) & (merged_HOA>0));
    if ~isempty(duplicates) % voxles which were previously identified
        update_ROI = tmp_data_prob(duplicates) > merged_HOA_prob(duplicates);
        undecided_duplicates = [undecided_duplicates;duplicates( tmp_data_prob(duplicates) == merged_HOA_prob(duplicates))];
        % for voxels to be replace - delete previous ROI allocation
        merged_HOA(duplicates(update_ROI)) = 0;
        merged_HOA_prob(duplicates(update_ROI)) = 0;
        % for voxels not to be replace - delete current ROI allocation
        tmp_datat2(duplicates(~update_ROI)) = 0;
        tmp_data_prob(duplicates(~update_ROI)) = 0;
        
    end
    merged_HOA = merged_HOA + tmp_datat2;
    merged_HOA_prob = merged_HOA_prob + tmp_data_prob;
    waitbar(roi_i/max(HOA_sub_nii(:)),h)
end
close (h)

%% Decide allocation - Cerebellum
h = waitbar(0,'Going over Cortical ROI');
for roi_i = 2
    dat_tmp_i = single(MNI_map_nii==roi_i);
    roi_i_unique = 200;
    
    
    % Same for both cortical and subcortical
    niftiwrite(dat_tmp_i,tmp_filename,nii_info_origin,'Compressed',1)
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        tmp_filename,target_nifti,tmp_filename));
    tmp_data_prob = niftiread(tmp_filename);
    system(sprintf('fslmaths %s -thr 0.5 -bin %s',...
        tmp_filename,tmp_filename));
    tmp_datat2=single(niftiread(tmp_filename))*(roi_i_unique);
    duplicates = find((tmp_datat2>0) & (merged_HOA>0));
    if ~isempty(duplicates) % voxles which were previously identified
 % for voxels not to be replace - delete current ROI allocation
        tmp_datat2(duplicates) = 0;
        tmp_data_prob(duplicates) = 0;
    end
    merged_HOA = merged_HOA + tmp_datat2;
    merged_HOA_prob = merged_HOA_prob + tmp_data_prob;
    waitbar(roi_i/max(HOA_sub_nii(:)),h)
end
close (h)

%% decide allocation for undecided voxels - Cortical
undecided_duplicates = unique(undecided_duplicates);
atlas_name = 'Harvard-Oxford Cortical Structural Atlas';
h = waitbar(0,'Correcting unclear Cortical voxels');
for voxel_i = 1:numel(undecided_duplicates)
    voxel = undecided_duplicates(voxel_i);
    voxel_mask = merged_HOA*0;
    voxel_mask(voxel) = 1;
    
    niftiwrite(voxel_mask,tmp_filename,nii_info_target,'Compressed',1)
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        tmp_filename,HOA_cortical,tmp_filename));
    [~,atlasquery] = system(sprintf('atlasquery -a "%s" -m %s',...
        atlas_name,tmp_filename));
    atlasquery = (strsplit(atlasquery,{':','\n'}))';
    proportions = str2double(atlasquery);
    [~,best_ROI_prop_loc] = max(proportions);
    best_ROI = atlasquery{best_ROI_prop_loc-1};
    % Match with labels - Space and hyphen strings were replaced with '_', commas were removed
    best_ROI_new = strrep(strrep(strrep(strrep(best_ROI,' ','_'),...
        '-','_'),...
        ',',''),...
        '''','');
    best_ROI_ind = joint_labs.ind(strcmp(best_ROI_new,joint_labs.label));
    if ismember(best_ROI_ind,HOA_cortical_ROI_2_exclude)
        best_ROI_ind=0;
    end
    merged_HOA(voxel) = best_ROI_ind;
    waitbar(voxel_i/numel(undecided_duplicates),h)
end
undecided_duplicates=[];
close(h)


%%  Differentiate Left and Right cortical regions
% add 50 to left cortical regions to differentiate Left and Right
Cortical_regions = merged_HOA > 0 & merged_HOA < 50;
image_dim = size(Cortical_regions);
x_midpoint = ceil(image_dim(1)/2);
R_Cortical_regions = Cortical_regions;
R_Cortical_regions(1:x_midpoint,:,:) = 0;

cortical_labs_l = cortical_labs;
cortical_labs_r = cortical_labs;
cortical_labs_l.label = strcat('L._',cortical_labs_l.label);
cortical_labs_r.label = strcat('R._',cortical_labs_r.label);
cortical_labs_r.ind = cortical_labs_r.ind + 50;
joint_labs = [cortical_labs_l; cortical_labs_r ;sub_labs];
joint_labs.label =strrep(joint_labs.label,'Left','L.');
joint_labs.label =strrep(joint_labs.label,'Right','R.');
joint_labs.ind(end+1) = 200;
joint_labs.label(end) = {'Cerebellum'};
merged_HOA_lateralized = merged_HOA + 50*(R_Cortical_regions);

writetable(joint_labs,'./HOA_labs.txt');
niftiwrite(merged_HOA_lateralized,output_HOA,nii_info_target,'Compressed',1)

