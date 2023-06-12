function IDIF_extraction_wrapper(PET_dyn_path, t_PET_emi, t_PET_delta, anatomy, qc_path, IDIFVessels_path, IDIF_path, options)


if nargin < 7

    options = get_default_options();

end

[IDIF_raw, TACs_selected, xyz, number_of_final_voxels] = extract_raw_IDIF(PET_dyn_path, t_PET_emi, anatomy, qc_path, IDIFVessels_path, options);

IDIF.IDIF_raw   = IDIF_raw;
IDIF.t_IDIF_raw = t_PET_emi;
IDIF.t_IDIF_delta = t_PET_delta;

IDIF.IDIF       = IDIF.IDIF_raw;
IDIF.t_IDIF     = IDIF.t_IDIF_raw;

IDIF.flag_Feng  = 0;
IDIF.flag_Chen  = 0;

IDIF.voxs.selected_TACs             = TACs_selected;
IDIF.voxs.xyz                       = xyz;
IDIF.voxs.number_of_final_voxels    = number_of_final_voxels;

save(fullfile(IDIF_path,['IDIF_',anatomy,'.mat']),'IDIF');
store_options(options, qc_path);
