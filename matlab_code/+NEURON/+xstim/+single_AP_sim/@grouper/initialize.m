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

n_points = size(old_stim,1) + size(new_stim,1);


% % % %This shouldn't be done here
% % % if obj.opt__invert_stimulus
% % %    old_stim = 1./old_stim;
% % %    new_stim = 1./new_stim;
% % % end

new_data_obj = s.new_data;

solved_mask = new_data_obj.solution_available;

if n_points > obj.opt__max_non_rand_size
    fixed_indices = NEURON.sl.array.shuffle(find(~solved_mask)); %#ok<FNDSB>
    
    %Method, not sure what to call it 
    %We basically grab in equal sized bins except for the last bin
    n_bins = obj.opt__n_bins;
    start_indices = round(linspace(1,length(fixed_indices),n_bins+1));
    end_indices   = start_indices(2:end)-1;
    end_indices(end) = length(fixed_indices);
    start_indices(end) = [];
    
    N = end_indices - start_indices + 1;
else
    
    
    %We'll need to adjust indices later on ...
    input_data = new_stim(~solved_mask,:);
    
    imd = NEURON.sci.cluster.iterative_max_distance(input_data,...
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
    fixed_indices = NEURON.sl.array.indices.new_to_old.getOldIndices__oldKeepMask__newIndices(~solved_mask,imd.index_order);
    
    %Using this information to form groups
    %======================================================================
    %Step 1: How many points to place in each group ...
    %-----------------------------------------------
    
    %Interesting, cumsum can exceed sum by just a bit ...
    %Found comment on this for r:
    %http://r.789695.n4.nabble.com/cumsum-vs-sum-td876349.html
    %I found this in my data as well which caused problems
    %This could be a method, normalize ...
    %
    %   Many different normalization procedures ...
    %
    % norm_dist_contributions = cumsum(max_distance)./sum(max_distance);
    
    max_distance = imd.max_distance;
    norm_dist_contributions = cumsum(max_distance);
    norm_dist_contributions = norm_dist_contributions./norm_dist_contributions(end);
    
    %This could be a method
    %----------------------------------------------------------------------
    n_bins = obj.opt__n_bins;
    edges  = linspace(0,1,n_bins+1);
    N      = histc(norm_dist_contributions,edges);
end

r = NEURON.sl.array.enforce_minimum_counts_by_regrouping(N,obj.opt__min_group_size);

obj.groups_of_indices_to_run = NEURON.sl.array.toCellArrayByCounts(fixed_indices,r.counts_out);


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