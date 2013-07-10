function getStimulusMatches(obj)
%
%   getStimulusMatches(obj)
%
%   This method should examine the old and new applied stimuli and
%   determine if any of the new stimuli are same as old stimuli, and thus
%   we can use the solution from the old location, or if any of the new
%   stimuli are redundant, and thus once we learn one of the redundant
%   points, we can apply that solution to all redundant points in the set.
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

%NOTE: We concatenate old first, then new.
%
%This is important below when we determine if a point
%came from the old or new data
u = sl.array.unique_rows([old_stim; new_stim]);

is_new_mask = true(1,n_total);
is_new_mask(1:n_old) = false;

ref_I = u.o_first_group_I; %Index of the first unique value with the same
%value as the given index
%
%i.e. for values 3 6 3 7 6
%ref_I =>        1 2 1 4 2  <= The 3 & 6 are repeats
%indices         1 2 3 4 5

is_redundant   = ref_I ~= 1:length(ref_I); %The first unique entry will
%have a value equal to its index
has_old_source = ref_I <= n_old; 

new_and_old_source = is_new_mask & has_old_source;
new_and_new_source = is_new_mask & is_redundant & ~has_old_source;

%If any of our old points have the same applied stimulus as an "old" point
%then we apply the solution that the old point used.
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

end