function Patlak_wrapper(PET_dyn_path, t_PET_emi, t_PET_delta, BRAIN_path, Cp_in, Cp_time, anatomy,out_path, options)

if nargin<9

    options = get_default_options();

end


[~, PET2D, ~]=load_PET(PET_dyn_path);
[PET_brain, PET2D_brain, ~]=load_PET(BRAIN_path);
voxs=find(PET2D_brain>0.1); % 0.5 if not normalized

nr_points=length(find(t_PET_emi>=options.Patlak_start)); 
%%

Ki_vec  = zeros(1,length(voxs));
Ki_CV   = zeros(1,length(voxs));
WB_TAC  = mean(PET2D(voxs,:));

warning off
for vv =1:length(voxs)
    %fprintf('*')   
    TAC     = PET2D(voxs(vv),:);
    %weights = corrected_weights02(TAC, t_PET_delta).^2;
    weights = corrected_weights02(WB_TAC, t_PET_delta).^2;
    weights = adjustweights(weights);
    [Cp,Cpint,time,TAC_extended,weights] = setPatlak(Cp_in',Cp_time',t_PET_emi',TAC',weights);
    [Kp, stdKp] = Patlak(TAC_extended,time,Cp,Cpint,weights,nr_points);
    Ki_vec(vv) = Kp;
    Ki_CV(vv) = stdKp/Kp*100;
    
end
warning on
%%

Ki_vec(Ki_vec<0)    = 0;
Ki_vec(Ki_CV>=300)  = 0; %>300?

Ki_map              = zeros(size(PET_brain));
Ki_map(voxs)        = Ki_vec;

Ki_gauss_map        = imgaussfilt3(Ki_map,0.5);

Ki_CV(Ki_vec<0)    = 0;
%Ki_CV(Ki_CV>=300)  = 0;
Ki_CV_map          = zeros(size(PET_brain));
Ki_CV_map(voxs)    = Ki_CV;


%%
if ~strcmp(anatomy,'')

    anatomy = ['_' anatomy];

end

save_3D_nii(BRAIN_path,Ki_map,fullfile(out_path,['Ki' anatomy '_WB.nii.gz']));
save_3D_nii(BRAIN_path,Ki_gauss_map,fullfile(out_path,['Ki_gauss' anatomy '_WB.nii.gz']));
save_3D_nii(BRAIN_path,Ki_CV_map,fullfile(out_path,['Ki_CV' anatomy '_WB.nii.gz']));

end