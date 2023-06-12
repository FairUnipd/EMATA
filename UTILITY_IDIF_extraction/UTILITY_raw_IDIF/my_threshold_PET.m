function [thresh, CC] = my_threshold_PET(vessels_PET,voxs_thresh)

% VESSELS ENANCHMENT PET
%load(fullfile(output_path, 'Temp', 'vessels_PET.mat'))

thresh = 0.99;
mask = vessels_PET > thresh;
CC = bwconncomp(mask, 26);

% while CC.NumObjects < 2
%     thresh = thresh - 0.01;
%     mask = vessels_PET > thresh;
% 	CC = bwconncomp(mask, 26);
% end

% Riordino
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = sort(numPixels, 'descend');
CC.PixelIdxList = CC.PixelIdxList(idx);

% Diminuisco la soglia
try
    flag = length(CC.PixelIdxList{1}) + length(CC.PixelIdxList{2}) < voxs_thresh;
catch
    flag = length(CC.PixelIdxList{1}) < voxs_thresh;
end
while flag
    thresh = thresh - 0.01;
    mask = vessels_PET > thresh;
    CC = bwconncomp(mask, 26);
    % Riordino
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = sort(numPixels, 'descend');
    CC.PixelIdxList = CC.PixelIdxList(idx);
    
    try
        flag = length(CC.PixelIdxList{1}) + length(CC.PixelIdxList{2}) < voxs_thresh;
    catch
        flag = length(CC.PixelIdxList{1}) < voxs_thresh;
    end
end

% disp(['prima CC ' num2str(length(CC.PixelIdxList{1})) ', seconda CC ' num2str(length(CC.PixelIdxList{2}))]);

end