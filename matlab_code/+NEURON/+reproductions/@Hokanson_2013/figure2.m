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
%----------------------------------------------
%       dual_slice_thresholds: {1x5 cell}
%              dual_slice_xyz: {1x5 cell}
%     single_slice_thresholds: {1x5 cell}
%            single_slice_xyz: {1x5 cell}]
%           internode_lengths:

keyboard

%subplot(1,2,1)

for iFig = 1:2
    figure
    x_points_plot = zeros(1,4);
    y_points_plot = zeros(1,4);
    plot(x_stim,vol_ratio,'Linewidth',3)
    
    
        hold on
        for iDiameter = 1:n_diameters
            diameter_legends{iDiameter} = sprintf('%g um',obj.ALL_DIAMETERS(iDiameter));
            
            if iFig == 2

                [x_points_plot(1),x_points_plot(2),y_points_plot(1),y_points_plot(2)] = ...
                    getLimitInfo(obj,x_stim(:),vol_ratio(:,iDiameter),...
                    extras.single_slice_thresholds{iDiameter},...
                    extras.single_slice_xyz{iDiameter},...
                    extras.internode_lengths(iDiameter));

                [x_points_plot(3),x_points_plot(4),y_points_plot(3),y_points_plot(4)] = ...
                    getLimitInfo(obj,x_stim(:),vol_ratio(:,iDiameter),...
                    extras.dual_slice_thresholds{iDiameter},...
                    extras.dual_slice_xyz{iDiameter},...
                    extras.internode_lengths(iDiameter));

                plotLimits(obj,x_points_plot,y_points_plot)
            
            end

        end
        hold off
    
    
    set(gca,'FontSize',18)
    legend(diameter_legends)
    title('Electrodes spaced 400 um apart in transverse direction')
    xlabel('Stimulus Amplitude (uA)')
    
end

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


%==========================================================================
%==========================================================================

%==========================================================================
%==========================================================================
%TODO: Add labels
I = 1;
figure
subplot(2,1,1)

% [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
%                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);

cur_xyz = extras.single_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.single_slice_thresholds{I})')
set(gca,'CLim',[0 40])
axis equal
colorbar


subplot(2,1,2)
cur_xyz = extras.dual_slice_xyz{I};
imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.dual_slice_thresholds{I})')
set(gca,'CLim',[0 40])
axis equal
colorbar




end