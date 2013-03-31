function stimRatios(obj,varargin)
% get ratios of cathodal to anodal stim amplitudes needed to activate myelinated axon
% over a range of distances

in.debug = false;
in = processVarargin(in,varargin);

TISSUE_RESISTIVITY = obj.tissue_resistivity; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATIONS      = 0.1;   % 100us duration, square pulse
STIM_AMP = 1;
props_paper = obj.props_paper;

%Props that differ from defaults ...
TEMP_CELSIUS = obj.temp_celsius;

minDist = 0.01*1000;
maxDist = 5*1000;
N_distances = 50;
distances = linspace(minDist,maxDist,N_distances);

xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic');
xstim_obj.cmd_obj.options.debug = in.debug;
xstim_obj.props.changeProps('celsius',TEMP_CELSIUS);
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,STIM_DURATIONS,STIM_AMP);
xstim_obj.cell_obj.props_obj.setPropsByPaper(props_paper);

catThresholds = -1*xstim_obj.sim__getThresholdsMulipleLocations({0 distances 0},'threshold_sign',-1);
anodeThresholds = xstim_obj.sim__getThresholdsMulipleLocations({0 distances 0},'threshold_sign',1);
ratios = catThresholds./anodeThresholds;

figure
plot(distances./1000,ratios)
xlabel('Electrode Distance (mm)')
ylabel('Stim Amp Ratio (-Stim/+Stim)')
ylim([0 1])

obj.myelinated_stim_ratios = ratios;

end