function figure6(obj)

% figure 6
% 100 us pulse, 10 um diameter, 200um EAS
% arranged as in fig 1c, one stationary above 0,0,0, one moves further away

% general props
EAS = 200;
fiber_diameter = 10;
tissue_resistivity = [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal];

% stimulus
stim_start_time = 0.1;
stim_duration = 0.1; % 100 us
stim_amps = {-1 -1};

% initial electrode locations (initially overlapping)
electrode_locations = zeros(2,3);
electrode_locations(:,2) = EAS; % NOTE: cell will not need to be moved from origin
% will vary electrode_locations(2,3) to move second electrode along axon

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_locations);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
cell.props_obj.changeFiberDiameter(fiber_diameter);
electrodes = xstim.elec_objs;
electrodes.setStimPattern(stim_start_time,stim_duration,stim_amps);

% get actual inter-electrode spacings
internodal_length = cell.props_obj.internode_length;
internodal_ratio_spacings = 0:0.25:8;
elec_spacing_all = internodal_ratio_spacings*internodal_length; % not sure if 0 will cause an issue, but it's on the graph
N_elec_spacing = length(elec_spacing_all);


% initialize thresholds
thresh_active = zeros(N_elec_spacing,1);
thresh_mdf1 = thresh_active;
thresh_mdf2 = thresh_active;

for i_elec_spacing = 1:N_elec_spacing
    % move second electrode
   electrode_locations(2,3) = elec_spacing_all(i_elec_spacing);
   electrodes(2).moveElectrode(electrode_locations(2,:));
   
   % active sim
   result = xstim.sim__determine_threshold(1);
   thresh_active(i_elec_spacing) = result.stimulus_threshold;
   %mdf1
   thresh_mdf1(i_elec_spacing) = obj.computeThreshold(xstim,1);
   thresh_mdf2(i_elec_spacing) = obj.computeThreshold(xstim,2);
   
end

% threshold error
mdf1_error = obj.thresholdError(thresh_mdf1,thresh_active);
mdf2_error = obj.thresholdError(thresh_mdf2,thresh_active);

% plot
figure
plot(internodal_ratio_spacings,mdf1_error,'s--',internodal_ratio_spacings,mdf2_error,'-')
fontsize = 15;
xlabel('Inter-Electrode-Spacing [Internodal Lengths]','fontsize',fontsize)
ylabel('Threshold Error [%]','fontsize',fontsize)
%ylim([-20 80])
legend('Single Node Method','Weighted Sum Method')
set(gca,'fontsize',fontsize - 2)

end