function mask=vessels_binary_sum(PET_sum, voxs_thresh,pixdim)
%extract vessels binary mask by processing Jerman filter output
%INPUT: 
% PET_sum: sum of first PET frames
% lastframe: index of the latest volume to sum 
% pixdim (optional): image voxel size
%OUTPUT: 
% vessels mask

%Written by MDF, adapted from ES and AB's code


if nargin<3

    pixdim=[1;1;1];

end

to_mask =PET_sum; %sum(PET_dyn(:,:,:,firstframe:lastframe),4); %8 is arbitrary
to_mask = imgaussfilt3(to_mask, 1);

min_v = 0.5;      %0.1    0.5
max_v = 2;        %2      2
step = 0.5;     %0.1	0.5

vessels_PET = vesselness3D(to_mask, min_v:step:max_v,pixdim,0.5,true);


% figure
% for s=1:size(vessels_PET,3)
%     curr_slice=vessels_PET(:,:,s);
%     imagesc(curr_slice)
%     colorbar
%     pause()
%
% end


% Calcola soglia ottima
[thresh, CC] = my_threshold_PET(vessels_PET,voxs_thresh);

% First cleaning
dim_PET = size(PET_sum);
[CC_arterial] = extract_arterial_CC_PET(CC, dim_PET, PET_sum);

% Saving selected volume
CC_arterial.selected_volume = [];
% if CC_arterial.NumObjects < 2
%     CC_max_number = 1;
% else
%     CC_max_number = CC_arterial.NumObjects;
% end
for i = 1:CC_arterial.NumObjects  %length(CC_arterial.TAClist)
    CC_arterial.selected_volume = [CC_arterial.selected_volume; CC_arterial.PixelIdxList{i}];
end
% 
% CC_arterial.all_volume = [];
% for i = 1:length(CC_arterial.AllPixelIdxList)
%     CC_arterial.all_volume = [CC_arterial.all_volume; CC_arterial.AllPixelIdxList{i}];
% end


all_volume = zeros(size(vessels_PET));
all_volume(CC_arterial.selected_volume) = 1;
%all_volume(CC_arterial.all_volume) = 1;


mask=all_volume;

end
