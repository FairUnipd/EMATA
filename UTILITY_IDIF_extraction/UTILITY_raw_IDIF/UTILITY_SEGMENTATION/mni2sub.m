function mni2sub(out_path)
%MNI to subject's space coregistraion using FSL FLIRT. it requires WSL to work in Windows Systems
%
%out_path: folder which contains the Pseudo_STATIC PET image. It will be used to store the coregistered images and the transformation matrix
%
%template_path: folder which contains the MNI template and the SSS/ICA boxes

%Written by MDF, 9/21/2022

disp('Starting FSL FLIRT Coregistration')

% in files
MNI_SUVR        = convertpath2lnx(which('FDG_SUVR_extended_norm.nii.gz'));
SSS_box         = convertpath2lnx(which('SSS_box_template_2_extended.nii.gz'));
ICA_box         = convertpath2lnx(which('ICA_box_template_2_extended.nii.gz'));
CCA_box         = convertpath2lnx(which('CCA_box.nii.gz'));
PET_static      = convertpath2lnx(fullfile(out_path,'Pseudo_STATIC.nii'));

% out files
MNI_SUVR_coreg  = convertpath2lnx(fullfile(out_path,'FDG_SUVR_cereb_template_flirt_out.nii'));
coreg_matrix    = convertpath2lnx(fullfile(out_path,'coreg_flirt.mat'));
SSS_box_coreg   = convertpath2lnx(fullfile(out_path,'SSS_box_flirt_out.nii'));
ICA_box_coreg   = convertpath2lnx(fullfile(out_path,'ICA_box_flirt_out.nii'));
CCA_box_coreg   = convertpath2lnx(fullfile(out_path,'CCA_box_flirt_out.nii'));



%% FLIRT coregistration

%Setting commands

cmd_prfx        = get_fsl_command('flirt');



%mni 2 sub coreg
flirt_cmd       = convertcmd2lnx ([cmd_prfx ' -in ' MNI_SUVR ' -ref ' PET_static ' -omat '...
    coreg_matrix ' -out ' MNI_SUVR_coreg ' -dof 12 -v -searchrx -45 45 ' ...
    '-searchry -45 45 -searchrz -45 45']);
%using the previously estimated transformation matrix to transform SSS box
flirt_cmd_SSS   = convertcmd2lnx ([cmd_prfx ' -in ' SSS_box ' -ref ' PET_static ' -init '...
    coreg_matrix ' -out ' SSS_box_coreg ' -applyxfm -v -interp nearestneighbour']);
%using the previously estimated transformation matrix to transform ICA box
flirt_cmd_ICA   = convertcmd2lnx ([cmd_prfx ' -in ' ICA_box ' -ref ' PET_static ' -init ' ...
    coreg_matrix ' -out ' ICA_box_coreg ' -applyxfm -v -interp nearestneighbour']);
%using the previously estimated transformation matrix to transform CCA box
flirt_cmd_CCA   = convertcmd2lnx ([cmd_prfx ' -in ' CCA_box ' -ref ' PET_static ' -init ' ...
    coreg_matrix ' -out ' CCA_box_coreg ' -applyxfm -v -interp nearestneighbour']);


%MNI
disp('****************************')
disp("MNI template coregistration to subject's space");
[status_FLIRT,cmd_out]=system(flirt_cmd,'-echo');
%SSS
disp('****************************')
disp("Applying transformation to SSS box");
[status_FLIRT_SSS,cmd_out]=system(flirt_cmd_SSS,'-echo');
%ICA
disp('****************************')
disp("Applying transformation to ICA box");
[status_FLIRT_ICA,cmd_out]=system(flirt_cmd_ICA,'-echo');
%CCA
disp('****************************')
disp("Applying transformation to CCA box");
[status_FLIRT_CCA,cmd_out]=system(flirt_cmd_CCA,'-echo');


if status_FLIRT | status_FLIRT_SSS | status_FLIRT_ICA | status_FLIRT_CCA

    exception=MException('IDIF_extraction_tool:Fail','FSL FLIRT coregistration failed');
    throw(exception);

end

disp('****************************');
disp('FSL FLIRT coregistration completed!')

end