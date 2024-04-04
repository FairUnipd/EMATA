function num_voxs=get_num_voxels(volume,voxsize)
%Simple function to get the desired number of voxels given the PET image
%vox_size

%Written by MDF, 10/20/2022


vox_volume  = voxsize(1)*voxsize(2)*voxsize(3);
num_voxs    = round(volume/vox_volume);

end