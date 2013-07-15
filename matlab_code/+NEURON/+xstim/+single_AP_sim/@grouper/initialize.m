function initialize(obj)
%
%
%   This method initializes the groups based on stimulus distance.
%   Eventually we could create methods which iteratively update
%   the groupings based on threshold solutions ...
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.grouper.initialize


s = obj.s;

%NEURON.xstim.single_AP_sim.applied_stimulus_manager.getLowDStimulusInfo
[old_stim,new_stim] = s.stimulus_manager.getLowDStimulusInfo();

if obj.opt__invert_stimulus
   old_stim = 1./old_stim;
   new_stim = 1./new_stim;
end

new_data_obj = s.new_data;

solved_mask = new_data_obj.solution_available;

%We'll need to adjust indices later on ...
input_data = new_stim(~solved_mask,:);

imd = sci.cluster.iterative_max_distance(input_data,...
    'previous_data',old_stim);

obj.imd = imd;

%imd props:
%                    K: 20
%         previous_data: []
%              new_data: [9516x1 double]
%      starting_indices: [651 8958]
%     exhaustive_search: [1x9516 logical]
%           index_order: [1x9516 double]
%          max_distance: [1x9516 double]

%Translate indices back to unsolved indices ...
%TODO: Rewrite function ...
fixed_indices = sl.indices.new_to_old.getOldIndices__oldKeepMask__newIndices(~solved_mask,imd.index_order);


max_distance = imd.max_distance;

%Using this information to form groups
%==========================================================================
%Step 1: How many points to place in each group ...
%-----------------------------------------------
norm_dist_contributions = cumsum(max_distance)./sum(max_distance);

%This could be a method 
%-----------------------------------
n_bins = obj.opt__n_bins;
edges  = linspace(0,1,n_bins+1);
N      = histc(norm_dist_contributions,edges);

r = sl.array.enforce_minimum_counts_by_regrouping(N,obj.opt__min_group_size);

obj.groups_of_indices_to_run = sl.array.toCellArrayByCounts(fixed_indices,r.counts_out);

I1 = find(~solved_mask);
I2 = s.stimulus_manager.applied_stimulus_matcher.unique_new_indices;
I3 = sort(fixed_indices);
assert(isequal(I1,I2),'I1 and I2 not equal');

assert(isequal(I1,I3),'I1 and I3 not equal');

assert(isequal(length(unique([obj.groups_of_indices_to_run{:}])),length(I1)),'Length mismatch')


obj.max_index = length(obj.groups_of_indices_to_run);
obj.cur_index = 0;

obj.initialized = true;


end

% % % % function getDataByCDFBins(data_for_cdf,bins)
% % % % 
% % % % %   NOTE: Ideally this would be a object 
% % % % %Options 
% % % % %- percentiles or specifics bins
% % % % %- minimum group size
% % % % %- 
% % % % 
% % % % end