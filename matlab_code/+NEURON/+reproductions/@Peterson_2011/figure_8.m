function figure_8(obj)
% recreate figure 8
%
%   p = NEURON.reproductions.Peterson_2011
%   p.figure_8
%

% define props
EAS_all = [50,300]; % um, place cell at these locations, center electrodes at origin
N_EAS = length(EAS_all);
fiber_diams = 4:20; % um
N_diams = length(fiber_diams);
tissue_resistivity = [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal];

% define stimulus: 11 electrodes: 6 anodes, 5 cathodes
stim_start_time = 0.1;
stim_duration   = 20/1000; % 20 us

%TODO: Move this to being a method or property of the class ...
stim_amps = {0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4}; % defined in fig 1d

% define electrode locations: adjacent electrode spacing = 650 um
%Make this a method as well ...
elec_spacing = 650;

electrode_locations = zeros(11,3);
electrode_locations(:,3) = (-5:5)*elec_spacing;
%------------------------------------------------------------------------


% define cell locations
cell_locations = {0 EAS_all 0};

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_locations);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
xstim.elec_objs.setStimPattern(stim_start_time,stim_duration,stim_amps);

thresholds = zeros(N_diams,N_EAS);
% get thresholds
for iDiam = 1:N_diams
    fiber_diameter = fiber_diams(iDiam);
    % change diameter
    cell.props_obj.changeFiberDiameter(fiber_diameter);
    
    % test all EAS
    thresholds(iDiam,:) = xstim.sim__getThresholdsMulipleLocations(cell_locations);
    
end

% normalize thresholds
maxThresholds   = max(thresholds);
norm_thresholds = bsxfun(@rdivide,thresholds,maxThresholds);


% plot
for iEAS = 1:N_EAS
    figure
    plot(fiber_diams,norm_thresholds(:,iEAS),'o','markersize',6)
    xlabel('Axon Diameter [\mum]')
    ylabel('Normalized Activation Threshold')
    title(sprintf('Electrode-to-Axon Spacing = %i \\mum',EAS_all(iEAS)))
    xlim([4 20])
    ylim([0 1.2])
end

end