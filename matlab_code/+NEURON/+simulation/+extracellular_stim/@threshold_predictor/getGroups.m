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

%Transform to make data bit more linear in threshold distance ...
%---------------------------------------------------------------------
% % % applied_stimuli = 1./applied_stimuli; %Two looked bad, going back to 1
% % % %NOTE: 2 might have been bad due to not carrying the sign when squaring
% % % old_stimuli     = 1./old_stimuli;



PC_THRESHOLD = 0.99; %Weird threshold definition, see implementation below

%Dimensionality Reduction
%--------------------------------------------------------------------------
n_new_stimuli  = size(applied_stimuli,1);

if isempty(old_stimuli)
    [~,score,latent] = princomp(applied_stimuli,'econ');
else
    [~,score,latent] = princomp([applied_stimuli; old_stimuli],'econ');
end

csl = cumsum(latent) - latent(1);
I = find(csl./csl(end) > PC_THRESHOLD,1);

if isempty(old_stimuli)
    applied_stimuli = score(:,1:I);
else
    applied_stimuli = score(1:n_new_stimuli,1:I);
    old_stimuli     = score(n_new_stimuli+1:end,1:I);
end


%NEW GROUPING STRATEGY
%--------------------------------------------------------------------------
%1) Group 1, all extremes ... of low dim space
%2) From their build at some rate, we'll go with two for now ...
%3) At some point it would be good to cut things off ..., when max distance
%is some value -> sure, let's finish this ...

%DESIGN DECISION - log2
max_groups = floor(log2(n_new_stimuli));

groups_of_indices_to_run = cell(1,max_groups);

[~,I_min] = min(applied_stimuli);
[~,I_max] = max(applied_stimuli);

groups_of_indices_to_run{1} = unique([I_min I_max]);


unmatched_indices = 1:n_new_stimuli;
unmatched_indices(groups_of_indices_to_run{1}) = [];

%Distance initialization
%--------------------------------------------------------------------
distance_between_new     = pdist2(applied_stimuli,applied_stimuli);

keyboard

%Matrix, New

%NEW ALGORITHM
%rows are old points
%columns are new points
%
%
%Crap, I am missing something ....
%The question is, which point if I eliminate would reduce
%the most from the distance of others ...
%This is nearly a complete thought, I just need more work

%Point to elminate is the one closest to all other points - I think
%What happens after the first point ...

%Random thought, not sure if useful, points greater than chosen point
%are replaced with chosen point
%CRAP: I think this is how the algorithm needs to be run
%What if for all points, I replace their distances with the guy 
%that is being chosen, how much does the sum go down for all unmatched
%points ...
%

if isempty(old_stimuli)
   dist_matrix = pdist2(applied_stimuli,applied_stimuli);
else
   dist_matrix = pdist2([applied_stimuli; old_stimuli],applied_stimuli); 
end

sum_dist_matrix = sum(dist_matrix);



%Old distance will be the combination of the first group + 
%the old stimuli (if present)

%This variable will represent the closest point from the original
%set to each point in the unmatched set. It is only valid
%for points that are currently unset.
min_dist_best_aligned = Inf(n_new_stimuli,1);
min_dist_best_aligned(unmatched_indices) = ...
    min(distance_between_new(unmatched_indices,groups_of_indices_to_run{1}),[],2);


%NOTE: This is only for debugging ...
best_score_all = zeros(1,max_groups);



if isempty(old_stimuli)
    min_distance_old = min_dist_best_aligned;
else
    min_distance_old = min(pdist2(applied_stimuli,old_stimuli),[],2);
    min_distance_old = min(min_dist_best_aligned,min_distance_old);
end

best_score_all(1) = sum(min_distance_old(unmatched_indices))/length(unmatched_indices);

N_RANDOMIZATIONS = 200; %We might change this or allow the user to change this eventually


next_set_size = 16; %Start with some multiple of 2, this seems reasonable
%HARDCODED ...
n_remaining = length(unmatched_indices);
iGroup = 1;
while next_set_size < n_remaining
   
   iGroup = iGroup + 1;
   
   %Initialization of mask for local loop
   use_as_next_group_mask = false(1,n_remaining);
   
   %=======================================================================
   % LOCAL LOOP -  
   %=======================================================================
   best_local_score = Inf;
   for iRand = 1:N_RANDOMIZATIONS
      use_as_next_group_mask(:) = false;
      use_as_next_group_mask(randperm(n_remaining,next_set_size)) = true;
      
      %possible_next_group_indices = unmatched_indices(use_as_next_group_mask);
      remaining_unmatched_indices = unmatched_indices(~use_as_next_group_mask);
      
      %NOTE: This is a really slow line :/
      %dist_1 = distance_between_new(remaining_unmatched_indices,possible_next_group_indices);
      %Is this faster?????
      dist_1 = distance_between_new(~use_as_next_group_mask,use_as_next_group_mask);
      
      
      %This is also a slow line ...
      min_dist_1 = min(dist_1,[],2);

      temp_score = sum(min(min_dist_1,min_distance_old(remaining_unmatched_indices)));
 
      if temp_score < best_local_score
          best_local_score = temp_score;
          best_use_as_next_group_mask = use_as_next_group_mask;
          min_dist_best     = min_dist_1;
      end
   end
   
   best_score_all(iGroup) = best_local_score/(length(unmatched_indices)-next_set_size);
   
   %NOTE: These indices are aligned to the indices of
   %unmatched_indices, not the original values
   best_next_indices                        = find(best_use_as_next_group_mask);
   groups_of_indices_to_run{iGroup}         = unmatched_indices(best_next_indices);
   
   unmatched_indices(best_next_indices) = [];
   
   min_dist_best_aligned(unmatched_indices) = min_dist_best;
   
   %Update unmatched points
   
   
   if isempty(min_distance_old)
       min_distance_old = min_dist_best_aligned;
   else
       min_distance_old = min(min_dist_best_aligned,min_distance_old);
   end
   
   next_set_size = 2*next_set_size;
   n_remaining   = length(unmatched_indices);
   
   
end

%Put everyone in a final group & quit
groups_of_indices_to_run{iGroup} = unmatched_indices;
groups_of_indices_to_run(iGroup+1:end) = [];

%groups_of_indices_to_run{end} = unmatched_indices;

best_score_all(iGroup+1:end) = [];

keyboard

%Some plot testing
% row = zeros(1,n_new_stimuli);
% c = cell_locations;
% for iGroup = 1:n_groups_total
%    row(groups_of_indices_to_run{iGroup}) = iGroup; 
%    i_use = find(row ~= 0);
%    scatter3(score(i_use,1),score(i_use,2),score(i_use,3),100,row(i_use),'filled');
%    axis equal
%    title(sprintf('Run %d',iGroup))
%    pause
% end






end
