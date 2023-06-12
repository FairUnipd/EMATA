function [CC_arterial] = extract_arterial_CC_PET(CC, dim_TOF_c, dynIDIF)

CC_arterial = CC;

numPixels = cellfun(@numel,CC_arterial.PixelIdxList);
[biggest,idx] = sort(numPixels, 'descend');
CC_arterial.PixelIdxList = CC_arterial.PixelIdxList(idx);

% Tolgo le componenti connesse  che sono piccole
to_remove = [];
size_voxel = 1;
for i = 1:CC_arterial.NumObjects
    [~, ~, z] = ind2sub(dim_TOF_c,CC_arterial.PixelIdxList{i});
    if biggest(i) < 100 || std2(z) < 1
        to_remove = [to_remove i];
    end
end

CC_arterial.AllPixelIdxList = CC_arterial.PixelIdxList;
CC_arterial.PixelIdxList(to_remove) = [];
CC_arterial.NumObjects = CC_arterial.NumObjects-length(to_remove);

% % ESTRAGGO TAC per le varie regioni connesse ed ELIMINO I TESSUTI
% for i = 1:CC_arterial.NumObjects
%     [CL_x,CL_y,CL_z] = ind2sub(dim_TOF_c,CC_arterial.PixelIdxList{i});
%     matrix_temp = [];
%     for k = 1:length(CL_x)
%         matrix_temp(k,1:size(dynIDIF,4)) =  squeeze(dynIDIF(CL_x(k),CL_y(k),CL_z(k),:));
%     end
%     
%     CC_arterial.TAClist{i} = mean(matrix_temp);
%     
% end
% CC_backup = CC_arterial;
% 
% for i = 1:length(CC_arterial.TAClist)
%     matrix_TAC(i,:) = CC_arterial.TAClist{i};
% end
% 
% number_of_cluster = 3;
% if size(matrix_TAC,1) < number_of_cluster
%     number_of_cluster = size(matrix_TAC,1)-1;
% end
% if size(matrix_TAC,1) == 1
%     number_of_cluster = 1;
% end
% 
% idx = kmeans(matrix_TAC, number_of_cluster,'Distance','correlation','Replicates',500);
% 
% % Z = linkage(matrix_TAC, 'complete');
% % idx = cluster(Z,'maxclust',number_of_cluster);
% 
% centroids = zeros(number_of_cluster, size(dynIDIF,4));
% 
% for i = 1:number_of_cluster
%         centroids(i,:) = mean(matrix_TAC((idx == i),:));
% end
% 
% % Rimuovo le CC con TAC tessutali
% [val, keep] = max(max(centroids'));
% matrix_TAC = matrix_TAC((idx == keep),:);
% to_keep = (idx == keep);
% CC_arterial.PixelIdxList = CC_arterial.PixelIdxList(to_keep);
% CC_arterial.TAClist = CC_arterial.TAClist(to_keep);
% CC_arterial.NumObjects = sum(to_keep~=0);

end