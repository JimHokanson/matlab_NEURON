function addResults(obj,new_stimulus_indices,thresholds)
%
%   addResults(obj,new_stimulus_indices,thresholds)
%
%   INPUTS
%   =======================================================================
%   new_stimulus_indices : observations x [space x time]
%   thresholds           : stimulus thresholds in uA (sort of)
%
%   FULL PATH:
%   

applied_stimuli = obj.new_stimuli_matrix(new_stimulus_indices,:);
xyz_centers     = obj.new_cell_locations(new_stimulus_indices,:);

n_entries = length(thresholds);

%Updating results
%--------------------------------------------------------------
current_index = length(obj.creation_time);
new_indices   = current_index+1:current_index + n_entries;

obj.applied_stimulus_matrix(new_indices,:) = applied_stimuli;
obj.creation_time(new_indices)             = now;
obj.stimulus_setup_id(new_indices)         = obj.current_stimulus_setup_id;
obj.threshold_values(new_indices)          = thresholds;
obj.xyz_center(new_indices,:)              = xyz_centers;

saveToDisk(obj)

end