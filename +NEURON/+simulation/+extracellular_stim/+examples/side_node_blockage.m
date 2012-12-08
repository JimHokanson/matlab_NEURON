function side_node_blockage
%
%   Generate plot to show results ...
%
%   JAH TODO: Unfinished, run at stim amps shown below
%   Should show strong activation with strong side inhibition
%   in which an AP fails to propogate ...
%
%   NEURON.simulation.extracellular_stim.examples.side_node_blockage

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
obj.n_obj.debug = false;

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
stim_levels = 1:20;
nStim = length(stim_levels);
all_stim  = cell(1,nStim);
all_fired = zeros(1,nStim);
for iStim = 1:nStim
    [all_fired(iStim),extras] = sim__single_stim(obj,-1*stim_levels(iStim),...
        'save_data',true,'complicated_analysis',true);
    all_stim{iStim} = extras.vm;
end
formattedWarning('Still need to plot results ...,click on link')
keyboard