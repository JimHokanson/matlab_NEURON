classdef threshold_options < handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.threshold_options
    %
    %   This class was specifically designed with the idea of determining
    %   a singular stimulus threshold. It's main function is to hold
    %   relevant property values in a single location.
    %
    %   Documentation
    %   ===================================================================
    %   1) This class relies on the scaling extracellular stimulation
    %   concept where threshold is really a scaling factor on some default
    %   stimulus. Only the two in combination provide an absolute value.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow absolute or relative threshold accuracy. This might
    %   require changing the property names
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    
    properties
        use_halfway_value_as_threshold = true %If true, the threshold
        %reported is not actually tested for threshold but is half way
        %between the minimum and maximum. In general this will be a more
        %accurate estimate of threshold.
        
        threshold_accuracy_option = 'absolute' %Not yet implemented
        
        threshold_accuracy = 0.1  %How fine to get when determining threshold. 
        %The current implementation is actually at worst half this value
        %due to halving. (better explanation needed) I might want to change
        %the implementation to reflect reality. This could also use a name
        %change as this is a worst case value.
        
        %.changeGuessAmount() - recommended, not required
        guess_amounts = 2.^(1:8)  %When determining threshold a binary search 
        %algorithm is used. The algorithm itself however must first be
        %bound. These are the amounts that are added to one side in order
        %to try and determine bound. IMPORTANTLY, this can be updated in
        %cases where the starting point is more exact to limit halving
        %steps.
        
        throw_error_on_no_solution = true %otherwise NaN returned
        
        short_simulation_test_time = 0.1; %This is the time from the end of
        %the simulation that is examined to try and distinguish between
        %insufficient time to propogate and too strong a stimulus.
    end
    
    methods 
        function set.guess_amounts(obj,new_value)
           %TODO: Implement checks
           %1) positive
           %2) not empty
           
           obj.guess_amounts = new_value;
        end
    end
    
    properties
        max_threshold = 10000 %Units uA 
    end
    
    properties (Constant)
        MIN_THRESHOLD = 0.001 %Units uA
    end
    
    methods 
        function changeGuessAmount(obj,guess_unit,varargin)
           %
           in.scaling   = 2;
           in.n_guesses = length(obj.guess_amounts);
           in = processVarargin(in,varargin);
           
           obj.guess_amounts = abs(guess_unit)*in.scaling.^(1:in.n_guesses);
        end
        function testing_values = getLowerStimulusTestingPoints(obj,starting_value)
           %getLowerStimulusTestingPoints
           %
           %    testing_values = getLowerStimulusTestingPoints(obj,starting_value)
           %
           
           s = sign(starting_value);
           starting_value = abs(starting_value);
           testing_values = starting_value - obj.guess_amounts;
           testing_values(testing_values <= obj.MIN_THRESHOLD) = [];
           testing_values = s.*[testing_values obj.MIN_THRESHOLD];
        end
        function testing_values = getHigherStimulusTestingPoints(obj,starting_value)
           %getHigherStimulusTestingPoints
           %
           %    testing_values = getHigherStimulusTestingPoints(obj,starting_value)
           %
           s = sign(starting_value);
           starting_value = abs(starting_value);
           testing_values = starting_value + obj.guess_amounts;
           testing_values(testing_values >= obj.max_threshold) = [];
           testing_values = s.*[testing_values obj.max_threshold]; 
        end
    end
end

