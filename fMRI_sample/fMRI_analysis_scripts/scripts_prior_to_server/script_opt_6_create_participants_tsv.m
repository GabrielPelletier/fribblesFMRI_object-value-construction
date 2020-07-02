%% Template Matlab script to create an BIDS compatible participants.tsv file
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase
%
% DHermes, 2017
% modified RG 201809

%%
clear
root_dir = '/Users/roni/Desktop/GabrielP/fribblesFMRI/fmri_sample';
project_label = 'BIDS';

participants_tsv_name = fullfile(root_dir,project_label,...
    'participants.tsv');

%% make a participants table and save 

participant_id = {'sub-0301'; 'sub-0302'; 'sub-0303'; 'sub-0304'; 'sub-0305'; 'sub-0306'; 'sub-0307'; 'sub-0308'};
%age = [nan; nan; nan; nan; nan; nan; nan; nan];
%sex = {nan; nan; nan; nan; nan; nan; nan; nan}; 

%t = table(participant_id,age,sex);

t = table(participant_id);

writetable(t,participants_tsv_name,'FileType','text','Delimiter','\t');

