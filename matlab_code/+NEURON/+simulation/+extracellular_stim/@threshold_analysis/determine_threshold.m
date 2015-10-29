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
%   ERROR CASES
%   =======================================================================
%   1) Failure to find a stimulus which causes action potential
%   propagation. One example in which this can happen is for the HH model
%   at higher temperatures.
%
%   FULL PATH: 
%       NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold

AUTO_EXPAND_SIM_TIME = true;

%in.throw_error = true;
%in = NEURON.sl.in.processVarargin(in,varargin);

%What about if there is:
%1) No applied stimulus 
%   - this can come in if exactly half way between two opposite signed stimuli
%2) Infinite applied extracellular voltage????
%   - this is fixed when computing the stimulus ...


%Classes:
%t - NEURON.simulation.extracellular_stim.threshold_options
%r - NEURON.simulation.extracellular_stim.results.single_sim
%result_obj - NEURON.simulation.extracellular_stim.results.threshold_testing_history

if isnan(starting_value)
    error('Starting value may not be NaN')
end

if starting_value == 0
    error('Starting value may not be equal to 0')
end

t = obj.parent.threshold_options_obj;

obj.ap_propagation_observed = false;

result_obj = NEURON.simulation.extracellular_stim.results.threshold_testing_history(obj.threshold_info);

%First simulation 
%--------------------------------------------------------------------------
r = run_stimulation(obj,starting_value,AUTO_EXPAND_SIM_TIME);

[lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,starting_value,result_obj);
%One of the values from the previous function will be empty, and one will
%be the starting_value that we tested.


%Bounding the solution
%--------------------------------------------------------------------------
if isempty(lower_bound)
    [lower_bound,upper_bound] = helper__getLowerBound(obj,t,upper_bound,result_obj);
else
    [lower_bound,upper_bound] = helper__getHigherBound(obj,t,lower_bound,result_obj);
end

%Binary search until solution is found
%--------------------------------------------------------------------------
while true
    
   %Stopping condition check
   %----------------------------------------------------------
   bound_difference = abs(upper_bound - lower_bound);
   if bound_difference < t.max_threshold_error_absolute
       break
   end
    
   next_value = helper__getNextValue(lower_bound,bound_difference);
   r = run_stimulation(obj,next_value,AUTO_EXPAND_SIM_TIME);
   
   [lower_bound_temp,upper_bound_temp] = helper__getNewestBounds(obj,r,t,next_value,result_obj);
   if isempty(lower_bound_temp)
       upper_bound = upper_bound_temp;
   else
       lower_bound = lower_bound_temp;
   end
end

if ~obj.ap_propagation_observed
    error('Unable to find a stimulus which produces action potential propagation')
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
%helper__getLowerBound
%   
%   [lower_bound,upper_bound,n_loops] = helper__getLowerBound(obj,t,starting_value,result_obj)
%
%   This function is called when it is determined that we need to reduce
%   the stimulus amplitude to find a lower stimulus bound for the halving
%   approach. Specifically we are looking for a stimulus amplitude which
%   does not elicit a response.
%
%   OUTPUTS
%   =======================================================================
%   lower_bound : First stimulus amplitude encountered which does not 
%           elicit a response. This is the primary answer we are looking
%           for.
%   upper_bound : In the process of searching for a lower bound, tests
%       which elicit a response allow us to lower the upper bound. 
%   n_loops     : # of simulations run in this function
%
%   INPUTS
%   =======================================================================


testing_values = getLowerStimulusTestingPoints(t,starting_value);
upper_bound    = starting_value;
for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value,true);
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

n_loops = iTest + 1; %+1 is for the initial simulation ...

end

function [lower_bound,upper_bound,n_loops] = helper__getHigherBound(obj,t,starting_value,result_obj)
%
%
%   [lower_bound,upper_bound,n_loops] = helper__getHigherBound(obj,t,starting_value,result_obj)
%   
%


%1) Get higher stimulus options
%2) Start Testing
%3) We might be able to do predictions based on max potential - test later ...

testing_values = getHigherStimulusTestingPoints(t,starting_value);
lower_bound    = starting_value;
for iTest = 1:length(testing_values)
   cur_value = testing_values(iTest);
   r = run_stimulation(obj,cur_value,true);
   [temp_lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,cur_value,result_obj);
   if isempty(upper_bound)
       lower_bound = temp_lower_bound;
   else
       break;
   end
end

%TODO: Change into specific error for class
%??? - not sure what I meant by this - I think I meant
%just to provide more detail ...
if isempty(upper_bound)
   %This indicates that given the stimuli tested, we
   %keep on seeing a response ...
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

function [lower_bound,upper_bound] = helper__getNewestBounds(obj,r,~,tested_value,result_obj)
%helper__getNewestBounds
%
%   [lower_bound,upper_bound] = helper__getNewestBounds(obj,r,t,tested_value,result_obj
%
%   This is the main function that is responsible for analyzing the
%   membrane potential and determining whether or not to go higher or lower
%   with the stimulus.
%
%   INPUTS
%   =======================================================================
%   r : NEURON.simulation.extracellular_stim.results.single_sim
%
%   OUTPUTS
%   =======================================================================
%   Important, an empty output indicates that the bound was not set. Only
%   one of these two values is set in this function.
%
%   lower_bound : New lower bound where the cell doesn't respond to the
%                 stimulus.
%   upper_bound :
%
%   

lower_bound = [];
upper_bound = [];

if r.success
    if r.ap_propagated
        upper_bound = tested_value;
        obj.ap_propagation_observed = true;
        response_option = 1;
    elseif anyAboveThreshold(obj,r.membrane_potential)
        %Too strong a stimulus OR simulation ran an insufficient amount of time
        %------------------------------------------------------------------
        %The idea of too strong a stimulus comes from monophasic stimuli
        %where a sufficiently strong stimulus can theoretically cause
        %inhibition of propogation. Insufficient run time should not happen
        %due to automatically prolonging the duration of the stimulus
        %should the membrane potential be increasing at the end.
        
        %NOTE: ap propagation was not observed, it is just inferred
        upper_bound = tested_value;
        response_option = 2;
    else
        lower_bound = tested_value;
        response_option = 4;
    end
elseif r.tissue_fried
    upper_bound = tested_value;
    response_option = 3;
else
    error('Unhandled case')
end

result_obj.logResult(tested_value,response_option,r.membrane_potential)
end