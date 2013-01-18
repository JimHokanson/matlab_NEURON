function saveToDisk(obj) 
%
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim_logger.data.deleteEntries
%   
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.sim_logger.data.saveToDisk

%MLINT
%-------------
%#ok<*NASGU> not used in file is ok (save function not recognized)
%JAH 1/16/2013 - submitted enhancement request to fix this ...


%Saving to disk
%--------------------------------------------------------------
n_points_per_cell       = obj.n_points_per_cell;   

applied_stimulus_matrix = obj.applied_stimulus_matrix;
threshold_values        = obj.threshold_values;
xyz_center              = obj.xyz_center;

creation_time           = obj.creation_time;

stimulus_setup_id       = obj.stimulus_setup_id;
stimulus_setup_objs     = obj.stimulus_setup_objs;

VERSION = obj.VERSION;

save(obj.data_path,...
    'VERSION',...
    'n_points_per_cell',...
    'applied_stimulus_matrix',...
    'threshold_values',...
    'xyz_center',...
    'creation_time',...
    'stimulus_setup_id',...
    'stimulus_setup_objs')

end