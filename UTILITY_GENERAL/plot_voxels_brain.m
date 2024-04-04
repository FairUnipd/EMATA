function plot_voxels_brain(COREG_path, IDIF_path, anatomy1, anatomy2)
%Transforming MNI

coreg_matrix   = convertpath2lnx(fullfile(COREG_path,'coreg_flirt.mat'));

MNI_brain_path = '/nfsd/biopetmri4/Projects/lavori_PET/IDIF_extraction_tool/Test_tool/Template_OLD/MNI152_T1_1mm_brain_extended.nii.gz';
MNI_head_path = '/nfsd/biopetmri4/Projects/lavori_PET/IDIF_extraction_tool/Test_tool/Template_OLD/HEAD_PD/HEAD_2_MNI_extended_bin.nii.gz';
MNI_brain2sub  = fullfile(COREG_path,'MNIBRAIN2PET.nii.gz');
MNI_head2sub  = fullfile(COREG_path,'MNIHEAD2PET.nii.gz');

REF            = fullfile(COREG_path,'Pseudo_STATIC.nii');

cmd_prfx       = get_fsl_command('flirt');
flirt_cmd   = convertcmd2lnx ([cmd_prfx ' -in ' MNI_brain_path ' -ref ' REF ' -init '...
    coreg_matrix ' -out ' MNI_brain2sub ' -applyxfm -v']);


[status_FLIRT,cmd_out]=system(flirt_cmd,'-echo');

flirt_cmd   = convertcmd2lnx ([cmd_prfx ' -in ' MNI_head_path ' -ref ' REF ' -init '...
    coreg_matrix ' -out ' MNI_head2sub ' -applyxfm -v']);


[status_FLIRT,cmd_out]=system(flirt_cmd,'-echo');

%% GENERATING figure
load(fullfile(IDIF_path,['IDIF_' anatomy1 '.mat']));

MASK_NII  = load_nii(fullfile(IDIF_path, 'Vessels', [anatomy1 '_mask.nii']));
BRAIN_NII = load_nii(MNI_brain2sub);
HEAD_NII = load_nii(MNI_head2sub);

figure


p = patch(isosurface(BRAIN_NII.img,max(BRAIN_NII.img(:))/1.5));
set(p,'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','LineStyle',":",'FaceAlpha',1);

hold on

p = patch(isosurface(HEAD_NII.img,0.5));
set(p,'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','LineStyle',":",'FaceAlpha',0.1);


p = patch(isosurface(MASK_NII.img,0.3));

set(p,'FaceColor','red','EdgeColor','none','LineStyle',":",'FaceAlpha',0.5);

daspect(1./[MASK_NII.hdr.dime.pixdim(2) MASK_NII.hdr.dime.pixdim(3) MASK_NII.hdr.dime.pixdim(4)])

scatter3(IDIF.voxs.xyz(:,2),IDIF.voxs.xyz(:,1),IDIF.voxs.xyz(:,3),20,"blue", 'filled');

set(gcf,'color','white')
axis off

if nargin > 3

    load(fullfile(IDIF_path,['IDIF_' anatomy2 '.mat']));

    MASK_NII  = load_nii(fullfile(IDIF_path, 'Vessels', [anatomy2 '_mask.nii']));

    p = patch(isosurface(MASK_NII.img,0.3));
    set(p,'FaceColor','red','EdgeColor','none','LineStyle',":",'FaceAlpha',0.5);



    scatter3(IDIF.voxs.xyz(:,2),IDIF.voxs.xyz(:,1),IDIF.voxs.xyz(:,3),20,"blue", 'filled');



end

camlight
lighting gouraud

