function slow_AP_initiation
%
%   cell location
%0   450   780
%
%   stimulus -21.88
%
%   Show the significant delay in the kinetics ...


%DEFAULT VARIABLES: We'll change things below ...
in.TISSUE_RESISTIVITY = [1200 1200 200];
in.ELECTRODE_LOCATION = [0 0 200; 0 0 -200]; %Offset two electrodes in z, slight offset in y to prevent zero distance
in.CELL_CENTER        = [0 0 0]; %This is going to change
in.STIM_START_TIME    = 0.2;
in.STIM_START_TIME_2  = 0.2;
in.STIM_DURATIONS     = 0.2;
in.STIM_AMPS          = 1;


%BUILD THE MODEL
%=============================================================================
obj = NEURON.simulation.extracellular_stim;
%obj.n_obj.debug = true;

%tissue ------------------------------------------------
set_Tissue(obj,NEURON.tissue.homogeneous_anisotropic(in.TISSUE_RESISTIVITY));

%stimulation electrode ---------------------------------
e_objs = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
setStimPattern(e_objs(1),in.STIM_START_TIME,in.STIM_DURATIONS,in.STIM_AMPS);
setStimPattern(e_objs(2),in.STIM_START_TIME_2,in.STIM_DURATIONS,in.STIM_AMPS);
set_Electrodes(obj,e_objs);

%cell ---------------------------------------------------
set_CellModel(obj,NEURON.cell.axon.MRG(in.CELL_CENTER))

obj.threshold_cmd_obj.allow_opposite_sign = false;

%TODO: Run this for -1 through -20 ...
%[apFired,extras] = sim__single_stim(obj,scale,