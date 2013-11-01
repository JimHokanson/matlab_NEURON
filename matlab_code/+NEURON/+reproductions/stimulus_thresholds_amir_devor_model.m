function stimulus_thresholds_amir_devor_model()

clear_classes

in.TISSUE_RESISTIVITY = [1211 1211 175];
in.ELECTRODE_LOCATION = [0 0 0];
in.CELL_CENTER        = [0 0 0]; %This is going to change
in.STIM_START_TIME    = 0.2;
in.STIM_START_TIME_2  = 0.2;
in.STIM_DURATIONS     = 0.2;
in.STIM_AMPS          = 1;
in.MAX_TIME_AFTER_EVENT = 4; %Need to go a bit longer for slow AP initiation
in.MAX_STIM_AMP       = 100;


XYZ   = {0:10:500 10 0:10:780};

options = {...
    'electrode_locations',in.ELECTRODE_LOCATION,...
    'tissue_resistivity',in.TISSUE_RESISTIVITY,...
    'cell_type','drg_ad'};
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});




r = xstim.sim__getThresholdsMulipleLocations(XYZ,...
    'merge_solvers',C.merge_solvers,'use_new_solver',C.use_new_solver);



x_bounds = [0 500];
y_bounds = [0 500];
z_bounds = [0 780];

obj = NEURON.simulation.extracellular_stim;
obj.n_obj.debug = false;
obj.opt__TIME_AFTER_LAST_EVENT = in.MAX_TIME_AFTER_EVENT;


%tissue ------------------------------------------------
set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.TISSUE_RESISTIVITY));

%stimulation electrode ---------------------------------
e_objs = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
setStimPattern(e_objs(1),in.STIM_START_TIME,in.STIM_DURATIONS,in.STIM_AMPS);
if length(e_objs) > 1
    setStimPattern(e_objs(2),in.STIM_START_TIME_2,in.STIM_DURATIONS,in.STIM_AMPS);
end
set_Electrodes(obj,e_objs);

%cell ---------------------------------------------------
set_CellModel(obj,NEURON.cell.DRG_AD(in.CELL_CENTER))

obj.threshold_cmd_obj.allow_opposite_sign = false;
obj.threshold_cmd_obj.max_threshold = in.MAX_STIM_AMP;


%Let's do a simple loop through z & x

z_all = -1000:100:1000;
x_all = 50:50:1000;
nZ = length(z_all);
nX = length(z_all);

obj.sim__determine_threshold(-5)
[apFired,extras] = obj.sim__single_stim(-2,'save_data',true);
mesh(extras.vm)