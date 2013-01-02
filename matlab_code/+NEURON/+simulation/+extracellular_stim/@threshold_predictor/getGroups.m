function groups_of_indices_to_run = getGroups(...
    obj,applied_stimuli,cell_locations,old_stimuli,thresholds,old_locations)

%For right now we'll do a really basic algorithm. This could get fancier at
%some point ...

% A nice algorithm would minimize distances from all points to the nearest
% selected point
%
%i.e. minimize(sum over all points(point - chosen point that is closest)
%
%It would do this repeatably, choosing a set of points


%TODO: Reduce data
%TODO: With lots of samples this could get slow really quickly
%for the representative input sample we should reduce to a representative
%set that is maximially different - use clustering techniques????


groups_of_indices_to_run = [];


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



n_new_stimuli = size(applied_stimuli,1);

n_groups_total = ceil(n_new_stimuli/obj.opt__n_sims_per_group);

groups_of_indices_to_run = cell(1,n_groups_total);

n_sims_per_group_local = obj.opt__n_sims_per_group;

matched_indices   = [];
unmatched_indices = 1:n_new_stimuli;

current_base_data = old_stimuli;

N_RANDOMIZATIONS = 1000; %We might change this or allow the user to change this eventually

rand_total = zeros(N_RANDOMIZATIONS,obj.opt__n_sims_per_group);

scores     = zeros(1,N_RANDOMIZATIONS);

for iGroup = 1:n_groups_total-1
    
   remaining_data = applied_stimuli(unmatched_indices,:);
   
   n_remaining = length(unmatched_indices);
   
   
   
   for iRand = 1:N_RANDOMIZATIONS
      
      %NOTE: Do I want to change to writing as a column????
       
       test_indices = randperm(n_remaining,n_sims_per_group_local);
      
       rand_total(iRand,:) = test_indices;
       
      other_indices = 1:n_remaining;
      other_indices(test_indices) = [];
      
      unmatched_data = remaining_data(other_indices,:);
      matched_data   = [remaining_data(test_indices,:); current_base_data];
      
      D = pdist2(unmatched_data,matched_data);
      
      keyboard
      
      %scores(iRand) = min(D);
      
      %Get distance metric
      %Update scores
   end
   
   %Take out best solution
   [~,best_score_index] = min(scores);
   best_next_indices = rand_total(best_score_index,:);
   
   groups_of_indices_to_run{iGroup} = unmatched_indices(best_next_indices);
   
   unmatched_indices(best_next_indices) = [];
   
   %current_base_data = [current_base_data; remaining_data
       
   
   
   
end



end
