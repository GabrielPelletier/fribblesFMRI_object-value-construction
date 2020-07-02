function [new_name, scan_type] = renameSeries(old_name)
% function newName = renameSeries(oldName)
% Rename the series name to a more simple name
% and assign scan type (clinical/func/anat/dwi/other
% edited to fit BIDS format

if strfind(old_name,'localizer_3D_2_(9X5X5)')
    new_name='Localizer';
    scan_type = 'clinical';
elseif strfind(old_name,'t2_tirm_tra_dark-fluid_FLAIR');
    new_name='T2w';
    scan_type = 'clinical';
    
% fribBid _sbRef 
elseif strfind(old_name,'cmrr_mbep2d_365vol_S4_TR1.2_SBRef');
    new_name='task-fribBids_sbref';
    scan_type = 'func';
% fribBid scans     
elseif strfind(old_name,'cmrr_mbep2d_365vol_S4_TR1.2')
    new_name='task-fribBids';
    scan_type = 'func';
 
% fLoc _sbRef    
elseif strfind(old_name,'cmrr_mbep2d_165vol_S4_TR1.2_SBRef');
    new_name='task-fLoc_sbref';
    scan_type = 'func';
% fLoc scans
elseif strfind(old_name,'cmrr_mbep2d_165vol_S4_TR1.2');
    new_name='task-fLoc';
    scan_type = 'func';
    
% Other stuf from other scripts
elseif strfind(old_name,'cmrr_mbep2d_100vol_SBRef');
    new_name='task-probe_sbref';
    scan_type = 'func';
elseif strfind(old_name,'cmrr_mbep2d_100vol');
    new_name='task-probe';
    scan_type = 'func';
elseif strfind(old_name,'cmrr_mbep2d_168vol_SBRef');
    new_name='task-localizer_sbref';
    scan_type = 'func';
elseif strfind(old_name,'cmrr_mbep2d_168vol');
    new_name='task-localizer';
    scan_type = 'func';

% Anatomical scans    
elseif strfind(old_name,'MPRAGE_iso1mm')
    new_name='T1w';
    scan_type = 'anat';
elseif strfind(old_name,'MPRAGE')
    new_name='T1w';
    scan_type = 'anat';
elseif strfind(old_name,'MPRAGE_EnchancedContrast')
    new_name='T1w';
    scan_type = 'anat';
elseif strfind(old_name,'FLAIR');
    new_name='T2w';
    scan_type = 'clinical';
elseif strfind(old_name,'ep2d_diff_64dir_iso1.7_b1000')
    new_name='dwi1000';
    scan_type = 'dwi';
elseif strfind(old_name,'ep2d_diff_64dir_iso1.7_b2500');
    new_name='dwi2500';
    scan_type = 'dwi';
elseif strfind(old_name,'gre_field_mapping');
    new_name='gre_field_mapping';
    scan_type = 'other';
elseif strfind(old_name,'epse_B1000_PA');
    new_name='dwi1000pa';
    scan_type = 'dwi';
elseif strfind(old_name,'epse_B2500_PA');
    new_name='dwi2500pa';
    scan_type = 'dwi';
else
    new_name='UnknownScan';
    scan_type = 'other';
    disp(['did not recognize scan series: ' old_name]);
end
end