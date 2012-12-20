function [threshold_value,n_loops] = determine_threshold(obj,starting_value)
%NOTE: This will require use of the threshold_cmd object ...
%
%
%   TODO:
%   =======================================================================
%   1) Provide result class
%   2) Handle edge cases
%   3) Handle bounding errors more appropriately
%   4) Document results ...
%   5) Do subthreshold to threshold projections ...


%What about if there is:
%1) - no stim
%2) - infinite applied extracellular voltage????


stim_sign = sign(starting_value);

%NEURON.simulation.extracellular_stim.threshold_cmd;
t = obj.parent.threshold_options_obj;

r = run_stimulation(obj,starting_value);

%Bounding the solution
%--------------------------------------------------------------------------
[lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,starting_value);
if isempty(lower_bound)
    [lower_bound,upper_bound,n_loops] = helper_getLowerBound(obj,t,starting_value);
else
    [lower_bound,upper_bound,n_loops] = helper__getHigherBound(obj,t,starting_value);
end

%Binary search until solution is found
%--------------------------------------------------------------------------
while true
   bound_difference = abs(upper_bound - lower_bound);
   if bound_difference < t.threshold_accuracy
       threshold_value = upper_bound;
       break
   end
    
   next_value = helper__getNextValue(obj,stim_sign,lower_bound,bound_difference);
   r = run_stimulation(obj,next_value);
   
   n_loops = n_loops + 1;
   
   [lower_bound_temp,upper_bound_temp] = helper__getNewestBounds(obj,r,t,next_value);
   if isempty(lower_bound_temp)
       upper_bound = upper_bound_temp;
   else
       lower_bound = lower_bound_temp;
   end
end

end

function [lower_bound,upper_bound,n_loops] = helper_getLowerBound(obj,t,starting_value)

%1) Get lower stimulus options
%2) Start testing 

testing_values = getLowerStimulusTestingPoints(t,starting_value);

for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value);
   [lower_bound,temp_upper_bound] = helper__getNewestBounds(obj,r,t,cur_value);
   if isempty(lower_bound)
       upper_bound = temp_upper_bound;
   else
       break;
   end
end

%TODO: Change this to a specific error message for the class
if isempty(lower_bound)
    error('Unable to find a lower stimulus bound ...')
end

n_loops = iTest + 1;

end

function [lower_bound,upper_bound,n_loops] = helper__getHigherBound(obj,t,starting_value)

%1) Get higher stimulus options
%2) Start Testing
%3) We might be able to do predictions based on max potential - test later ...

testing_values = getHigherStimulusTestingPoints(t,starting_value);

for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value);
   [temp_lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,cur_value);
   if isempty(upper_bound)
       lower_bound = temp_lower_bound;
   else
       break;
   end
end

%TODO: Change into specific error for class
if isempty(upper_bound)
   error('Unable to find a upper stimulus bound ...') 
end

n_loops = iTest + 1;

end

function next_value = helper__getNextValue(obj,stim_sign,lower_bound,bound_difference)
   if stim_sign < 0
      next_value = lower_bound - 0.5*bound_difference; 
   else
      next_value = lower_bound + 0.5*bound_difference;
   end
end

function isShort = helper__isShortSimCondition(obj,r,t)
%
%   This function indicates that the simulation was not run for a
%   sufficient amount of time ...
%

sim = obj.parent;
first_index_end_time = find(sim.time_vector >= sim.tstop - t.short_simulation_test_time,1);
if isempty(first_index_end_time)
    %??? Is our simulation too short?
    %
    error('See code')
end
temp_vm = r.membrane_potential(first_index_end_time:end,:);
isShort = any(temp_vm(:) > membrane_threshold);
end

function [lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,tested_value)

lower_bound = [];
upper_bound = [];

if r.success
    %Cases:
    %1) AP propogation
    %2) failure due time out
    %3) failure due to too strong a stimulus
    if r.ap_propogated
        upper_bound = tested_value;
    elseif r.threshold_crossed %Too strong a stimulus OR too long
        %Need to write code to differentiate ...
        %NOTE: We need a time vector
        if helper__isShortSimCondition(obj,r,t)
            lower_bound = tested_value;
        else
            upper_bound = tested_value;
        end
    else
        lower_bound = tested_value;
    end
elseif r.tissue_fried
    upper_bound = tested_value;
else
    error('Unhandled case')
end



end