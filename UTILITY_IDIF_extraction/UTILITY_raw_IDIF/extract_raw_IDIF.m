function [IDIF_raw, TACs_selected, xyz, number_of_final_voxels] = extract_raw_IDIF(PET_dyn_path, t_PET_emi, anatomy, qc_path, mask_path, options)

try
    
    NII_mask        = load_nii(fullfile(mask_path,[anatomy '_mask.nii']));

catch
    
    exception=MException('IDIF_extraction_tool:Fail','Required Anatomical segmentation not present');
    throw(exception);

end

anatomical_mask = NII_mask.img;
voxsize         = NII_mask.hdr.dime.pixdim(2:4);

switch (anatomy)

    case {"ICA"}

        number_of_final_voxels = get_num_voxels(options.selected_volume_ICA,voxsize);
        angulation = [90,0];


    case {"CCA"}

        number_of_final_voxels = get_num_voxels(options.selected_volume_CCA,voxsize);
        angulation = [90,0];

    otherwise

        exception=MException('IDIF_extraction_tool:Fail','Invalid site for IDIF extraction');
        throw(exception);

end


[PET_dyn, PET2D, ~] = load_PET(PET_dyn_path);
%cleaning PET...
PET_dyn(:,:,1:options.clean_vols_up,:)=0;
PET_dyn(:,:,end-options.clean_vols_down:end,:)=0;


[xyz,~,~,mat_IDIF_final,peaks,...
    number_of_final_voxels] = voxels_select(anatomical_mask,...
    PET_dyn,t_PET_emi,number_of_final_voxels);

linear_indexes              = sub2ind(size(anatomical_mask),xyz(:,1),xyz(:,2),xyz(:,3));
mask_voxels                 = zeros(size(anatomical_mask));
mask_voxels(linear_indexes) = peaks;

IDIF_raw        = mean(mat_IDIF_final);
TACs_selected   = mat_IDIF_final;

%saving 3D
save_3D_nii(PET_dyn_path,mask_voxels,fullfile(qc_path,['QC_' anatomy '.nii']));

%smart plot
smart_3D_plot(anatomical_mask, xyz, PET2D,t_PET_emi,voxsize, angulation, qc_path, anatomy);


%plotting IDIF
figure('visible','off')
hold on
plot(t_PET_emi,mat_IDIF_final)
plot(t_PET_emi,IDIF_raw, 'LineWidth',4,'Color','red')
title(['IDIF raw extracted from ', anatomy])
xlabel('time [s]')
ylabel('Activity [Bq/ml]')
exportgraphics(gca,fullfile(qc_path,['IDIF_raw_',anatomy,'.jpeg']),'Resolution',300)



end