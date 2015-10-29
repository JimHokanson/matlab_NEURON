classdef threshold_options < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.threshold_options
    %
    %   This class was specifically designed with the idea of determining
    %   a singular stimulus threshold. It's main function is to hold
    %   relevant property values in a single location.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow absolute or relative threshold accuracy. This might
    %   require changing the property names
    %   2) 
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    %       NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    
    properties (Constant)
        THERSHOLD_ERROR_OPTIONS = {'absolute' 'relative'} 
        MIN_THRESHOLD = 0.000001 %Units uA
    end
    
    properties
        max_threshold = 10000 %(Units uA), This is the maximum stimulus
        %amplitude to test when trying to find threshold bounds before
        %throwing an error. It is used after all guess amounts have been 
        %tried to try and get the upper bound for stimulus threshold.
    end
    
    properties
        use_halfway_value_as_threshold = true  %(default: true) If true, the
        %threshold reported is not actually tested for threshold but is
        %half way between the lowest tested value which provided a response
        %and the highest tested value which did not give a response. In
        %general this will be a more accurate estimate of threshold. If
        %false threshold is the lowest tested value which gave a response.
        %Setting the value false guarantees that the tested amplitude is
        %sufficient to yield a response.
        
        threshold_error_option = 'absolute' %Not yet implemented
    end
 
    properties
        max_threshold_error_absolute = 0.1  %How fine to get when determining 
        %threshold. As implemented, when the halfway value is used 
        %(see prop above) the max error is actually half the value of this
        %property.
        
        %NOT YET IMPLEMENTED
        %max_threshold_error_relative = 1    %Maximum percent difference
        %between true threshold and reported threshold
        
        %.changeGuessAmount() - method is recommended but not required
        guess_amounts = 2.^(1:8)  %When determining threshold a binary search 
        %algorithm is used. The algorithm itself however must first be
        %bound. These are the amounts that are added to one side in order
        %to try and determine bound. IMPORTANTLY, this can be updated in
        %cases where the starting point is more exact to limit halving
        %steps.
        
        %NOT YET IMPLEMENTED
        throw_error_on_no_solution = true %otherwise NaN returned
    end
    
    methods 
        function set.guess_amounts(obj,new_value)
           %
           %    set.guess_amounts(obj,new_value)
           %
           
           %TODO: Implement checks
           %1) positive
           %2) not empty
           
           obj.guess_amounts = new_value;
        end
    end
    

    
    methods 
        function changeGuessAmount(obj,guess_unit,varargin)
           %changeGuessAmount
           %
           %    changeGuessAmount(obj,guess_unit,varargin)
           %
           %    Helper method to set the growth rate of guessing
           %    
           %
           %    INPUTS
           %    ===========================================================
           %    guess_unit : 
           %
           in.scaling   = 2;
           in.n_guesses = length(obj.guess_amounts);
           in = NEURON.sl.in.processVarargin(in,varargin);
           
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

