function result_obj = determine_threshold(obj,starting_value)
%determine_threshold
%
%   result_obj = determine_threshold(obj,starting_value)
%
%   This is the main method that actually implements determining threshold.
%   In general it should not be called by the user. Instead one should
%   refer to a similar method in the extracellular_stim class.
%
%   INPUTS
%   =======================================================================
%   starting_value : Absolute scalar value to start with when determining
%       threshold. Threshold itself is assumed to be a scalar value,
%       regardless of the complexity of the stimulus. The sign of the
%       starting_value limits the solution to being of the same sign. 
%
%   OUTPUTS
%   =======================================================================
%   result_obj : (Class: NEURON.simulation.extracellular_stim.results.threshold_testing_history)
%                Result object that documents the testing performed.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Check applied stimuli to make sure it isn't identically zero
%
%   See Also:
%       NEURON.simulation.extracellular_stim.results.sim__single_stim;
%       NEURON.simulation.extracellular_stim.results.sim__determineThreshold;
%
%   FULL PATH: 
%       NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold


%in.throw_error = true;
%in = processVarargin(in,varargin);

%TODO: Check applied stimulus ...
%What about if there is:
%1) No applied stimulus 
%   - this can come in if exactly half way between two opposite signed stimuli
%2) Infinite applied extracellular voltage????
%   - this is fixed when computing the stimulus ...


%Classes:
%t - NEURON.simulation.extracellular_stim.threshold_options
%r - NEURON.simulation.extracellular_stim.results.single_sim
%result_obj - NEURON.simulation.extracellular_stim.results.threshold_testing_history

t = obj.parent.threshold_options_obj;

%First simulation ---------------------------------------------------------
r = run_stimulation(obj,starting_value);

result_obj = NEURON.simulation.extracellular_stim.results.threshold_testing_history(obj.threshold_info);

%Bounding the solution
%--------------------------------------------------------------------------
lower_bound = helper__getNewestBounds(obj,r,t,starting_value,result_obj);
if isempty(lower_bound)
    [lower_bound,upper_bound] = helper__getLowerBound(obj,t,starting_value,result_obj);
else
    [lower_bound,upper_bound] = helper__getHigherBound(obj,t,starting_value,result_obj);
end

%Binary search until solution is found
%--------------------------------------------------------------------------
while true
    
   %Stopping condition check
   %----------------------------------------------------------
   bound_difference = abs(upper_bound - lower_bound);
   if bound_difference < t.threshold_accuracy
       break
   end
    
   next_value = helper__getNextValue(lower_bound,bound_difference);
   r = run_stimulation(obj,next_value);
   
   [lower_bound_temp,upper_bound_temp] = helper__getNewestBounds(obj,r,t,next_value,result_obj);
   if isempty(lower_bound_temp)
       upper_bound = upper_bound_temp;
   else
       lower_bound = lower_bound_temp;
   end
end

%Threshold - upper bound or halfsies?
if t.use_halfway_value_as_threshold
    bound_difference = abs(upper_bound - lower_bound);
    stimulus_threshold = helper__getNextValue(lower_bound,bound_difference);
else
    stimulus_threshold = upper_bound;
end

result_obj.finalizeData(stimulus_threshold);

end

function [lower_bound,upper_bound,n_loops] = helper__getLowerBound(obj,t,starting_value,result_obj)

%1) Get lower stimulus options
%2) Start testing 

testing_values = getLowerStimulusTestingPoints(t,starting_value);
upper_bound    = starting_value;
for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value);
   [lower_bound,temp_upper_bound] = helper__getNewestBounds(obj,r,t,cur_value,result_obj);
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

function [lower_bound,upper_bound,n_loops] = helper__getHigherBound(obj,t,starting_value,result_obj)

%1) Get higher stimulus options
%2) Start Testing
%3) We might be able to do predictions based on max potential - test later ...

testing_values = getHigherStimulusTestingPoints(t,starting_value);
lower_bound    = starting_value;
for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value);
   [temp_lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,cur_value,result_obj);
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

function next_value = helper__getNextValue(lower_bound,bound_difference)
%
%
%   INPUTS
%   =====================================
%   lower_bound - lower bound

   if lower_bound < 0
      next_value = lower_bound - 0.5*bound_difference; 
   else
      next_value = lower_bound + 0.5*bound_difference;
   end
end

function isShort = helper__isShortSimCondition(obj,r,t)
%helper__isShortSimCondition
%
%   isShort = helper__isShortSimCondition(obj,r,t)
%
%   INPUTS
%   =======================================================================
%   r :
%   t :
%
%   In this code we are trying to distinguish between a strong stimulus
%   which does not propogate, and a sufficiently strong stimulus which just
%   does not have enough time to propogate because the simulation is too
%   short.
%
%   In general, if the stimulus is too strong, we won't expect any of the
%   membrane to be above threshold close to the end of the simulation. The
%   parameter that tells us how far back to go from the end of the simulation
%   is in the threshold options as:
%       .short_simulation_test_time
%
%   NOTE: This obtains the time vector from the simulation object. 
%   This might eventually change to being an object of its own ...

sim_props = obj.parent.props_obj;
first_index_end_time = find(sim_props.time_vector >= sim_props.tstop - t.short_simulation_test_time,1);
if isempty(first_index_end_time)
    %??? Is our simulation too short?
    %
    error('See code')
end
temp_vm = r.membrane_potential(first_index_end_time:end,:);
isShort = any(temp_vm(:) > r.vm_threshold);
end

function [lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,tested_value,result_obj)
%helper__getNewestBounds
%
%   [lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,tested_value,result_obj
%
%   This is the main function that is responsible for analyzing the
%   membrane potential and determining whether or not to go higher or lower
%   with the stimulus ...
%
%   INPUTS
%   =======================================================================
%   r : NEURON.simulation.extracellular_stim.results.single_sim
%
%
%   OUTPUTS
%   =======================================================================
%   Important, an empty output indicates that the bound was not set.
%   lower_bound :
%   upper_bound :
%
%   

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


result_obj.logResult(tested_value,isempty(lower_bound),r.max_membrane_potential,r.membrane_potential)


end