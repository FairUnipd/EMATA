function [mask_cluster_bg,centroids] = generate_BG_tissue_mask(anatomy,PET_dyn_path,hemi_scan,K,out_path, qc_path, mask_path, options)

if nargin<7

    options=get_default_options();

end

NII_mask        = load_nii(fullfile(mask_path,[anatomy '_mask.nii']));
mask            = NII_mask.img;

%loading dynPET
[~, PET2D, ~]   = load_PET(PET_dyn_path,options);

%%%%%%%%%%%
%%BG mask%%
%%%%%%%%%%%
se      = strel('sphere',2);
bg_1    = imdilate(mask,se);
bg_2    = imdilate(bg_1,se);


% external background
inside_indexes  = find(bg_1);
bg_indexes      = find(bg_2);
bg_indexes      = bg_indexes(not(ismember(bg_indexes,inside_indexes)));

%extracting background time series
PET_bg = PET2D(bg_indexes,:);


%%%%%%%%%%%%%%%%%
%%Clustering BG%%
%%%%%%%%%%%%%%%%%

%interpolation (to make it uniform)
t_grid_min      = hemi_scan/60;
t_grid_interp   = t_grid_min(1):1:t_grid_min(end);
PET_bg_interp   = interp1(t_grid_min,PET_bg', t_grid_interp');

%late frames extraction
start_time          = min(find(t_grid_interp>30,1,'first'));
late_PET_bg_interp  = PET_bg_interp(start_time:end,:);

%clustering (K fixed)
%K=3;
cl = kmeans(late_PET_bg_interp',K, 'Replicates',500);

%bg mask with clusters
mask_cluster_bg             = zeros(size(mask));
mask_cluster_bg(bg_indexes) = cl;

%view and save centroids (as centroids)
centroids   = zeros(size(PET_bg,2),K);
time_bg        = hemi_scan;
figure('visible','off')

for i=1:K

    subplot(K,1,i)
    PET_curr_cl=PET_bg(cl==i,:);
    plot(t_grid_min,PET_curr_cl)
    hold on
    plot(t_grid_min,median(PET_curr_cl,1), 'LineWidth',4, 'Color','red')
    xlabel('time [min]')
    ylabel('Activity [Bq/ml]')
    hold off
    centroids(:,i)=median(PET_curr_cl,1);

end

exportgraphics(gcf,fullfile(qc_path,[anatomy '_BG_cluster.jpeg']),'Resolution',300)

%reassigning clusters (sorted)
[~,sorted_cl]=sort(centroids(end,:),'ascend');
tmp=mask_cluster_bg;
for i=1:K
    mask_cluster_bg(tmp==sorted_cl(i))=i;
end

centroids_bg = centroids(:,sorted_cl);


%plotting centroids with same scale
figure('visible','off')
plot(t_grid_min,centroids_bg,'LineWidth', 2)
xlabel('time [min]')
ylabel('Activity [Bq/ml]')
legend(cellfun(@num2str,num2cell([1:K]')))
exportgraphics(gcf,fullfile(qc_path,[anatomy,'_BG_cluster_centroids.jpeg']),'Resolution',300)


%Saving
mask_name=[anatomy,'_BG_',num2str(K),'_clusters_mask.nii'];
save_3D_nii(PET_dyn_path,mask_cluster_bg,fullfile(out_path,mask_name));

%saving struct
save(fullfile(out_path,['BG_',anatomy,'.mat']),'mask_cluster_bg','centroids_bg','time_bg');

store_options(options,qc_path);

end

