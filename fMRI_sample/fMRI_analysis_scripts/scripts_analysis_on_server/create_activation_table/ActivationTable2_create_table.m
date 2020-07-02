clear;
close all;


% Define these variables
task_num=1;
%ses_num=1;
model = 'model013';
zthresh='3.1'; % '2.3' or '3.1'
masking = 'wholeBrain'; % 'wholeBrain', or if SVC specifcy the ROI e.g. 'vmPFC'
cope_lev_1=11;
cope_lev_2=1;
cope_lev_3=1;
visualize_fsleyes=false; % True or False


min_n = 5; % show only ROI with at least this number of voxels
experiment_path='/export2/DATA/FRIB_FMRI/fmri_sample/derivatives';
%group_analysis_path=[experiment_path,'models/model',sprintf('%03.f',model_num),'/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
group_analysis_path = sprintf('%s/group/model/%s/',experiment_path,model);

tmp_path = [pwd,'/tmp']; % where tmporary files will be saved
HO_atlas = [pwd,'/HOA.nii.gz'];
HO_atlas_labs = readtable([pwd,'/HOA_labs.txt']);
HO_atlas_data = niftiread(HO_atlas);

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

switch task_num
    case 1
        num_of_copes_lev1=16;
        contrast_names_lev1={'ConjStim';'ConjStim_mod_value';'SummStim';'SummStim_mod_value';'ConjRate';'ConjRate_mod_value';'SummRate';'SummRate_mod_value';'Rate_mod_Rt';'Stim_mod_accu';'Rate_mod_accu';'ConjStim-SummStim';'ConjStim_mod_value-SummStim_mod_value';'Rate-Stim';'ConjRate_mod_value-SummRate_mod_value';'ConjRate-SummRate'};
        %contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,2,1,1,2,1,1,2,2,2,2,6];
        num_of_copes_lev2 = 1;
        contrast_names_lev2 ={'mean'};
        %contrast_fix_lev2 = [1,1,1,1,2];
        %baseline_2_max = 0.4075; % hight with double gamma - 2s stim
        
    case 2
    case 3

end

contrast_names_lev3={'GroupMean';'GroupMeanInverse'};
task_names={'fribBids'};
task_name=task_names{task_num};
contrast_name_lev1=contrast_names_lev1{cope_lev_1};
contrast_name_lev2=contrast_names_lev2{cope_lev_2};
contrast_name_lev3=contrast_names_lev3{cope_lev_3};
%zthresh_str=strrep(num2str(zthresh),'.','_');
contrast_name = sprintf('%s_%s',contrast_name_lev1,contrast_name_lev3);

%cope_main_path_options=dir([group_analysis_path,'n42_',zthresh,'_',masking]);
cope_main_path_options=dir([group_analysis_path]);

if isempty(cope_main_path_options)
    error('Error: no results directory found. please make sure the paths are correctly defined')
elseif length(cope_main_path_options)==1
    analysis_dir_selection=1;
else
    analysis_dir_selection = listdlg('PromptString','Select an analysis directory:','SelectionMode','single','ListString',{cope_main_path_options.name},'ListSize',[500,400]);
end
origin_dir=[group_analysis_path,cope_main_path_options(analysis_dir_selection).name,sprintf('/group_task-fribBids_cope%i.gfeat/cope%i.feat/',cope_lev_1,cope_lev_2)];
origin_thresh_zstat=[origin_dir,sprintf('thresh_zstat%i.nii.gz',cope_lev_3)];
origin_cluster_mask=[origin_dir,sprintf('cluster_mask_zstat%i.nii.gz',cope_lev_3)];
[~,tmp]=system(['fslstats ',origin_cluster_mask,' -p 100']);
num_of_sig_cluster=str2double(tmp);

std_data_path = sprintf('%s/cluster_zstat%i_std.txt',...
    origin_dir,cope_lev_3);
std_data = readtable(std_data_path);
if num_of_sig_cluster==0
    error('The requested cope has no significant cluster corrected results. Breakdown is irrelevant')
end
HOA_data = niftiread(HO_atlas);
table_headers = {'Contrast','Cluster','Region','Number_of_voxels_in_the_region',...
    'Cluster_size','X','Y','Z','Peak_Z_value','p'};

out_table = [];
for cluster=1:num_of_sig_cluster
    tmp_cluster_mask=sprintf('%s/cluster_mask%i.nii.gz',tmp_path,cluster);
    system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s',...
        origin_cluster_mask,cluster,cluster,tmp_cluster_mask));
    
    cluster_data = niftiread(tmp_cluster_mask);
    cluster_labs = HOA_data(cluster_data==1);
    % remove unlabeled voxels
    cluster_labs(cluster_labs==0)=[];
    delete(tmp_cluster_mask);
    [lab_ind_n,lab_ind]=hist(cluster_labs,unique(cluster_labs));
    if length(unique(cluster_labs)) ==1
    [lab_ind_n,lab_ind]=hist(cluster_labs,1);
    end
    cluster_ROI = HO_atlas_labs.label(ismember(HO_atlas_labs.ind,lab_ind));
    % Sort by number of apprearances
    [lab_ind_n,order] = sort(lab_ind_n,'descend');
    lab_ind = lab_ind(order);
    cluster_ROI = cluster_ROI(order);
    % filter by minimal n
    filter = lab_ind_n > min_n;
    lab_ind_n_f = lab_ind_n(filter);
    lab_ind_f = lab_ind(filter);
    cluster_ROI_f = cluster_ROI(filter);
    num_of_regions = length(cluster_ROI_f);
    
    std_data_tmp = std_data(std_data.ClusterIndex==cluster,:);
    % write data to table
    out_table_tmp = cell(num_of_regions,length(table_headers));
    out_table_tmp{1,1} = contrast_name;
    out_table_tmp{1,2} = cluster;
    try % cluster which are all cerebellum or WM
    [out_table_tmp{:,3}] = cluster_ROI_f{:};
    lab_ind_n_f_tmp = num2cell(lab_ind_n_f(:));
    [out_table_tmp{:,4}] = lab_ind_n_f_tmp{:};
    catch
        out_table_tmp{:,3} = 'other (ventricle or white matter)';
        out_table_tmp{:,4} = 0;
    end
    out_table_tmp{1,5} = std_data_tmp.Voxels;
    out_table_tmp{1,6} = std_data_tmp.Z_MAXX_mm_;
    out_table_tmp{1,7} = std_data_tmp.Z_MAXY_mm_;
    out_table_tmp{1,8} = std_data_tmp.Z_MAXZ_mm_;
    out_table_tmp{1,9} = sprintf('%.3f',std_data_tmp.Z_MAX);
    out_table_tmp{1,10} = std_data_tmp.P;
    
    
    out_table = [out_table;out_table_tmp];
    contrast_name = [];
end

out_table = cell2table(out_table,'VariableNames',table_headers);
%disp(out_table);
writetable(out_table,['activationTable_' contrast_name_lev1 '_' contrast_name_lev3 '_' masking '.csv']);
