function reproduceCurrentDistanceRelationships()

%NOTE: I would like to add on an option to test this against
%previously run data to see if it matches ...

m = local_neural_models.Dennis_2011;

fiber_diameters = [7.3 10];
nFibers         = length(fiber_diameters);
[~,steps]       = m.getCurrentDistanceCurve([],'get_default_steps',true);
nSteps          = length(steps);
t_all           = zeros(nSteps,nFibers);

for iSize = 1:nFibers
    cur_fiber_size = fiber_diameters(iSize);
    t_all(:,iSize) = m.getCurrentDistanceCurve(cur_fiber_size);
end

%NOW: need to flip everything to current vs distance

stim_plot_levels = 1:100;
new_distances    = zeros(100,nFibers);

%NOTE: This could all be a method of the current-distance curves ...


for iSize = 1:nFibers
   x_old_stim = t_all(:,iSize)';
   new_distances(:,iSize) = interp1(x_old_stim,steps,stim_plot_levels,'pchip');
end

figure(1)
plot(stim_plot_levels,new_distances)




end

function helper__run_current_distance_curve


%JAH STATUS: Unfinished, should probably move back into local NEURON models
%This class should really just be about reproducing results ...


%NEURON SIMULATION CODE
%===================================================================================
in.TISSUE_RESISTIVITY   = 500;
in.distance_steps       = [10 20:20:200 250:50:1200]; 
in.starting_value       = 1;
in.dim                  = 1;
in.ELECTRODE_LOCATION   = [0 0 0];
in.CELL_CENTER          = [0 0 0];
in.STIM_START_TIME      = 0.1;
in.STIM_DURATION        = [0.2 0.4];
in.STIM_SCALE           = [-1 0.5];

obj = NEURON.simulation.extracellular_stim;
obj.threshold_cmd_obj.use_max_threshold = false;
set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.TISSUE_RESISTIVITY));

%Electrode handling
e_obj = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
setStimPattern(e_obj,in.STIM_START_TIME,in.STIM_DURATION,in.STIM_SCALE);
set_Electrodes(obj,e_obj);

%Cell handling
cell = NEURON.cell.axon.MRG(in.CELL_CENTER);
cell.props_obj.fiber_diameter = fiber_diameter;
set_CellModel(obj,cell)

%Was toggling this ...
obj.n_obj.debug = false;

%method   NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
t_all = sim__getCurrentDistanceCurve(obj,in.distance_steps,in.dim,in.starting_value);

end