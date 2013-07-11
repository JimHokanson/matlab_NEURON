function initialize(obj)
%
%
%   IMPROVEMENTS:
%   =======================================================================
%   1) Provide option if we have too few new points to just solve
%   everything all at once ...
%   2) 
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.grouper.initialize


%Question, how to expand 

%Step 1 - organize data
%--------------------------------------------------------------------------
%old_data %old data and new data - run unique ??????

p = obj.p;
old_stim = p.old_stimuli.low_d_stimulus;
new_stim = p.new_stimuli.low_d_stimulus;

new_data_obj = p.new_data;

%ASSUMPTION: For now let's assume any solved new stimuli are
%redundant

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
N = histc(norm_dist_contributions,edges);

r = sl.array.enforce_minimum_counts_by_regrouping(N,obj.opt__min_group_size);

obj.groups_of_indices_to_run = sl.array.grabDataByCounts(fixed_indices,r.counts_out);

obj.max_index = length(obj.groups_of_indices_to_run);
obj.cur_index = 0;

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