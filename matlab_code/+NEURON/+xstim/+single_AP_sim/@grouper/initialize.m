function initialize(obj)

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


imd = iterative_max_distance(input_data,...
    'previous_data',old_stim);

keyboard

%Translate indices back to unsolved indices ...






% % % % % % obj.initialized = true;
% % % % % % 
% % % % % % old_stimuli     = obj.low_d_old_stimuli(old_indices_use,:);
% % % % % % applied_stimuli = obj.low_d_new_stimuli(new_indices_use,:);
% % % % % % n_new_stimuli   = size(applied_stimuli,1);
% % % % % % 
% % % % % % if n_new_stimuli < 20
% % % % % %     groups_of_indices_to_run = {new_indices_use};
% % % % % %     return
% % % % % % end
% % % % % % 
% % % % % % %First grouping stratgey
% % % % % % %I think instead of doing the min and max we should do a convex hull
% % % % % % %strategy
% % % % % % %Sadly the convex hull had way more points than I anticipated
% % % % % % %However, we could use this to test the prediction model
% % % % % % %and whether or not we need to use a different algorithm
% % % % % % %- see convhulln
% % % % % % %--------------------------------------------------------------------------
% % % % % % [~,I_min] = min(applied_stimuli);
% % % % % % [~,I_max] = max(applied_stimuli);
% % % % % % 
% % % % % % first_group = unique([I_min I_max]);
% % % % % % 
% % % % % % n_first_group = length(first_group);
% % % % % % 
% % % % % % chosen_stimuli = applied_stimuli(first_group,:);
% % % % % % %--------------------------------------------------------------------------
% % % % % % 
% % % % % % 
% % % % % % %NOTE: If K is greather than length, no error occurs which is fine
% % % % % % [idx_nn,dist_nn] = knnsearch(applied_stimuli,applied_stimuli,'K',50);
% % % % % % 
% % % % % % dist_nn = dist_nn'; %
% % % % % % 
% % % % % % %Initialization of distance metrics and loop variables
% % % % % % %--------------------------------------------------------------------------
% % % % % % if isempty(old_stimuli)
% % % % % %     [~,smallest_distance_to_known_point] = knnsearch(chosen_stimuli,applied_stimuli);
% % % % % % else
% % % % % %     [~,smallest_distance_to_known_point] = knnsearch([chosen_stimuli; old_stimuli],applied_stimuli);
% % % % % % end
% % % % % % 
% % % % % % 
% % % % % % %Main algorithm
% % % % % % %--------------------------------------------------------------------------
% % % % % % chosen_points    = zeros(1,n_new_stimuli);
% % % % % % max_dist_removed = zeros(1,n_new_stimuli);
% % % % % % 
% % % % % % not_chosen_mask              = true(1,n_new_stimuli);
% % % % % % not_chosen_mask(first_group) = false;
% % % % % % 
% % % % % % for iPoint = n_first_group+1:n_new_stimuli
% % % % % %     
% % % % % %    %SLOW LINE
% % % % % %    [maxValue,I] = max(smallest_distance_to_known_point); %Get point furthest from all old points
% % % % % %    if maxValue == 0 
% % % % % %       error('Repetitions present, prior code should have removed repetitions')
% % % % % %    end
% % % % % %    
% % % % % %    chosen_points(iPoint) = I;
% % % % % %    
% % % % % %    %INSIGHT
% % % % % %    %-----------------------------------------------------------------------
% % % % % %    %Let's say we get a maxValue of 1 for this point
% % % % % %    %meaning this point is the farthest distance of any unknown point
% % % % % %    %to some known point.
% % % % % %    %Let's say the closest 3 points are 0.2 1 and 2 away
% % % % % %    %knowledge of this point can only improve the first two samples, as the
% % % % % %    %third one must already have a closer point, otherwise it would 
% % % % % %    %be the max value. This means instead of taking the min
% % % % % %    %over all unknown points, we only take the min over the first set
% % % % % %    %of points, which leads to less comparisons.
% % % % % %    
% % % % % %    I_update = find(dist_nn(:,I) > maxValue,1);
% % % % % %    
% % % % % %    if isempty(I_update)
% % % % % %        %This means our knnsearch was too small, compute all ...
% % % % % %        
% % % % % %    %The smallest distance from all unknown points to known points
% % % % % %    %is now the minimum of either previous minimum distances, or the
% % % % % %    %distance from these points to the chosen point (which is know
% % % % % %    %considered to be a known point)
% % % % % %    
% % % % % %    %SLOW LINE :/
% % % % % %    %Increasting K in nn decreases these calls
% % % % % %    %but it also increases nn search time
% % % % % %    smallest_distance_to_known_point(not_chosen_mask) = ...
% % % % % %        min(smallest_distance_to_known_point(not_chosen_mask),pdist2(applied_stimuli(not_chosen_mask,:),applied_stimuli(I,:)));
% % % % % %    else 
% % % % % %       indices = idx_nn(I,1:I_update-1);      
% % % % % %       smallest_distance_to_known_point(indices) = ...
% % % % % %             min(smallest_distance_to_known_point(indices),dist_nn(1:I_update-1,I));        
% % % % % %    end
% % % % % %    
% % % % % %    not_chosen_mask(I)       = false;
% % % % % %    max_dist_removed(iPoint) = maxValue;
% % % % % % end
% % % % % % 
% % % % % % %Using this information to form groups
% % % % % % %==========================================================================
% % % % % % %Step 1: How many points to place in each group ...
% % % % % % %-----------------------------------------------
% % % % % % normalized_contributions = cumsum(max_dist_removed)./sum(max_dist_removed);
% % % % % % 
% % % % % % %NOTE: We remove the normalized contributions from those enries
% % % % % % %that make up the first group, so that sum(N) = total_points - n_first_group
% % % % % % N = histc(normalized_contributions(n_first_group+1:end),0:obj.opt__TESTING_PERCENTAGE_SPACING:1+obj.opt__TESTING_PERCENTAGE_SPACING);
% % % % % % 
% % % % % % non_empty_groups   = find(N ~= 0);
% % % % % % n_non_empty_groups = length(non_empty_groups);
% % % % % % 
% % % % % % %Step 2: Assignment of groups based on # to place in each group
% % % % % % %-----------------------------------------------
% % % % % % n_groups_total     = n_non_empty_groups+1;
% % % % % % 
% % % % % % all_groups    = cell(1,n_groups_total);
% % % % % % all_groups{1} = new_indices_use(first_group);
% % % % % % 
% % % % % % last_used_index  = n_first_group;
% % % % % % for iGroup = 1:n_non_empty_groups
% % % % % %     cur_group_N = N(non_empty_groups(iGroup));
% % % % % %     
% % % % % %     %NOTE: offset by 1 is to account for first_group set
% % % % % %     %NOTE: We reindex back into the indices passed into the function
% % % % % %     all_groups{iGroup+1} = new_indices_use(chosen_points(last_used_index+1:last_used_index+cur_group_N));
% % % % % %     last_used_index      = last_used_index + cur_group_N;
% % % % % % end
% % % % % % 
% % % % % % groups_of_indices_to_run = all_groups;


end