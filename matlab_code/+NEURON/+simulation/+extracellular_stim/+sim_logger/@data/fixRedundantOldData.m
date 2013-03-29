function fixRedundantOldData(obj)
%
%   fixRedundantOldData(obj)
%
%   NOTE: This function currently relies on dimensionality reduction
%   which if given the wrong value could really wipe out our data. The
%   dimensionality reduction is only in place currently to speed up the
%   unique rows .... I might change this to be an exact match. Things will
%   be a bit slower but it guarantees no loss of data.
%
%   NOTE: We do have a check that doesn't allow these reductions to occur
%   if the observed thresholds between this stimuli differ by a substantial
%   amount.
%   
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
%
%   CODE STATUS:
%   Done, but not so clean. See note above on how old stimuli are compared
%   ...
%   

%At some point my code got buggered with redundant old stimuli :/ so I
%wrote this function to fix that problem


%NOTE: This might need to change
MAX_THRESHOLD_DIFFERENCE = 0.1;


%TODO: We should tie this back into the methods of the class ...

obj.predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor(...
                        obj.new_stimuli_matrix,...
                        obj.applied_stimulus_matrix,...
                        obj.xyz_center,....
                        obj.new_cell_locations,...
                        obj.threshold_values);

%NEURON.simulation.extracellular_stim.threshold_predictor.getStimuliMatches
%NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli
m = obj.predictor_obj.getStimuliMatches();

r_groups = m.getRedundantOldGroups();

%Redundant Stimuli Handling ...
%-----------------------------------------------------
if ~isempty(r_groups)
    
    n_duplicate_groups = length(r_groups);
    
    new_threshold_values = zeros(1,n_duplicate_groups);
    first_indices_keep   = zeros(1,n_duplicate_groups);
    other_indices_remove = cell(1,n_duplicate_groups);
    
    for iGroup = 1:n_duplicate_groups
       cur_group_indices = r_groups{iGroup};
       
       first_indices_keep(iGroup)     = cur_group_indices(1);
       other_indices_remove{iGroup} = cur_group_indices(2:end);
       
       thresholds_local  = obj.threshold_values(cur_group_indices);
       if any(isnan(thresholds_local))
           error('Case not yet handled')
       end
       
       new_threshold_values(iGroup) = mean(thresholds_local);
       if any(abs(thresholds_local -  new_threshold_values(iGroup)) > MAX_THRESHOLD_DIFFERENCE)
           error('Max threshold difference for same stimulus violated, code not yet handled')
       end
    end
    
    obj.threshold_values(first_indices_keep) = new_threshold_values;
    
    obj.deleteEntries(vertcat(other_indices_remove{:}));

end

if any(isnan(obj.threshold_values))
    error('Case not yet handled')
end



