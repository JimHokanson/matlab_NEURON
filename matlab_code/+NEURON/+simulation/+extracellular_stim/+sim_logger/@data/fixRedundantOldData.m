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

%Dimensionality Reduction: Do I want to do this???
%--------------------------------------------------------------------------
predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor(...
                    [],obj.applied_stimulus_matrix);

[~,old_low_dimension] = predictor_obj.rereduceDimensions(...
                                            [],obj.applied_stimulus_matrix);
           
[unique_old_stim,~,index_in_unique_old_stim] = unique(old_low_dimension,'rows');

n_unique      = size(unique_old_stim,1);
n_old_entries = size(old_low_dimension,1);   
%Redundant Stimuli Handling ...
%-----------------------------------------------------
if n_unique ~= n_old_entries
    
    indices_delete_mask       = false(1,n_old_entries);
    new_threshold_mask        = false(1,n_old_entries);
    new_threshold_values      = NaN(1,n_old_entries);
    
    
    [~,IC] = unique2(index_in_unique_old_stim);
    %IC: 
    
    redundant_groups = find(cellfun('length',IC) > 1);
    
    for iGroup = 1:length(redundant_groups)
       cur_IC_index      = redundant_groups(iGroup);
       cur_group_indices = IC{cur_IC_index};
       thresholds_local  = obj.threshold_values(cur_group_indices);
       if any(isnan(thresholds_local))
           error('Case not yet handled')
       end
       threshold_new = mean(thresholds_local);
       if any(abs(thresholds_local - threshold_new) > MAX_THRESHOLD_DIFFERENCE)
           error('Max threshold difference for same stimulus violated, code not yet handled')
       end
       new_threshold_mask(cur_group_indices(1))      = true;
       new_threshold_values(cur_group_indices(1))    = threshold_new;
       indices_delete_mask(cur_group_indices(2:end)) = true; 
    end    
    
    %Updating thresholds
    obj.threshold_values(new_threshold_mask) = new_threshold_values(new_threshold_mask);
    
    %Removal of redundant entries and saving ...
    obj.deleteEntries(indices_delete_mask);

end

if any(isnan(obj.threshold_values))
    error('Case not yet handled')
end



