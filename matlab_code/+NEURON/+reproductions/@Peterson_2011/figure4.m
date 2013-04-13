function figure4(obj)
% recreate figure 4

%% a

%% b

%% c

% define props
fiber_diams = 6:20; % um
N_diams = length(fiber_diams);
electrode_location = [0 200 0]; % 200 um EAS
tissue_resistivity = [obj. resistivity_transverse obj. resistivity_transverse obj.resistivity_longitudinal];

% define stimulus (100 us square pulse)
stim_start_time = 0.1;
stim_durations = 0.1;
stim_amp = -1;

% create simulation
xstim = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_location);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
xstim.elec_objs.setStimPattern(stim_start_time,stim_durations,stim_amp); % set stimulus

% initialize thresholds
activeThresholds = zeros(N_diams,1);

% loop over diameters and test
for iDiam = 1:N_diams
    fiber_diameter = fiber_diams(iDiam);
    cell.props_obj.changeFiberDiameter(fiber_diameter);
    result = xstim.sim__determine_threshold(1);
    activeThresholds(iDiam) = result.stimulus_threshold;
end

% normalize
activeThresholds = activeThresholds./max(activeThresholds);

% plot
figure
plot(fiber_diams,activeThresholds,'o','markersize',6)
xlabel('Axon Diameter [\mum]')
ylabel('Normalized Activation Threshold')
legend('Active Axon Model')
ylim([0 1])

end