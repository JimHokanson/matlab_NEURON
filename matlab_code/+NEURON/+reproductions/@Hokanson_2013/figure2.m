function figure2(use_long)
%
%   NEURON.reproductions.Hokanson_2013.figure2
%
%   NEURON.reproductions.Hokanson_2013.figure2(true)
%
%   =======================================================================
%                       MULTIPLE FIBER DIAMETERS
%   =======================================================================
%
%   The goal here is to explore the effect of different fiber diameters.
%
%   This is tentatively:
%       NEW FIGURE 2

import NEURON.reproductions.*

C.MAX_STIM_TEST_LEVEL = 30;



obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);

EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);

rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,length(C.FIBER_DIAMETERS));
    for iDiameter = 1:n_diameters
        avr.fiber_diameter = C.FIBER_DIAMETERS{iDiameter};
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all(iPair) = [temp_cell{1,:}];
    rd_all(iPair) = [temp_cell{2,:}];
end







[dual_counts,single_counts,x_stim,extras] = getCountData(obj,...
    C.MAX_STIM_TEST_LEVEL,...
    C.ELECTRODE_LOCATION,...
    C.STIM_WIDTH,...
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



keyboard


%==========================================================================
%==========================================================================

%==========================================================================
%==========================================================================
%TODO: Add labels

n_fibers = length(fiber_diameters);

for iFigure = 1:n_fibers
    
    figure
    subplot(2,1,1)
    
    % [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
    %                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);
    
    cur_xyz = extras.single_slice_xyz{iFigure};
    imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.single_slice_thresholds{iFigure})')
    set(gca,'CLim',[0 40])
    axis equal
    colorbar
    
    
    subplot(2,1,2)
    cur_xyz = extras.dual_slice_xyz{iFigure};
    imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.dual_slice_thresholds{iFigure})')
    set(gca,'CLim',[0 40])
    axis equal
    colorbar
    
end


end