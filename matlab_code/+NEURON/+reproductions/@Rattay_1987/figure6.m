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
STIM_SCALES = 1;
props_paper = obj.props_paper;

%Props that differ from defaults ...
TEMP_CELSIUS = obj.temp_celsius;

tested_z = 0:100:500;
tested_x = [0:100:500 1000 2000];

xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic',...
    'cell_options',{'paper',props_paper},...
    'stim_scales',STIM_SCALES,...
    'stim_durations',STIM_DURATIONS,...
    'stim_start_times',STIM_START_TIME,...
    'debug',in.debug,...
    'celsius',TEMP_CELSIUS);

thresholds = xstim_obj.sim__getThresholdsMulipleLocations({tested_x 0 tested_z},'threshold_sign',-1);
%anodeThresholds = xstim_obj.sim__getThresholdsMulipleLocations({tested_x 0 tested_z});
obj.fig6_thresholds = reshape(thresholds,[length(tested_x) length(tested_z)]);

end