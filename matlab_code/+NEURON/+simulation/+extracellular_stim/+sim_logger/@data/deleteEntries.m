function deleteEntries(obj,indices_or_mask_delete)
%deleteEntries
%
%   This method was written to handle deletion of entries that are deemed
%   to be redundant.
%
%   deleteEntries(obj,indices_or_mask_delete)
%
%   INPUTS
%   ========================================================
%   indices_or_mask_delete : indices or logical array of entries that
%   should be deleted
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim_logger.data.saveToDisk
%       NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.sim_logger.data.deleteEntries
%
%
%   IMPROVEMENT
%   ======================================
%   1) LOW PRIORITY
%      Could eventually remove stimulus setup ids if all stimuli
%from one setup are no longer present
%i.e. something along the lines of ...
%
%   unique(obj.stimulus_setup_id)
%   Remove stimulus_setup_objs
%
%   NOTE: This would require renumbering stimulus setup ids to 
%   account for the shift ...


obj.applied_stimulus_matrix(indices_or_mask_delete,:) = [];
obj.threshold_values(indices_or_mask_delete) = [];
obj.xyz_center(indices_or_mask_delete,:) = [];
obj.creation_time(indices_or_mask_delete) = [];
obj.stimulus_setup_id(indices_or_mask_delete) = [];

obj.saveToDisk();

end