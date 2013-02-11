function matching_stimuli_obj = getStimuliMatches(obj)
%
%    NOTE: The goal of placing this method in this object is
%    that this class gets to decide what the same is.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Change ismember to using unique (low priority)
%
%   See Also:
%       NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli
%
%    FULL PATH:
%    NEURON.simulation.extracellular_stim.threshold_predictor.getStimuliMatches

%OLD vs OLD
%OLD vs NEW
%NEW vs NEW

m = NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli;

m.n_old = obj.n_old;
m.n_new = obj.n_new;

%NOTE: Some of these might be better off as unique statements ...
[~,loc_old_vs_old] = ismember(obj.low_d_old_stimuli,obj.low_d_old_stimuli,'rows');

if ~isempty(obj.low_d_old_stimuli)
[~,loc_new_vs_old] = ismember(obj.low_d_new_stimuli,obj.low_d_old_stimuli,'rows');
else
   loc_new_vs_old = zeros(obj.n_new,1); 
end

[~,loc_new_vs_new] = ismember(obj.low_d_new_stimuli,obj.low_d_new_stimuli,'rows');


m.old_index_for_redundant_old_source       = loc_old_vs_old;
m.old_index_for_redundant_old_source__mask = loc_old_vs_old ~= (1:length(loc_old_vs_old))';

m.old_index_for_redundant_new_source       = loc_new_vs_old;
m.old_index_for_redundant_new_source__mask = (loc_new_vs_old ~= 0);

m.new_index_for_redundant_new_source       = loc_new_vs_new;
m.new_index_for_redundant_new_source__mask = loc_new_vs_new ~= (1:length(loc_new_vs_new))';

matching_stimuli_obj = m;

end