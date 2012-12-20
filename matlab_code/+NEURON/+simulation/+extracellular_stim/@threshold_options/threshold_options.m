classdef threshold_options < handle_light
    %
    %  
    
    %?? Move threshold_analysis options into here????
    
    properties
        max_threshold         = 10000 %Units uA
    end
    
    properties
        threshold_accuracy         = 0.1  %How fine to get when determining threshold
        guess_amounts              = 2.^(1:8)
        throw_error_on_no_solution = true %otherwise NaN returned
        make_init_guess_by_voltage = false; %If true, make the start scale 
        %use a fixed voltage which is equal to the input - i.e. adjust
        %scale so that it generates the input, with the input treated as a
        %target mV level (maximum applied potential)
        %NOT YET IMPLMENTED - how to handle sign??????
        
        
        short_simulation_test_time = 0.1; %This is the time from the end of
        %the simulation that is examined to try and distinguish between
        %insufficient time to propogate and too strong a stimulus
    end
    
    properties (Constant)
        MIN_THRESHOLD = 0.01 %Units uA
    end
    
    methods 
        function testing_values = getLowerStimulusTestingPoints(obj,starting_value)
           %TODO: Document
           s = sign(starting_value);
           starting_value = abs(starting_value);
           testing_values = starting_value - obj.guess_amounts;
           testing_values(testing_values <= obj.MIN_THRESHOLD) = [];
           testing_values = s.*[testing_values obj.MIN_THRESHOLD];
        end
        function testing_values = getHigherStimulusTestingPoints(obj,starting_value)
           %TODO: Document 
           s = sign(starting_value);
           starting_value = abs(starting_value);
           testing_values = starting_value - obj.guess_amounts;
           testing_values(testing_values >= obj.max_threshold) = [];
           testing_values = s.*[testing_values obj.max_threshold]; 
        end
    end
end

