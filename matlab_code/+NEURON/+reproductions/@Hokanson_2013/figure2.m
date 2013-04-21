function figure2()
%
%   NEURON.reproductions.Hokanson_2013.figure2
%
%   MULTIPLE FIBER DIAMETERS
%
%   The goal here is to explore the effect of different fiber diameters.
%
%   This is tentatively:
%       NEW FIGURE 2

obj = NEURON.reproductions.Hokanson_2013;

MAX_STIM_TEST_LEVEL      = 30;
ELECTRODE_LOCATION       = obj.ALL_ELECTRODE_PAIRINGS(7);
STIM_SPACING             = 200; %Change this if above changes ...
STIM_WIDTH               = {[0.2 0.4]};

fiber_diameters          = obj.ALL_DIAMETERS;

[dual_counts,single_counts,x_stim,extras] = getCountData(obj,...
    MAX_STIM_TEST_LEVEL,...
    ELECTRODE_LOCATION,...
    STIM_WIDTH,...
    fiber_diameters);

vol_ratio = dual_counts./single_counts;

n_diameters      = length(fiber_diameters);
diameter_legends = cell(1,n_diameters);

%extras
%       dual_slice_thresholds: {1x5 cell}
%              dual_slice_xyz: {1x5 cell}
%     single_slice_thresholds: {1x5 cell}
%            single_slice_xyz: {1x5 cell}

keyboard

%subplot(1,2,1)

plot(x_stim,vol_ratio,'Linewidth',3)
hold on
for iDiameter = 1:n_diameters
    diameter_legends{iDiameter} = sprintf('%g um',obj.ALL_DIAMETERS(iDiameter));
    

    %Get min points
    %I would like to have this be a method ...
    dual_t   = extras.dual_slice_thresholds{iDiameter};
    single_t = extras.single_slice_thresholds{iDiameter}; 

    t_min_z_dual   = min(dual_t(:,:,1));
    t_min_x_dual   = min(dual_t(ceil(size(dual_t,1)/2),:,:));
    t_min_z_single = min(single_t(:,:,1));
    
    x_single       = extras.single_slice_xyz{iDiameter}{1};
    t_min_x_single = min(single_t(x_single == STIM_SPACING,:,:));
    
    all_values = [t_min_x_single t_min_z_single t_min_x_dual t_min_z_dual];
    chars      = 'xzXZ';
    for iVal = 1:4
       y_val = interp1(x_stim(:),vol_ratio(:,iDiameter),all_values(iVal));
       s = text(all_values(iVal),y_val,chars(iVal));
       set(s,'FontSize',18)
    end
end
hold off

set(gca,'FontSize',18)
legend(diameter_legends)
title('Electrodes spaced 400 um apart in transverse direction')
xlabel('Stimulus Amplitude (uA)')


% % % [~,I] = max(vol_ratio);
% % % max_vol_ratio_stim_amps = x_stim(I);
% % % subplot(1,2,2)
% % % cla
% % % hold all
% % % for iDiameter = 1:n_diameters
% % %    cur_xyz  = extras.dual_slice_xyz{iDiameter};
% % %    cur_data = squeeze(extras.dual_slice_thresholds{iDiameter}); 
% % %    
% % %    %contour_value = [max_vol_ratio_stim_amps(iDiameter) max_vol_ratio_stim_amps(iDiameter)];
% % %    
% % %    %contour_value = contour_value - 0.3;
% % %    
% % %    contour_value = [11 11];
% % %    
% % %    contour(cur_xyz{1},cur_xyz{3},cur_data',contour_value)
% % % end
% % % hold off
% % % set(gca,'YLim',[-800 800])

keyboard

% % % I = 3;
% % % 
% % % subplot(1,2,1)
% % % 
% % % % [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
% % % %                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);
% % % 
% % % cur_xyz = extras.single_slice_xyz{I};
% % % imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.single_slice_thresholds{I})')
% % % axis equal
% % % colorbar
% % % 
% % % subplot(1,2,2)
% % % cur_xyz = extras.dual_slice_xyz{I};
% % % imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.dual_slice_thresholds{I})')
% % % axis equal
% % % colorbar




end