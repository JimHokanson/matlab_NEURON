I = 4;

subplot(1,2,1)

% [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
%                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);

cur_xyz = extras.single_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.single_slice_thresholds{I})')
axis equal
colorbar

subplot(1,2,2)
cur_xyz = extras.dual_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.dual_slice_thresholds{I})')
axis equal
colorbar

figure
I = 4;

subplot(1,2,1)

% [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
%                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);

cur_xyz = extras.single_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(volume_single{I})')
axis equal
colorbar
set(gca,'CLim',[50 950])

subplot(1,2,2)
cur_xyz = extras.dual_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(volume_dual{I})')
axis equal
colorbar
set(gca,'CLim',[50 950])
