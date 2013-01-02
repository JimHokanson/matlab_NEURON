function groups_of_indices_to_run = getGroups(...
    obj,applied_stimuli,cell_locations,old_stimuli,thresholds,old_locations)

%NOTE: We don't currently use the previous threshold information
%or location info but we could eventually ...

%==========================================================================
%QUESTION : Do we peform an initial transform of the input stimulus
%ANSWER   : I believe we should take 1/x^2, see reasoning below
%NOTE: An alternative approach would be to compare in differential space
%***** This might be the most appropriate of all ...
%NOTE: This is also essentially equivalent to how one predicts the values
%and ideally these two methods could interact in a learning system
%==========================================================================
%The problem with the current solution is that the applied stimulus
%is not linearly related to threshold, which makes using distance between
%stimuli a bad metric (although it should suffice for now)
%
%In general it is believed that a rough threshold = I0 + k*r^2 law holds
%
%Stimuli = 1/r
%
%Threshold = f(stimuli)?????
%
%   NOTE: This is a rough approximation and doesn't take into account
%   gradients or multiple electrodes changing things
%
%THE WORK
%--------------------------------------------------------------------------
%r = 1/stimuli
%
%   threshold = I0 + k*(1/stimuli)^2
%
%   Thus, a hypothesis is that we'll get quicker convergence if we learn
%   based on a distance that compares 1/stimuli^2 then if we learn over
%   stimuli to the 2nd.
%
%   NOTE: Once we collect the data we could easily test this with
%   regression.
%
%
%
%   TODO: Finish this line of thought
%
%   GOAL: Essentially we want our distance metric to evenly sample
%   threshold, which we don't know, but we might be able to make an
%   intelligent guess about what we don't know

%==========================================================================
%QUESTION:Do we include new group data in subsequent runs
%ANSWER  : YES!
%See below for reasoning
%==========================================================================
%NOTE: On subsequent runs, when adding new base values, we need
%to keep previous base values so as to provide valid references
%example
%Consider the numbers 1:100, and say we grab 3 values on each run
%The numbers 1:100 represent numbers in some higher dimensional space
%but where the distance is easily interepreted as the different between
%two numbers
%Round 1
%1    50     100
%Round 2
%If we keep the previous values
%1 25 50 65 75 100 %Possibly outcome, not the best
%If we don't keep the previous values
%2 51 99  likely outcome, we esentially try and replicate Round 1
%which is not desirable




%**************************************************************************
%Things to do before function is done:
%1) Input transform
%2) Reduce dimensionality before distance testing
%3) Try kmeans based approach
%       - take kmeans with clusters equal to # of points to add
%       - how does this take into account previous work?????
%4) Write better code for group sizes, we should start small
%with only a few points and then increase the relative group size
%as we progress, then at some point we should throw everything into the
%remaining group
%5) Reduce previous data as well into fake previous data
%   NOTE: This is where the previous threshold data might become useful ...
%


keyboard


%For right now we'll do a really basic algorithm. This could get fancier at
%some point ...








n_sims_per_group_local   = obj.opt__n_sims_per_group;
n_new_stimuli  = size(applied_stimuli,1);
n_groups_total = ceil(n_new_stimuli/n_sims_per_group_local;

groups_of_indices_to_run = cell(1,n_groups_total);



unmatched_indices = 1:n_new_stimuli;


N_RANDOMIZATIONS = 2000; %We might change this or allow the user to change this eventually


distance_between_new     = pdist2(applied_stimuli,applied_stimuli);
if isempty(old_stimuli)
    distance_between_new_old = [];
else
    distance_between_new_old = pdist2(applied_stimuli,old_stimuli);
end

min_distance_old = min(distance_between_new_old,[],2);

%How to go from this to the randomization?????


min_dist_best_aligned = Inf(n_new_stimuli,1);
best_score_all = zeros(1,n_groups_total);
for iGroup = 1:n_groups_total-1
    
   %remaining_data = applied_stimuli(unmatched_indices,:);
   
   n_remaining = length(unmatched_indices);
   
   use_as_next_group_mask = false(1,n_remaining);
   
   score = Inf;
   for iRand = 1:N_RANDOMIZATIONS
      use_as_next_group_mask(:) = false;
      use_as_next_group_mask(randperm(n_remaining,n_sims_per_group_local)) = true;
      
      possible_next_group_indices = unmatched_indices(use_as_next_group_mask);
      remaining_unmatched_indices = unmatched_indices(~use_as_next_group_mask);
      
      dist_1 = distance_between_new(remaining_unmatched_indices,possible_next_group_indices);
      
      min_dist_1 = min(dist_1,[],2);
      
      if isempty(min_distance_old)
          temp_score = sum(min_dist_1);
      else
          temp_score = sum(min(min_dist_1,min_distance_old(remaining_unmatched_indices)));
      end

      if temp_score < score
          score = temp_score;
          best_use_as_next_group_mask = use_as_next_group_mask;
          min_dist_best     = min_dist_1;
      end
   end
   
   best_score_all(iGroup) = score;
   
   %NOTE: These indices are aligned to the indices of
   %unmatched_indices, not the original values
   best_next_indices = find(best_use_as_next_group_mask);
   
   groups_of_indices_to_run{iGroup} = unmatched_indices(best_next_indices);
   
   unmatched_indices(best_next_indices) = [];

   min_dist_best_aligned(unmatched_indices) = min_dist_best;
   
   if isempty(min_distance_old)
       min_distance_old = min_dist_best_aligned;
   else
       min_distance_old = min(min_dist_best_aligned,min_distance_old);
   end
   
end

groups_of_indices_to_run{end} = unmatched_indices;

keyboard

%Some plot testing
row = zeros(1,n_new_stimuli);
c = cell_locations;
for iGroup = 1:n_groups_total
   row(groups_of_indices_to_run{iGroup}) = iGroup; 
   i_use = find(row ~= 0);
   scatter3(c(i_use,1),c(i_use,2),c(i_use,3),100,row(i_use),'filled');
   axis equal
   title(sprintf('Run %d',iGroup))
   pause
end






end
