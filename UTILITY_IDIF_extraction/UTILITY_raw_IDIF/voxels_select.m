function [xyz_final,matrix_first_flag,matrix_second_flag, mat_IDIF_final, peaks,number_of_final_voxels]=voxels_select(mask,PET_dyn,t_IDIF_emi,number_of_final_voxels)

n_sampling = size(PET_dyn,4);

for t=1:n_sampling
    curr_PET=PET_dyn(:,:,:,t);
    PET2D(:,t)=curr_PET(:);
end
matrix=PET2D(find(mask),:);

%%
%%%%%%%%%%%%%%
% CLEANING %
%%%%%%%%%%%%%%

% First cleaning
% Peak position and amplitude
p_0_tMax = zeros(size(matrix,1),1);
p_1_vMax = zeros(size(matrix,1),1);
for i = 1:size(matrix,1)
    [vals,idxs] = sort(matrix(i,:),'descend');
    p_1_vMax(i,1) = vals(1);
    p_0_tMax(i,1) = idxs(1);
    %     if p_1_vMax(i) > 5*10^4
    %         n_picchi(i,1) = numel(findpeaks(max(matrix(i,:), vals(1)*0.5*ones(1,length(t_IDIF_emi)))));
    %     else
    %         n_picchi(i,1) = 1;
    %     end
end

% Mean value (TAC tail)
p_2_vTail = mean(matrix(:,(end-3):end),2);

%Retrieving 3D coordinates of mask voxels
[x,y,z] = ind2sub(size(mask),find(mask));
xyz = [x y z];


% Selecting peaks whose time is synchronized with t_mode
%keep_peak = logical(sign(p_1_vMax - 5*mean(p_2_vTail))+1);
t_mode = mode(p_0_tMax);
right_time = (p_0_tMax == t_mode); %mode(p_0_tMax) t_mode
%one_peak = n_picchi == 1;
% flag_1 = keep_peak & one_peak & right_time;
flag_1 = right_time;

matrix_first_flag = matrix(flag_1,:);
xyz = xyz(flag_1,:);

p_1_vMax = p_1_vMax(flag_1,:);
p_0_tMax = p_0_tMax(flag_1,:);
p_2_vTail = p_2_vTail(flag_1,:);
mat_param = [p_1_vMax, p_2_vTail];


%%

% k-means parametrico
n_cluster_kmeans = 2;
p_3_AUC = zeros(size(matrix_first_flag,1),1);
p_4_eSlope = zeros(size(matrix_first_flag,1),1);
p_5_mSlope = zeros(size(matrix_first_flag,1),1);
p_6_AUC = zeros(size(matrix_first_flag,1),1);
for i = 1:size(matrix_first_flag,1)
    % AUC

    interval = 1; %10 meglio di 5


    p_3_AUC(i,1) = trapz(t_IDIF_emi(1:(p_0_tMax(i)+interval )), matrix_first_flag( i,1:(p_0_tMax(i)+interval) ));

    % ENDING SLOPE
    interval_end = 2; %1
    X = t_IDIF_emi(end-interval_end:end)';
    Y = matrix_first_flag(i,end-interval_end:end)';
    G = [X ones(size(X))];
    slope_end = G\Y;
    slope_end = slope_end(1);
    p_4_eSlope(i,1) = slope_end;

    % RISING SLOPE
    interval_max = 2; %2
    starting = p_0_tMax(i)-interval_max;
    if starting <= 0

        starting = 1;

    end
    X = t_IDIF_emi(starting:p_0_tMax)';
    Y = matrix_first_flag(i,starting:p_0_tMax)';
    G = [X ones(size(X))];
    slope_max = G\Y;
    slope_max = slope_max(1);
    p_5_mSlope(i,1) = slope_max;

    % AUC AFTER PEAK

    interval=10;
    %10
    p_6_AUC(i,1) = trapz(t_IDIF_emi((p_0_tMax(i)+1):min((p_0_tMax(i)+interval ), n_sampling)), matrix_first_flag( i,(p_0_tMax(i)+1):min((p_0_tMax(i)+interval), n_sampling) ));

    % SD TAC
    p_7_SD(i,1) = std2(matrix_first_flag(i,:));
end
mat_param = [mat_param, p_3_AUC, p_4_eSlope, p_5_mSlope, p_7_SD];

% Normalization
mat_param = mat_param/max(mat_param);

% K-means
idx_peak = kmeans(mat_param,n_cluster_kmeans,'Distance','sqeuclidean','Replicates',500);
for i = 1:n_cluster_kmeans
    if nnz((idx_peak == i)) > 0
        centroids(i,:) = mean(matrix_first_flag((idx_peak == i),:));
        % disp(mean(mat_param(idx == i,:)))
    else
        centroids(i,:) = matrix_first_flag((idx_peak == i),:);
    end
end

[~, keep_cluster2] = max(max(centroids,[],2)); %keep cluster with max peak

flag_2 = (idx_peak == keep_cluster2);

matrix_second_flag = matrix_first_flag((flag_2),:);
xyz = xyz(flag_2,:);
disp(['Keeping only ' num2str(size(matrix_second_flag,1)) ' out of ' num2str(length(matrix_first_flag)) ' voxels after k-means'])



peaks = max(matrix_second_flag,[],2);
[~, indx] = sort(peaks, 'descend');


%Selecting the first N voxels according to peak
if size(matrix_second_flag,1) >= number_of_final_voxels

    disp(['Selecting the best ' num2str(number_of_final_voxels) ' voxels']);

else
    number_of_final_voxels = size(matrix_second_flag,1);
    disp([num2str(number_of_final_voxels) ' were selected']);
end

mat_IDIF_final = matrix_second_flag((indx(1:number_of_final_voxels)),:);
xyz_final = xyz((indx(1:number_of_final_voxels)),:);


peaks=peaks(indx(1:number_of_final_voxels),:);
end