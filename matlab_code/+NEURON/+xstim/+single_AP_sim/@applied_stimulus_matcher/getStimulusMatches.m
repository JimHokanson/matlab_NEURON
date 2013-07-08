function getStimulusMatches(obj)
%
%
%   getStimulusMatches(obj)
%
%
%   See Also:
%   NEURON.xstim.single_AP_sim.predictor.setSameAsOld
%   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.applyStimulusMatches
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.getStimulusMatches


p = obj.p;

old_stim = p.old_stimuli.low_d_stimulus;
new_stim = p.new_stimuli.low_d_stimulus;
n_old    = size(old_stim,1);
n_new    = size(new_stim,1);
n_total  = n_old + n_new;

%NOTE: We concatenate old then new, we use this below for the mask:
%has_old_source
u = sl.array.unique_rows([old_stim; new_stim]);

is_new_mask = true(1,n_total);
is_new_mask(1:n_old) = false;

ref_I = u.o_first_group_I;

is_redundant   = ref_I ~= 1:length(ref_I); %The first unique entry will
%have a value equal to its index
has_old_source = ref_I <= n_old; 

new_and_old_source = is_new_mask & has_old_source;
new_and_new_source = is_new_mask & is_redundant & ~has_old_source;


if any(new_and_old_source)
    new_indices = find(new_and_old_source) - n_old;
    p.setSameAsOld(new_indices,ref_I(new_and_old_source));
end

if any(new_and_new_source)
   new_indices        = find(new_and_new_source)  - n_old;
   new_source_indices = ref_I(new_and_new_source) - n_old;
   
   %Save properties locally, register callback ...
   obj.redundant_indices = new_indices;
   obj.source_indices    = new_source_indices;
   
   new_solution = p.new_data;
   new_solution.addWillSolveLaterIndices(new_indices,@obj.applyStimulusMatches);
end






%Info out
%--------------------------------------------------------------------------
%redundant_source -
%   0 - original
%   1 - old source
%   2 - new source
%location
%   - index into 



%Old code :/

% % % % % % %%OLD vs OLD
% % % % % % %OLD vs NEW
% % % % % % %NEW vs NEW
% % % % % % %==========================================================================
% % % % % % m = NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli;
% % % % % % 
% % % % % % m.n_old = obj.n_old;
% % % % % % m.n_new = obj.n_new;
% % % % % % 
% % % % % % %NOTE: Some of these might be better off as unique statements ...
% % % % % % [~,loc_old_vs_old] = ismember(obj.low_d_old_stimuli,obj.low_d_old_stimuli,'rows');
% % % % % % 
% % % % % % if ~isempty(obj.low_d_old_stimuli)
% % % % % % [~,loc_new_vs_old] = ismember(obj.low_d_new_stimuli,obj.low_d_old_stimuli,'rows');
% % % % % % else
% % % % % %    loc_new_vs_old = zeros(obj.n_new,1); 
% % % % % % end
% % % % % % 
% % % % % % [~,loc_new_vs_new] = ismember(obj.low_d_new_stimuli,obj.low_d_new_stimuli,'rows');
% % % % % % 
% % % % % % 
% % % % % % m.old_index_for_redundant_old_source       = loc_old_vs_old;
% % % % % % m.old_index_for_redundant_old_source__mask = loc_old_vs_old ~= (1:length(loc_old_vs_old))';
% % % % % % 
% % % % % % m.old_index_for_redundant_new_source       = loc_new_vs_old;
% % % % % % m.old_index_for_redundant_new_source__mask = (loc_new_vs_old ~= 0);
% % % % % % 
% % % % % % m.new_index_for_redundant_new_source       = loc_new_vs_new;
% % % % % % m.new_index_for_redundant_new_source__mask = loc_new_vs_new ~= (1:length(loc_new_vs_new))';
% % % % % % 
% % % % % % matching_stimuli_obj = m;


end