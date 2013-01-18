function addResults(obj,applied_stimuli,thresholds,xyz_centers)
%
%   addResults(obj,applied_stimuli,thresholds)
%
%   INPUTS
%   =======================================================================
%   applied_stimuli : observations x [space x time]
%   thresholds      : stimulus thresholds in uA (sort of)
%
%   FULL PATH:
%   

n_entries = length(thresholds);

%Updating results
%--------------------------------------------------------------
new_indices = obj.current_index+1:obj.current_index + n_entries;

obj.applied_stimulus_matrix(new_indices,:) = applied_stimuli;
obj.creation_time(new_indices)             = now;
obj.stimulus_setup_id(new_indices)         = obj.current_stimulus_setup_id;
obj.threshold_values(new_indices)          = thresholds;
obj.xyz_center(new_indices,:)              = xyz_centers;

saveToDisk(obj)

end