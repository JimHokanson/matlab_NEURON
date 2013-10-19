function figure2()
%
%   NEURON.reproductions.Hokanson_2013.figure2
%
%   =======================================================================
%                       MULTIPLE FIBER DIAMETERS
%   =======================================================================
%
%   The goal here is to explore the effect of different fiber diameters on
%   the volume ratio.
%
%   This is tentatively:
%       NEW FIGURE 2

import NEURON.reproductions.*

DIAMETER_FOR_SLICE = 15;

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3.5];

P.ISO_STIM_PLOT = [5 10 15];

C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};

%SLICE_DIMS    = {'zy' 'xz'};
SLICE_DIMS    = {'xz' 'xz'};

%EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};
EL_LOCATIONS = {[0 0 -200; 0 0 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:n_diameters
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all{iPair} = temp_cell(1,:);
    rd_all{iPair} = temp_cell(2,:);
end

keyboard
%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%1) Standard, vs amplitude ...
figure(1)
clf
for iPair = 1:2
    ax(iPair) = subplot(1,2,iPair);
    final_strings = sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

%Plots at same-amplitude
%This wasn't all that exciting
%--------------------------------------------------------------------------
figure(2)
cla
for iPair = 1:2
    subplot(1,2,iPair)
    final_strings = sl.cellstr.sprintf('%5.2f - uA',P.ISO_STIM_PLOT);
        
    
    cur_rs = rs_all{iPair};
    cur_rd = rd_all{iPair};
    
    n_stim     = length(P.ISO_STIM_PLOT);
    y_values_s = zeros(n_diameters,n_stim);
    y_values_d = zeros(n_diameters,n_stim);
    
    stim_amps = cur_rs{1}.stimulus_amplitudes;
    
    [~,I] = ismember(P.ISO_STIM_PLOT,stim_amps);
    
    for iDiam = 1:n_diameters
       temp_rs = cur_rs{iDiam};
       temp_rd = cur_rd{iDiam};
       y_values_s(iDiam,:) = temp_rs.counts(I);
       y_values_d(iDiam,:) = temp_rd.counts(I);
    end
    
    
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    %obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    plot(C.FIBER_DIAMETERS,y_values_d./y_values_s,'-o');
    legend(final_strings)
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end


% % for iPair = 1:2
% %     
% %     single_strings = sl.cellstr.sprintf('%s - %s: %5.2f - um',TITLE_STRINGS{iPair},'Independent',C.FIBER_DIAMETERS);
% %     double_strings = sl.cellstr.sprintf('%s - %s: %5.2f - um',TITLE_STRINGS{iPair},'Simultaneous',C.FIBER_DIAMETERS);
% %     
% %     titles = [single_strings(:) double_strings(:)];
% %     
% %     obj.plotSlices(rs_all{iPair},rd_all{iPair},titles,'one_by_two',iPair == 2)
% %     %Add on labels
% %     
% % end

%4.5   C, 13.89 Z - Long Single
%2.24  C, 9.16 Z  - Long Double
%13.21 C, 20.37 Z - Trans Single 
%6.61  C, 12.42 Z - Trans Double

values1 = [4.5 13.89 2.24 9.16]; %c z C Z
values2 = [13.21 20.37 6.61 12.42];


%Add these values to figure 1
%--------------------------------------------------------------------------

I = find(C.FIBER_DIAMETERS == DIAMETER_FOR_SLICE);

temp_s1 = rs_all{1}{I};
temp_d1 = rd_all{1}{I};

c1 = temp_d1.counts./temp_s1.counts;
s1 = temp_s1.stimulus_amplitudes;

temp_s2 = rs_all{2}{I};
temp_d2 = rd_all{2}{I};

c2 = temp_d2.counts./temp_s2.counts;
s2 = temp_s2.stimulus_amplitudes;

amps   = {s1 s2};
counts = {c1 c2};
values = {values1 values2};

for iPair = 1:2
    hold(ax(iPair),'all')
    cur_amps = amps{iPair};
    cur_counts = counts{iPair};
    cur_values = values{iPair};
    for iValue = 1:4
       y = interp1(cur_amps,cur_counts,cur_values(iValue));
       plot(ax(iPair),cur_values(iValue),y,'ko')
    end 
end



%X_LIMITS = {[-400 400] [-400 400]; [-500 500] [-500 500]};

X_LIMITS = {[-300 300] [-300 300]; [-300 300] [-300 300]};

X_LIMITS = {[-400 400] [-400 400]; [-400 400] [-400 400]};

C_LIM_MAX_ALL = [25 25; 25 25];

plot_indices = [1 2; 3 4];

figure(3)
clf
for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(2,2,plot_indices(iPair,1))
plot(temp_s.replicated_slice,'lim_dim1',X_LIMITS{iPair,1})
colorbar
set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

subplot(2,2,plot_indices(iPair,2))
plot(temp_d.slice,'lim_dim1',X_LIMITS{iPair,2})
colorbar
set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);


end


%Contour Plotting
%------------------------------------------------------------
%3, 10.2
%9  13.2

amps_plot = [3 9; 8 12];

I = find(C.FIBER_DIAMETERS == DIAMETER_FOR_SLICE);


figure(4)
clf

for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(1,2,iPair)
hold all
contour(temp_s.replicated_slice,amps_plot(iPair,:))
%contour(temp_s.replicated_slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

%subplot(2,2,plot_indices(iPair,2))
contour(temp_d.slice,amps_plot(iPair,:))
%contour(temp_d.slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

end


%====================================================================
%HACK, THIS IS FOR A SETUP PLOT
%====================================================================

amps_plot = [5 10 15; 5 10 15];

I = find(C.FIBER_DIAMETERS == 15);


figure(5)
clf

for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(1,2,iPair)
hold all
contour(temp_s.replicated_slice,amps_plot(iPair,:))
%contour(temp_s.replicated_slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

%subplot(2,2,plot_indices(iPair,2))
contour(temp_d.slice,amps_plot(iPair,:))
%contour(temp_d.slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);
title(TITLE_STRINGS{iPair})
set(gca,'xlim',[-500 500])
axis equal

end







% % % % %subplot(1,2,1)
% % % % 
% % % % for iFig = 1:2
% % % %     figure
% % % %     x_points_plot = zeros(1,4);
% % % %     y_points_plot = zeros(1,4);
% % % %     plot(x_stim,vol_ratio,'Linewidth',3)
% % % %     
% % % %     
% % % %     hold on
% % % %     for iDiameter = 1:n_diameters
% % % %         diameter_legends{iDiameter} = sprintf('%g um',obj.ALL_DIAMETERS(iDiameter));
% % % %         
% % % %         if iFig == 2
% % % %             
% % % %             [x_points_plot(1),x_points_plot(2),y_points_plot(1),y_points_plot(2)] = ...
% % % %                 getLimitInfo(obj,x_stim(:),vol_ratio(:,iDiameter),...
% % % %                 extras.single_slice_thresholds{iDiameter},...
% % % %                 extras.single_slice_xyz{iDiameter},...
% % % %                 extras.internode_lengths(iDiameter));
% % % %             
% % % %             [x_points_plot(3),x_points_plot(4),y_points_plot(3),y_points_plot(4)] = ...
% % % %                 getLimitInfo(obj,x_stim(:),vol_ratio(:,iDiameter),...
% % % %                 extras.dual_slice_thresholds{iDiameter},...
% % % %                 extras.dual_slice_xyz{iDiameter},...
% % % %                 extras.internode_lengths(iDiameter));
% % % %             
% % % %             plotLimits(obj,x_points_plot,y_points_plot)
% % % %             
% % % %         end
% % % %         
% % % %     end
% % % %     hold off
% % % %     
% % % %     
% % % %     set(gca,'FontSize',18)
% % % %     legend(diameter_legends)
% % % %     title('Electrodes spaced 400 um apart in transverse direction')
% % % %     xlabel('Stimulus Amplitude (uA)')
% % % %     
% % % % end


% % % % %==========================================================================
% % % % %==========================================================================
% % % % 
% % % % %==========================================================================
% % % % %==========================================================================
% % % % %TODO: Add labels
% % % % 
% % % % n_fibers = length(fiber_diameters);
% % % % 
% % % % for iFigure = 1:n_fibers
% % % %     
% % % %     figure
% % % %     subplot(2,1,1)
% % % %     
% % % %     % [temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
% % % %     %                             XYZ_MESH_SINGLE,current_pair,STEP_SIZE);
% % % %     
% % % %     cur_xyz = extras.single_slice_xyz{iFigure};
% % % %     imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.single_slice_thresholds{iFigure})')
% % % %     set(gca,'CLim',[0 40])
% % % %     axis equal
% % % %     colorbar
% % % %     
% % % %     
% % % %     subplot(2,1,2)
% % % %     cur_xyz = extras.dual_slice_xyz{iFigure};
% % % %     imagesc(cur_xyz{1},cur_xyz{3},squeeze(extras.dual_slice_thresholds{iFigure})')
% % % %     set(gca,'CLim',[0 40])
% % % %     axis equal
% % % %     colorbar
% % % %     
% % % % end


end