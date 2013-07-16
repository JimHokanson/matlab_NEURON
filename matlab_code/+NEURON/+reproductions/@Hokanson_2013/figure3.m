function figure3
%
%   NEURON.reproductions.Hokanson_2013.figure3
%
%   =======================================================================
%                       MULTIPLE STIMULUS WIDTHS
%   =======================================================================
%
%   This is currently NEW FIGURE 3

import NEURON.reproductions.*

EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_AMPLITUDE_DEFAULT = 30; %For 0.2 ms width ...
C.FIBER_DIAMETER           = 15;
C.STIM_WIDTHS_ALL          = [0.050 0.100 0.2 0.40 1 2];
C.DEFAULT_WIDTH_INDEX = find(C.STIM_WIDTHS_ALL  == 0.2);
C.STIM_START_TIME   = 0.1;
C.PHASE_AMPLITUDES  = [-1 0.5];
n_stim_widths              = length(C.STIM_WIDTHS_ALL);

%We might make a separate function that examines reproducing
%work from Yoshida & Horch where for a fixed amplitude they varied the
%pulse width ...
CONST_AMPLITUDE_TESTS = [5 10 15 20];
FONT_SIZE = 18;

obj = NEURON.reproductions.Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.fiber_diameter = C.FIBER_DIAMETER;
avr.quick_test     = true;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

max_stim_amplitudes_by_width = helper__getMaxStimulusAmplitudesByWidth(obj,C);


rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 2:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_stim_widths);
    for iWidth = 1:n_stim_widths
        cur_max_stim       = max_stim_amplitudes_by_width(iWidth);
        cur_stim_width     = C.STIM_WIDTHS_ALL(iWidth);
        avr.stim_widths    = [cur_stim_width 2*cur_stim_width];
        temp_cell{1,iWidth}  = avr.makeRequest(electrode_locations_test,cur_max_stim,...
            'single_with_replication',true);
        temp_cell{2,iWidth}  = avr.makeRequest(electrode_locations_test,cur_max_stim);
    end
    rs_all{iPair} = temp_cell(1,:);
    rd_all{iPair} = temp_cell(2,:);
end

%Plotting Results
%--------------------------------------------------------------------------

keyboard

%Result 1: normalized by amplitude
%Result 2: normalized by charge
%Result 3: normalized by original volume

width_labels = arrayfun(@(x) sprintf('%g ms',x),STIM_WIDTHS_ALL,'un',0);

%Varying Stimulus Amplitude
%==========================================================================
%Normalized by amplitude ...
%---------------------------------------
figure
subplot(1,3,1)
hold all
for iWidth = 1:n_stim_widths
    plot(stim_amps_all{iWidth},ratio_all{iWidth},'linewidth',3)
end
legend(width_labels)
xlabel('Stimulus Amplitude (uA)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by charge
%----------------------------------------
subplot(1,3,2)
hold all
for iWidth = 1:n_stim_widths
    plot(stim_amps_all{iWidth}*STIM_WIDTHS_ALL(iWidth),ratio_all{iWidth},'linewidth',3)
end
legend(width_labels)
xlabel('Stimulus Charge (nC)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by effectiveness
%------------------------------------------
subplot(1,3,3)
cla
hold all

volume_single = cell(1,n_stim_widths);
volume_dual   = cell(1,n_stim_widths);

for iWidth = 1:n_stim_widths
    x_plot = single_counts_all{1,iWidth}.^(1/3);
    plot(x_plot,ratio_all{iWidth},'linewidth',3)    
end
legend(width_labels)
xlabel('Cubed Root Original Recruitment Volume (um^3)^(1/3)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Contours for the same spatial recruitment
% % % % % figure
% % % % % contour_value = [550 550];
% % % % % color_order = get(gca,'ColorOrder');
% % % % % ax = zeros(1,2);
% % % % % for iWidth = 1:n_stim_widths
% % % % %    ax(1) = subplot(1,2,1);
% % % % %    hold all
% % % % %    cur_xyz  = extras.single_slice_xyz{iWidth};
% % % % %    cur_data = squeeze(volume_single{iWidth});
% % % % %    [~,h] = contour(cur_xyz{1},cur_xyz{3},cur_data',contour_value);
% % % % %    set(h,'Color',color_order(iWidth,:));
% % % % %
% % % % %    ax(2) = subplot(1,2,2);
% % % % %    hold all
% % % % %    cur_xyz  = extras.dual_slice_xyz{iWidth};
% % % % %    cur_data = squeeze(volume_dual{iWidth});
% % % % %    [~,h] = contour(cur_xyz{1},cur_xyz{3},cur_data',contour_value);
% % % % %    set(h,'Color',color_order(iWidth,:));
% % % % % end
% % % % % linkaxes(ax)
% % % % % legend(width_labels)


end

function max_stim_amplitudes_by_width = helper__getMaxStimulusAmplitudesByWidth(obj,C)

%Determining rough scaling factors to test
%--------------------------------------------------------------------------
C.DISTANCES_TEST = 20:20:800;
%We should make sure that this is sufficiently
%large so as to encompass MAX_STIM_AMPLITUDE_DEFAULT for our default
%stimulus width
n_x_dist_test = length(C.DISTANCES_TEST);

n_stim_widths              = length(C.STIM_WIDTHS_ALL);

thresholds_current_distance = zeros(n_x_dist_test,n_stim_widths);

fprintf('Running current vs distance tests for stim width normalizaton\n')
for iStim = 1:n_stim_widths
    cur_widths = [C.STIM_WIDTHS_ALL(iStim) 2*C.STIM_WIDTHS_ALL(iStim)];
    
    %TODO: make this a class method that is exposed ...
    %------------------------------------------
    xstim = obj.instantiateXstim([0 0 0]);
    
    xstim.cell_obj.props_obj.changeFiberDiameter(C.FIBER_DIAMETER);
    xstim.elec_objs.setStimPattern(C.STIM_START_TIME,cur_widths,C.PHASE_AMPLITUDES);
    
    %NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
    
    temp_result_obj = xstim.sim__getCurrentDistanceCurve(C.DISTANCES_TEST);
    thresholds_current_distance(:,iStim) = temp_result_obj.thresholds;
end

%We first need to find the distance that the "default" stimulus width
%will activate given the maximum stimulus amplitude at that stimulus width
%that we want to investigate. For example, for a 200 us pulse, how much
%tissue will we activate given the maximum stimulus amplitude we are
%testing
dist_given_max_default_amp = interp1(...
    thresholds_current_distance(:,C.DEFAULT_WIDTH_INDEX),...
    C.DISTANCES_TEST(:),C.MAX_STIM_AMPLITUDE_DEFAULT);

%Next we say, for each stimulus width, how strong a stimulus do we need
%(approximately) to get the same amount of tissue
amps_given_desired_distance = zeros(1,n_stim_widths);
for iStim = 1:n_stim_widths
    amps_given_desired_distance(iStim) = interp1(...
        C.DISTANCES_TEST(:),thresholds_current_distance(:,iStim),...
        dist_given_max_default_amp);
end

%This is a rough approximation which is only correct if the volume
%grows the same way for all stim widths, as we have only examined point on
%the volume, really we would need to also take into account longitudinal
%direction. We round up here as the max amplitudes should be integers.
max_stim_amplitudes_by_width = ceil(amps_given_desired_distance);



end