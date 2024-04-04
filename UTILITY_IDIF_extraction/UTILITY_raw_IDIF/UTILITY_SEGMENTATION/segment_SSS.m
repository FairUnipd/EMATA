function [SSS_mask,Pseudo_TOF_init]=segment_SSS(PET_dyn_path,time_PET,out_path,options)

[~,~,~,~, IDIFTemp_path, IDIFVessels_path, IDIFQC_path, ~, ~, COREG_path] = out_path_preparation(out_path);

SSS_mask_path = fullfile(IDIFVessels_path,'SSS_mask.nii');

if nargin<4

    options=get_default_options();

end

%loading dynPET
if isa(PET_dyn_path,'struct')

    PET_dyn = PET_dyn_path.PET_dyn;
    NIIdyn  = PET_dyn_path.NIIdyn;
    hdr     = NIIdyn.hdr;

else

    [PET_dyn, ~, hdr, NIIdyn] = load_PET(PET_dyn_path);

end

%cleaning PET...
PET_dyn(:,:,1:options.clean_vols_up,:)=0;
PET_dyn(:,:,end-options.clean_vols_down:end,:)=0;

%loading SSS box
SSS_box_coreg=fullfile(COREG_path,'SSS_box_flirt_out.nii.gz');
SSS_box=load_nii(SSS_box_coreg);
SSS_box_img=SSS_box.img;

%creating Pseudo_TOF_init
thresh_sum_v=find(time_PET>options.PseudoTOF_init_thr,1,'first');
Pseudo_TOF_init=sum(PET_dyn(:,:,:,1:thresh_sum_v),4);
Pseudo_TOF_init_boxed=Pseudo_TOF_init.*SSS_box_img;

if sum(Pseudo_TOF_init_boxed(:)) == 0

    exception=MException('IDIF_extraction_tool:Fail','Something went wrong with FLIRT coregistration, or the Superior Sagittal Sinus is not included in the image FOV');
    throw(exception);

end

%generating SSS mask
voxsize=hdr.dime.pixdim(2:4);
SSS_mask=vessels_binary_sum(Pseudo_TOF_init_boxed,get_num_voxels(options.mask_volume_SSS,voxsize));

%dilating mask
% se=strel('sphere',1);
% SSS_mask=imdilate(SSS_mask,se);

%saving results
save_3D_nii(NIIdyn,SSS_mask, SSS_mask_path);
save_3D_nii(NIIdyn,Pseudo_TOF_init,fullfile(IDIFTemp_path,'Pseudo_TOF_init.nii'));
save(fullfile(IDIFQC_path,'options.mat'),"options");

%reorienting
%reorient_nifti_to_original(SSS_mask_path, out_path, PET_dyn_path, hdr)


end