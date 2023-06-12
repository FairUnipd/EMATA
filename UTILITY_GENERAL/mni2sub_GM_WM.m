function mni2sub_GM_WM(out_path)
%MNI to subject's space coregistraion using FSL FLIRT. it requires WSL to work in Windows Systems
%
%out_path: folder which contains the Pseudo_STATIC PET image. It will be used to store the coregistered images and the transformation matrix
%
%template_path: folder which contains the MNI template and the SSS/ICA boxes

%Written by MDF, 9/21/2022

disp('Starting FSL FLIRT Coregistration')

% in files
MNI_SUVR        = convertpath2lnx(which('FDG_SUVR_extended.nii.gz'));
GM_mask         = convertpath2lnx(which('GM_mask.nii.gz'));
WM_mask         = convertpath2lnx(which('WM_mask.nii.gz'));
PET_static      = convertpath2lnx(fullfile(out_path,'Pseudo_STATIC.nii'));

% out files
MNI_SUVR_coreg  = convertpath2lnx(fullfile(out_path,'FDG_SUVR_cereb_template_flirt_out.nii'));
coreg_matrix    = convertpath2lnx(fullfile(out_path,'coreg_flirt.mat'));
GM_mask_coreg   = convertpath2lnx(fullfile(out_path,'GM_mask_flirt_out.nii'));
WM_mask_coreg   = convertpath2lnx(fullfile(out_path,'WM_mask_flirt_out.nii'));




%% FLIRT coregistration

%Setting commands

cmd_prfx        = get_fsl_command('flirt');
status_FLIRT    = 0;

if ~exist(coreg_matrix)

    %mni 2 sub coreg
    flirt_cmd       = convertcmd2lnx ([cmd_prfx ' -in ' MNI_SUVR ' -ref ' PET_static ' -omat '...
        coreg_matrix ' -out ' MNI_SUVR_coreg ' -dof 12 -v -searchrx -45 45 ' ...
        '-searchry -45 45 -searchrz -45 45']);

    %MNI
    disp('****************************')
    disp("MNI template coregistration to subject's space");
    [status_FLIRT,cmd_out]=system(flirt_cmd,'-echo');

end

%using the previously estimated transformation matrix to transform GM box
flirt_cmd_GM   = convertcmd2lnx ([cmd_prfx ' -in ' GM_mask ' -ref ' PET_static ' -init '...
    coreg_matrix ' -out ' GM_mask_coreg ' -applyxfm -v -interp nearestneighbour']);
%using the previously estimated transformation matrix to transform GM box
flirt_cmd_WM   = convertcmd2lnx ([cmd_prfx ' -in ' WM_mask ' -ref ' PET_static ' -init '...
    coreg_matrix ' -out ' WM_mask_coreg ' -applyxfm -v -interp nearestneighbour']);



%GM
disp('****************************')
disp("Applying transformation to GM mask");
[status_FLIRT_GM,cmd_out]=system(flirt_cmd_GM,'-echo');
%WM
disp('****************************')
disp("Applying transformation to WM mask");
[status_FLIRT_WM,cmd_out]=system(flirt_cmd_WM,'-echo');



if status_FLIRT | status_FLIRT_GM | status_FLIRT_WM

    exception=MException('IDIF_extraction_tool:Fail','FSL FLIRT coregistration failed');
    throw(exception);

end

disp('****************************');
disp('FSL FLIRT coregistration completed!')

end