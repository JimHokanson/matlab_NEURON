function groups_of_indices_to_run = getGroups(obj,old_indices_use,new_indices_use)
%
%
%   groups_of_indices_to_run = getGroups(obj,new_indices_use,old_indices_use)
%
%   TODO: Move most of this documentation to a separate document on the
%   topic ..
%
%   OUTPUTS
%   =======================================================================
%   groups_of_indices_to_run : (cell array of arrays) values in the arrays
%   are the indices of the passed in data to test together before running
%   another prediction algorithm
%
%   GOAL
%   =======================================================================
%   The goal is to specify testing order for groups of stimuli. The goal is
%   to start by testing points, that once we know their threshold, we will
%   be able to more accurately predict their neighbors. 
%
%   ALGORITHM
%   =======================================================================
%   I had originally started with an algorithm that tried to choose points
%   so that for the chosen point, it would make it so that all unknown
%   points as close as possible to it or previously chosen points. A bad
%   choice for a point would not reduce the overall distance between known
%   and unknown points. While explaining this to Lee he suggested that what
%   it sounded like I wanted was to choose points which were furthest from
%   other points. Although this is a slightly different formalism and not
%   necessarily as suited for the goal (a single far away point does little
%   to help prediction of a cluster of unknowns that are all close to each
%   other and not much else), the implementation is much easier.
%
%
%   IMPLEMENTATION NOTES:
%   =======================================================================
%   1) We currently don't use threshold or location information but we
%   might do this eventually. It is not critical that this method be
%   constant as it only serves to help create data. The output from this
%   method is not the output we save.
%   2) The input data is currently not reduced to provide efficient
%   searching. This isn't a huge concern at this point but it might
%   eventualy be desireable to downsample the old stimuli before running
%   the main algorithm.
%   3) This algorithm relies on differences (literally distance) between applied stimuli.
%   It attempts to sample the stimuli in an efficient way so as to minimize
%   the distance from any untested point to a given tested point. Ideally
%   this distance metric would be threshold based, but this is not possible
%   without more information. A multi-pass approach could be used to just
%   differences in threshold, but this would require a bit more work on the
%   implementation side.
%   4) The first group is chosen to span the entirety of reduced dimension
%   data. The following groups are chosen to represent certain fractions of
%   distance (TODO: Could describe this more)
%
%   YET TO IMPLEMENT
%   =======================================================================
%   1) If the testing space is sufficiently small, just test everything in
%   a single group.
%   2) Expose hardcoded constants as options for class.
%   3) Perhaps populate some results of this back into class:
%       - coefficients of pca
%       - anything else????
%
%   See Also:
%      NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds 

%Transform to make data bit more linear in threshold distance ...
%Delay until later if at all ...
%---------------------------------------------------------------------
% % % applied_stimuli = 1./applied_stimuli; %Two looked bad, going back to 1
% % % %NOTE: 2 might have been bad due to not carrying the sign when squaring
% % % old_stimuli     = 1./old_stimuli;


%NOTE: This method does not use thresholds or cell locations
%in its calculations. If used these would need to be offset
%by the indices passed in ...


old_stimuli     = obj.low_d_old_stimuli(old_indices_use,:);
applied_stimuli = obj.low_d_new_stimuli(new_indices_use,:);
n_new_stimuli   = size(applied_stimuli,1);

if n_new_stimuli < 20
    groups_of_indices_to_run = {new_indices_use};
    return
end

%First grouping stratgey
%I think instead of doing the min and max we should do a convex hull
%strategy
%Sadly the convex hull had way more points than I anticipated
%However, we could use this to test the prediction model
%and whether or not we need to use a different algorithm
%- see convhulln
%--------------------------------------------------------------------------
[~,I_min] = min(applied_stimuli);
[~,I_max] = max(applied_stimuli);

first_group = unique([I_min I_max]);

n_first_group = length(first_group);

chosen_stimuli = applied_stimuli(first_group,:);
%--------------------------------------------------------------------------


%NOTE: If K is greather than length, no error occurs which is fine
[idx_nn,dist_nn] = knnsearch(applied_stimuli,applied_stimuli,'K',50);

dist_nn = dist_nn'; %

%Initialization of distance metrics and loop variables
%--------------------------------------------------------------------------
if isempty(old_stimuli)
    [~,smallest_distance_to_known_point] = knnsearch(chosen_stimuli,applied_stimuli);
else
    [~,smallest_distance_to_known_point] = knnsearch([chosen_stimuli; old_stimuli],applied_stimuli);
end


%Main algorithm
%--------------------------------------------------------------------------
chosen_points    = zeros(1,n_new_stimuli);
max_dist_removed = zeros(1,n_new_stimuli);

not_chosen_mask              = true(1,n_new_stimuli);
not_chosen_mask(first_group) = false;

for iPoint = n_first_group+1:n_new_stimuli
    
   %SLOW LINE
   [maxValue,I] = max(smallest_distance_to_known_point); %Get point furthest from all old points
   if maxValue == 0 
      error('Repetitions present, prior code should have removed repetitions')
   end
   
   chosen_points(iPoint) = I;
   
   %INSIGHT
   %-----------------------------------------------------------------------
   %Let's say we get a maxValue of 1 for this point
   %meaning this point is the farthest distance of any unknown point
   %to some known point.
   %Let's say the closest 3 points are 0.2 1 and 2 away
   %knowledge of this point can only improve the first two samples, as the
   %third one must already have a closer point, otherwise it would 
   %be the max value. This means instead of taking the min
   %over all unknown points, we only take the min over the first set
   %of points, which leads to less comparisons.
   
   I_update = find(dist_nn(:,I) > maxValue,1);
   
   if isempty(I_update)
       %This means our knnsearch was too small, compute all ...
       
   %The smallest distance from all unknown points to known points
   %is now the minimum of either previous minimum distances, or the
   %distance from these points to the chosen point (which is know
   %considered to be a known point)
   
   %SLOW LINE :/
   %Increasting K in nn decreases these calls
   %but it also increases nn search time
   smallest_distance_to_known_point(not_chosen_mask) = ...
       min(smallest_distance_to_known_point(not_chosen_mask),pdist2(applied_stimuli(not_chosen_mask,:),applied_stimuli(I,:)));
   else 
      indices = idx_nn(I,1:I_update-1);      
      smallest_distance_to_known_point(indices) = ...
            min(smallest_distance_to_known_point(indices),dist_nn(1:I_update-1,I));        
   end
   
   not_chosen_mask(I)       = false;
   max_dist_removed(iPoint) = maxValue;
end

%Using this information to form groups
%==========================================================================
%Step 1: How many points to place in each group ...
%-----------------------------------------------
normalized_contributions = cumsum(max_dist_removed)./sum(max_dist_removed);

%NOTE: We remove the normalized contributions from those enries
%that make up the first group, so that sum(N) = total_points - n_first_group
N = histc(normalized_contributions(n_first_group+1:end),0:obj.opt__TESTING_PERCENTAGE_SPACING:1+obj.opt__TESTING_PERCENTAGE_SPACING);

non_empty_groups   = find(N ~= 0);
n_non_empty_groups = length(non_empty_groups);

%Step 2: Assignment of groups based on # to place in each group
%-----------------------------------------------
n_groups_total     = n_non_empty_groups+1;

all_groups    = cell(1,n_groups_total);
all_groups{1} = new_indices_use(first_group);

last_used_index  = n_first_group;
for iGroup = 1:n_non_empty_groups
    cur_group_N = N(non_empty_groups(iGroup));
    
    %NOTE: offset by 1 is to account for first_group set
    %NOTE: We reindex back into the indices passed into the function
    all_groups{iGroup+1} = new_indices_use(chosen_points(last_used_index+1:last_used_index+cur_group_N));
    last_used_index      = last_used_index + cur_group_N;
end

groups_of_indices_to_run = all_groups;

%DEBUGGING
%------------------------------------------------
% % % %Some plot testing
% % % row = zeros(1,n_new_stimuli);
% % % c = cell_locations;
% % % for iGroup = 2:n_groups_total
% % %    row(all_groups{iGroup}) = iGroup; 
% % %    i_use = find(row ~= 0);
% % %    scatter3(score(i_use,1),score(i_use,2),score(i_use,3),100,row(i_use),'filled');
% % %    %axis equal
% % %    view(0,90)
% % %    title(sprintf('Run %d',iGroup))
% % %    pause
% % % end
% % % 


end
