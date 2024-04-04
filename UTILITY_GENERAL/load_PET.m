function [PET_dyn,PET2D,hdr,NII]=load_PET(path,options)

if nargin<2

    options=get_default_options();
end

img=load_nii(path);
hdr=img.hdr;
PET_dyn=double(img.img);

%cleaning PET...
PET_dyn(:,:,1:options.clean_vols_up,:)=0;
PET_dyn(:,:,end-options.clean_vols_down:end,:)=0;

for t=1:size(PET_dyn,4)
    pet=PET_dyn(:,:,:,t);
    PET2D(:,t)=pet(:);
end

NII = img;
NII.img = []; % for memory efficiency
end