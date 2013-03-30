function figure6(obj,varargin)
%
%   Figure 6 examines stimulation thresholds for a myelinated axon using
%   the FH model. It actually tests two different diameters fibers, 2.4 um
%   and 9.6 um. Technically these are the axon diameters even though Rattay
%   refers to them as fiber diameters
%



in.debug = false;
in = processVarargin(in,varargin);

TISSUE_RESISTIVITY = obj.tissue_resistivity; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATIONS      = 0.1;   % 100us duration, square pulse
STIM_AMP = 1;
props_paper = obj.props_paper;

%Props that differ from defaults ...
TEMP_CELSIUS = obj.temp_celsius;

tested_z = 0:100:500;
tested_x = [0:100:500 1000 2000];

xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic');

xstim_obj.cmd_obj.options.debug = in.debug;
xstim_obj.props_obj.changeProps('celsius',TEMP_CELSIUS);
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,STIM_DURATIONS,STIM_AMP);
xstim_obj.cell_obj.props_obj.setPropsByPaper(props_paper);

thresholds = xstim_obj.sim__getThresholdsMulipleLocations({tested_x 0 tested_z},'threshold_sign',-1);
%anodeThresholds = xstim_obj.sim__getThresholdsMulipleLocations({tested_x 0 tested_z});
obj.fig6_thresholds = squeeze(thresholds);

end