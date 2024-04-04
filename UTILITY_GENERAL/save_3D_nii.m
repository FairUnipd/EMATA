function save_3D_nii(REFnii,matrix,destination)

NII = create_3D_nii(REFnii,matrix);
save_nii(NII,destination)
