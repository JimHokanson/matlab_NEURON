function matching_stimuli_obj = getStimuliMatches(obj)
%
%    NOTE: The goal of placing this method in this object is
%    that this class gets to decide what the same is.
%
%   I REALLY REALLY REALLY dislike this code. I'm not sure how to best
%   clean it up ...
%
%    FULL PATH:
%    NEURON.simulation.extracellular_stim.threshold_predictor.getStimuliMatches

%OLD vs OLD
%OLD vs NEW
%NEW vs NEW

m = NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli;

m.n_old = obj.n_old;
m.n_new = obj.n_new;

[~,loc_old_vs_old] = ismember(obj.low_d_old_stimuli,obj.low_d_old_stimuli,'rows');
[~,loc_new_vs_old] = ...
                     ismember(obj.low_d_new_stimuli,obj.low_d_old_stimuli,'rows');
[~,loc_new_vs_new] = ismember(obj.low_d_new_stimuli,obj.low_d_new_stimuli,'rows');

m.old_index_for_redundant_old_source      = loc_old_vs_old;
m.old_index_for_redundant_old_source_mask = find(loc_old_vs_old' ~= 1:length(loc_old_vs_old));

m.old_index_for_redundant_new_source      = loc_new_vs_old;
m.old_index_for_redundant_new_source_mask = loc_new_vs_old ~= 0;

m.new_index_for_redundant_new_source      = loc_new_vs_new;
m.new_index_for_redundant_new_source_mask = find(loc_new_vs_new' ~= 1:length(loc_new_vs_new));




%Following code was wrong, I started to fix it but I think it was way too
%complicated for what speed up it offered ...


% % % % %NOTE: For the sorted stimuli, we check neighbors to see if they are equal
% % % % total_diff_neighbors = sum(abs(diff(obj.all_stimuli_sorted_low_d,1)),2);
% % % % 
% % % % n_entries_total = length(total_diff_neighbors) + 1;
% % % % 
% % % % %Find where there is no difference between neighbors
% % % % %A value of true indicates a pairing between the index & the subsequent
% % % % %index
% % % % mask = [total_diff_neighbors == 0; total_diff_neighbors(end) == 0]';
% % % % 
% % % % pair_mask = total_diff_neighbors == 0;
% % % % 
% % % % duplicate_indices_mask = [pair_mask false] | [false pair_mask];
% % % % 
% % % % m = NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli;
% % % % 
% % % % m.n_old = obj.n_old;
% % % % m.n_new = obj.n_new;
% % % % 
% % % % m.old_is_part_of_duplicate_set = mask(obj.old_stim_index_in_sort);
% % % % m.new_is_part_of_duplicate_set = mask(obj.new_stim_index_in_sort);
% % % % 
% % % % 
% % % % %m.old_is_duplicate = mask(obj.original_index
% % % % 
% % % % 
% % % % [I_Start,I_End] = getStretchesOfLogicalHigh(mask);
% % % % 
% % % % first_duplicate_index = obj.original_index(I_Start);
% % % % first_duplicate_index(first_duplicate_index > obj.n_old) = first_duplicate_index(first_duplicate_index > obj.n_old) - obj.n_old;
% % % % 
% % % % is_from_old_flag      = obj.is_from_old_matrix(I_Start);
% % % % 
% % % % counts = I_End-I_Start + 1;
% % % % 
% % % % 
% % % % 
% % % % %NOTE: We could filter the grabs instead of creating these
% % % % %large arrays ...
% % % % temp_first_duplicate_index_all = zeros(1,n_entries_total);
% % % % temp_is_from_old_flag_all      = false(1,n_entries_total);
% % % % 
% % % % temp_first_duplicate_index_all(mask) = generateArrayByReplicatingCount(counts,first_duplicate_index);
% % % % temp_is_from_old_flag_all(mask)      = generateArrayByReplicatingCount(counts,is_from_old_flag);
% % % % 
% % % % %TODO: Maintain grouping information ...
% % % % %i.e. the I_Start I_End info ...
% % % % 
% % % % m.first_index_of_old_duplicate = temp_first_duplicate_index_all(obj.old_stim_index_in_sort);
% % % % m.first_index_of_new_duplicate = temp_first_duplicate_index_all(obj.new_stim_index_in_sort);
% % % % 
% % % % m.new_duplicate_has_old_source = temp_is_from_old_flag_all(obj.new_stim_index_in_sort);
% % % % 
% % % % 
% % % % m.old_is_duplicate_and_not_ref = m.old_is_part_of_duplicate_set & ....
% % % %     m.first_index_of_old_duplicate ~= 1:m.n_old;
% % % % 
% % % % temp = m.first_index_of_new_duplicate;
% % % % temp(m.new_duplicate_has_old_source) = 0;
% % % % 
% % % % m.new_is_duplicate_and_not_ref = m.new_is_part_of_duplicate_set & temp ~= 1:m.n_new;
% % % % 
% % % % matching_stimuli_obj = m;

end