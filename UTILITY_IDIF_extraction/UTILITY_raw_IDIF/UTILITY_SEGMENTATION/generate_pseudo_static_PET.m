function generate_pseudo_static_PET(PET_dyn_path,time_PET,diagnostic_path,options)
%generate a Pseudo STATIC PET image by averaging the frames acquired from
%minute 40 (or as in options) to the end of the acquisition.
%
%PET_dyn_path: PET dynamic NIFTI file path  
%time_PET: time_grid (in seconds)
%out_path: folder where the Pseudo_STATIC.nii will be stored

%Written by MDF, 9/21/2022



Pseudo_STATIC_PET_path = fullfile(diagnostic_path,'Pseudo_STATIC.nii');

if nargin<4

    options=get_default_options();

end

%load PET
[PET_dyn, PET2D, hdr] = load_PET(PET_dyn_path);
%cleaning PET...
PET_dyn(:,:,1:options.clean_vols_up,:)          = 0;
PET_dyn(:,:,end-options.clean_vols_down:end,:)  = 0;

%creating Pseudo STATIC
start_indx = find(time_PET>=options.PseudoStatic_thr,1,'first');
Pseudo_STATIC_PET = mean(PET_dyn(:,:,:,start_indx:end),4);

%calculating percentile thresh according to BRAIN_volume/Acquisition_volume
BRAIN_mean_vol = 1.4e+06; %experimentally determined
acquisition_vol = size(PET_dyn,1)*size(PET_dyn,2)*size(PET_dyn,3)*hdr.dime.pixdim(2)*hdr.dime.pixdim(3)*hdr.dime.pixdim(4); 
percentage = 100*(1-(BRAIN_mean_vol/acquisition_vol));
thresh = prctile(Pseudo_STATIC_PET,round(percentage),'all');
Pseudo_STATIC_PET(Pseudo_STATIC_PET<thresh) = 0;

%saving results
save_3D_nii(PET_dyn_path,Pseudo_STATIC_PET, Pseudo_STATIC_PET_path);
save(fullfile(diagnostic_path,'options.mat'),"options");

%reorienting
%reorient_nifti_to_original(Pseudo_STATIC_PET_path, out_path, PET_dyn_path, hdr)   


end