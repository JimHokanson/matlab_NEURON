classdef threshold_cmd < handle
    %
    %   TODO:
    %   - move into extracellular_stim package
    %
    %   threshold_cmd
    %
    %   This class provides instructions as to how to determine the
    %   threshold stimulus for a extracellular_stim simulation.
    %
    %   Specifically it:
    %   1) Provides guidance as to how to arrive at the maximum stimulus
    %   amplitude that should be tested for a given extracellular
    %   stimulation. A binary search algorithm is used to determine
    %   threshold but it must be bounded. This object specifies how to
    %   determine the maximum bound
    %   2) After an initial guess, the algorithm must determine the range.
    %   It is advantageous to provide a small range. Information on what to
    %   do after the initial guess is provided in this class.
    %   3) Properties related to the final solution are provided in this
    %   class, such as how accurate the solution should be and whether or
    %   not a positive or negative stimulus is allowed.
    %
    %   RULES FOR DETERMINING MAXIMUM STIMULUS AMPLITUDE
    %   ===================================================================
    %   
    %
    %
    %   TODO: Implement a threshold_analysis class
    %   ===================================================================
    %   The threshold analysis class will analyze whether or not an action
    %   potential has fired given more stringent criteria than we are
    %   currently using.
    %
    %   TODO: Recognize stimulus overload and handle appropriately
    %   ===================================================================
    %   When we "fry" the cell, which is generally indicated by an error
    %   along the lines of "exp(737.17) out of range, returning exp(700)" 
    %   we should adjust the max stimulus level appropriately, and then
    %   continue on, noting that the max level has been adjusted due to the
    %   "frying" effect. More specifically, the frying occurs if we test a
    %   really large stimulus on the cell. Generally this happens when we
    %   test a stimulus is excessively large given the close proximity of
    %   the cell to an electrode.
    %
    %
    %In NEURON.simulation.extracellular_stim as the property: .threshold_cmd_obj
    %
    
    properties
        max_threshold         = 100     %User defined max, (Units: uA)
        minimum_max_threshold = 20      %This property is used to specify the minimum level
                                        %of current that should be tested
                                        %at any given location. This is to handle
                                        %cases where the stimulus being tested
                                        %is really small due to the stimulus voltage being applied
                                        %(Units: uA)
        use_max_threshold = true        %if false, relies on the MAX_APPLIED_STIMULUS_VOLTAGE parametere exclusively
    end
    
    properties
        threshold_accuracy   = 0.1      %How fine to get when determining threshold
        guess_amount         = 1        %Amount to try and bound initially, afterwards it defaults to the max and min
        throw_error_on_no_solution = true %otherwise NaN returned
    end
    
    properties (Constant)
        MAX_APPLIED_STIMULUS_VOLTAGE = 3000 %mV
        %NOTE: I'm not sure what is reasonable here and I might need to
        %change this. I'm trying to prevent "exp(737.17) out of range,
        %returning exp(700)" (response from NEURON). This occurs when the
        %electrode is too close to a cell and the solver tests a current
        %level that is way too high. In other words, when finding
        %threshold, if we are off on the guess and increase our guess to
        %the stimulus max, if the max is not appopriate it will cause the
        %error/warning to occur. NOTE: We should detect that this has
        %occured and update our maximum accordingly.
    end

    properties (SetAccess = private)
        max_threshold_safe %Should only be changed by this class
        %init__create_stim_info
    end
    
    methods
        function value = getMaxThresholdForSim(obj)
            %getMaxThresholdForSim
            %
            %   We use the user specified value unless the specified value
            %   is too large given our proximity of the electrode to the
            %   cell. In that case the max_threshold_safe value is used,
            %   which is based on the constant, MAX_APPLIED_STIMULUS_VOLTAGE
            %
            %   NOTE: We can also use the safe value always if we set the
            %   property .use_max_threshold to false
            %
            %   See Also:
            %       NEURON.threshold_cmd.adjust_max_safe_threshold
            %
            
            if ~isempty(obj.max_threshold_safe)
                if obj.use_max_threshold
                    value = min(obj.max_threshold,obj.max_threshold_safe);
                else
                    value = obj.max_threshold_safe;
                end 
                if value < obj.minimum_max_threshold
                    value = obj.minimum_max_threshold;
                end
            else
                value = obj.max_threshold;
            end
        end
        function adjust_max_safe_threshold(obj,max_voltage_at_scale_1)
            %adjust_max_safe_threshold
            %
            %   adjust_max_safe_threshold(obj,max_voltage_at_scale_1)
            %
            %   INPUTS
            %   ======================================================
            %   max_voltage_at_scale_1 : 
            %
            %   KNOWN CALLERS
            %   =======================================
            %   NEURON.ext
            
            max_scale = obj.MAX_APPLIED_STIMULUS_VOLTAGE/max_voltage_at_scale_1;
            obj.max_threshold_safe = max_scale;
        end
    end
    
end

