%testing 4

%NOTE: Copied some stuff from default run
%might have caused problems
%Might be bug in code
%Rerun with steps of 5 ...

tic
DISTANCE_STEPS = 50:50:500;
DIM = 2;
STARTING_VALUE = -4;

in.TISSUE_RESISTIVITY = [1200 300 300];
in.ELECTRODE_LOCATION = [0 0 0];
in.CELL_CENTER        = [0 50 0];
in.STIM_START_TIME    = 0.2;
in.STIM_DURATIONS     = [0.2 0.4];
in.STIM_AMPS          = [1 -0.5];

obj = NEURON.simulation.extracellular_stim;
%obj.n_obj.debug = false;

%tissue ------------------------------------------------
set_Tissue(obj,NEURON.tissue.homogeneous_anisotropic(in.TISSUE_RESISTIVITY));

%stimulation electrode ---------------------------------
e_obj = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
setStimPattern(e_obj,in.STIM_START_TIME,in.STIM_DURATIONS,in.STIM_AMPS);
set_Electrodes(obj,e_obj);

%cell ---------------------------------------------------
set_CellModel(obj,NEURON.cell.axon.MRG(in.CELL_CENTER))

t_all = sim__getCurrentDistanceCurve(obj,DISTANCE_STEPS,DIM,STARTING_VALUE);

toc