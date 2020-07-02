%%
%%%  pydeface STILL DOES NOT WORK when called from matlab ...
%%%  defacing has to be done via terminal...

% from terminal call run_pydeface.sh 0SUBNUM1 0SUBNUM2 ...

% This script is to deface anatomical t1w.nii images
% 
% It uses the bash script run_pydeface.sh
% which is located in 	...
% If you need to modify it. The BIDS directory is defined in it.
%
% This bash script runs pydeface AND overwrites the T1w image with the newly
% defaced image (that now has the same name as the orignial t1w).


%% Which participants to deface?
participants = [448];

%bids_path = '/Users/roni/Desktop/GabrielP/fribblesFMRI/fmri_sample/BIDS/';


for subject_ind = 1:length(participants)
    
   sub_id = ['0' num2str(participants(subject_ind))];
   
%% Deface using pydeface
% Can't have this work for now, maybe later. For now, must do this on the
% terminal. 

    %fprintf('\nTo run pydeface, copy/paste this command in the terminal:\nrun_pydeface.sh %s\n', sub_id);
    % !! If this does not work because of some Python-relarted error, close
    % the terminal and open it again, it will reset the defaul python
    % path and version. !!
    
    fprintf('\npydeface /Users/rotembotvinik/Desktop/GabrielP/fribbles_fMRI/BIDS/sub-%s/anat/sub-%s_T1w.nii.gz\n',sub_id, sub_id);
    
%[status,cmdout] = system(['run_pydeface.sh ' sub_id])
 
end


