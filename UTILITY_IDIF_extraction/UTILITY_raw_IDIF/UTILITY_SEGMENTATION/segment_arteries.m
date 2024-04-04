function [Carotids_mask,Pseudo_TOF_final] = segment_arteries(PET_dyn_path,time_PET,out_path,anatomy,options)

[~,~,~,~, IDIFTemp_path, IDIFVessels_path, IDIFQC_path, ~, ~, COREG_path] = out_path_preparation(out_path);

%loading dynPET
[PET_dyn, PET2D, hdr, NIIdyn] = load_PET(PET_dyn_path);
%cleaning PET...
PET_dyn(:,:,1:options.clean_vols_up,:)=0;
PET_dyn(:,:,end-options.clean_vols_down:end,:)=0;

voxsize=hdr.dime.pixdim(2:4);

switch anatomy

    case 'ICA'

        number_of_voxels    = get_num_voxels(options.mask_volume_ICA,voxsize);
        conn_param          = 6;
        opening             = true;
        add_tmode           = options.add_tmode_ICA;

    case 'CCA'

        number_of_voxels    = get_num_voxels(options.mask_volume_CCA,voxsize);
        conn_param          = 6;
        opening             = true;
        add_tmode           = options.add_tmode_CCA;

    otherwise

        disp('Unknown');

        return

end




Carotids_mask_path = fullfile(IDIFVessels_path,[anatomy,'_mask.nii']);

if nargin<5

    options=get_default_options();

end



%loading Carotids box
Carotids_box_coreg = fullfile(COREG_path,[anatomy,'_box_flirt_out.nii.gz']);
Carotids_box = load_nii(Carotids_box_coreg);
Carotids_box_img = Carotids_box.img;

try

    SSS_mask = load_nii(fullfile(IDIFVessels_path,'SSS_mask.nii'));
    SSS_mask = SSS_mask.img;

catch

    disp('No SSS mask. Starting SSS segmentation')

    PET_dyn_struct.PET_dyn  = PET_dyn;
    PET_dyn_struct.PET2D    = PET2D;
    PET_dyn_struct.NIIdyn   = NIIdyn;
    [SSS_mask,~] = segment_SSS(PET_dyn_struct,time_PET,out_path,options);

end

%optimize Pseudo TOF for arteries segmentation
PET_vessels = PET2D(find(SSS_mask),:);
[peaks, peaks_indx] = max(PET_vessels,[],2);
thresh_sum_a = mode(peaks_indx)+ add_tmode;

disp(['Arterial Pseudo-Angiography Generation: Summing up to frame n.' num2str(thresh_sum_a)])

options.PseudoTOF_final_thr = time_PET(thresh_sum_a);
Pseudo_TOF_final = sum(PET_dyn(:,:,:,1:thresh_sum_a),4);

%Carotids segmentation
Pseudo_TOF_final_boxed=Pseudo_TOF_final.*Carotids_box_img;

if sum(Pseudo_TOF_final_boxed(:)) == 0

    exception=MException('IDIF_extraction_tool:Fail','Something went wrong with FLIRT coregistration, or the desired extraction site is not included in the image FOV');
    throw(exception);

end

Carotids_mask=vessels_binary_sum(Pseudo_TOF_final_boxed,number_of_voxels);

%Clean up
se = strel('sphere',1);

if (opening)

    Carotids_mask = imopen(Carotids_mask,se);

end

CC_arterial = bwconncomp(Carotids_mask,conn_param);

numPixels = cellfun(@numel,CC_arterial.PixelIdxList);
[biggest,idx] = sort(numPixels, 'descend');
CC_arterial.PixelIdxList = CC_arterial.PixelIdxList(idx);

CC_arterial.selected_volume = [];
if CC_arterial.NumObjects < 2
    CC_max_number = 1;
else
    CC_max_number = 2;
end
for i = 1:CC_max_number  %length(CC_arterial.TAClist)
    CC_arterial.selected_volume = [CC_arterial.selected_volume; CC_arterial.PixelIdxList{i}];
end


clean_mask= zeros(size(Carotids_mask));
%all_volume(CC_arterial.all_volume) = 1;
clean_mask(CC_arterial.selected_volume) = 1;

Carotids_mask = clean_mask;

%saving results
save_3D_nii(NIIdyn, Carotids_mask, Carotids_mask_path);
save_3D_nii(NIIdyn, Pseudo_TOF_final, fullfile(IDIFTemp_path,['Pseudo_TOF_final_' anatomy '.nii']));

save(fullfile(IDIFQC_path, 'options.mat'), "options");
store_options(options, IDIFQC_path);


%reorienting
%reorient_nifti_to_original(Carotids_mask_path, carotids_path, PET_dyn_path, hdr)

end