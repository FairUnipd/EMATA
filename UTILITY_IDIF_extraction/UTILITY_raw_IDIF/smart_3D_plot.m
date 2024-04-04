function smart_3D_plot(mask,xyz,PET2D,hemi_scan,vox_size,angulation,figures_dir,vessel)

x=xyz(:,1);
y=xyz(:,2);
z=xyz(:,3);

indx=sub2ind(size(mask),x,y,z);
PET_voxs=PET2D(indx,:);
peaks=max(PET_voxs,[],2);

%%
figure()

subplot(121)
isosurface(mask)
% hold on
% p = patch(isosurface(vessels_PET,0.5));
% set(p,'FaceColor',blue,'EdgeColor','none');
alpha(0.2);

color_peaks=peaks;
hold on
scatter3(xyz(:,2),xyz(:,1),xyz(:,3),20,color_peaks,'filled');
hold off
colormap jet
caxis([min(color_peaks) max(color_peaks)])
colorbar

daspect(1./vox_size)
view(angulation)
set(gca,'Box','off','color','none')
%%
c=jet;
num_points=size(xyz,1);
new_peaks_grid=linspace(min(peaks),max(peaks),256);
indexes=1:num_points;
displacements=flip(indexes);
subplot(122)
for i=1:num_points
    diff=abs(new_peaks_grid-peaks(i));
    [min_value,idx_min]=min(diff);
    curr_color=c(idx_min,:);
    plot(hemi_scan,(PET_voxs(i,:)./peaks(i))+displacements(i),'Color',curr_color)
    hold on
end
xlabel('time [sec]')
title('Normalized Activity')
set(gca,'color','none','ytick',[],'Box','off','YColor','none')

%%
savefig(fullfile(figures_dir,['Selected_voxels_',vessel,'.fig']));