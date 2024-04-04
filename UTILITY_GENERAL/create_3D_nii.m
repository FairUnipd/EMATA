function NII = create_3D_nii(REFnii,matrix)

if ~ isa(REFnii,'struct')

   REFnii = load_nii(REFnii);

end

REFnii.img = matrix;
REFnii.hdr.dime.scl_slope = 1; 
REFnii.hdr.dime.scl_inter = 0;
REFnii.hdr.dime.dim(1) = 3;
REFnii.hdr.dime.dim(5) = 1;
REFnii.hdr.dime.pixdim(5) = 0;
REFnii.hdr.dime.datatype = 16;
REFnii.hdr.dime.glmax = max(matrix(not(isinf(matrix))));
REFnii.hdr.dime.glmin = min(matrix(not(isinf(matrix))));
REFnii.hdr.dime.cal_max = max(matrix(not(isinf(matrix))));
REFnii.hdr.dime.cal_min = min(matrix(not(isinf(matrix))));

NII = REFnii;