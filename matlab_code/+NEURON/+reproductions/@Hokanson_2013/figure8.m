function figure8()
%
%   NEURON.reproductions.Hokanson_2013.figure8
%
%   Not used in the paper.
%
%   =======================================================================
%           Different electrode configurations, diagonal, 3 and 4
%   =======================================================================
%
%   The goal here is to explore the effect of different fiber diameters on
%   the volume ratio.
%

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 8];

C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test      = true;
%avr.merge_solvers  = true;
avr.use_new_solver  = true;

%Titles need to be changed ...
TITLE_STRINGS = {'2 electrodes diagonal' '3 electrodes' '4 electrodes'};
SLICE_DIMS    = {'zy' 'xz'};
EL_LOCATIONS = {[-200 -50 -200; 200 50 200;] [-200 -50 -200; 200 50 200; -200 50 200;] [-200 -50 -200; 200 -50 -200; -200 50 200; 200 50 200]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    fprintf(2,'iPair %d\n',iPair);
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:n_diameters
        fprintf(2,'Diamater %d\n',iDiameter);
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        fprintf(2,'Single\n');
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        fprintf(2,'Double\n');
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
for iPair = 1:2
    subplot(1,2,iPair)
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair},rd_all{iPair});
    legend(final_strings)
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

for iPair = 1:2
    
    single_strings = NEURON.sl.cellstr.sprintf('%s - %s: %5.2f - um',TITLE_STRINGS{iPair},'Independent',C.FIBER_DIAMETERS);
    double_strings = NEURON.sl.cellstr.sprintf('%s - %s: %5.2f - um',TITLE_STRINGS{iPair},'Simultaneous',C.FIBER_DIAMETERS);
    
    titles = [single_strings(:) double_strings(:)];
    
    obj.plotSlices(rs_all{iPair},rd_all{iPair},titles,'one_by_two',iPair == 2)
    %Add on labels
    
end

%2) Threshold Plots ...














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