classdef predictor < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.predictor
    %
    %   This in general will be an abstract class with some helper
    %   methods that other classes can use ...
    %
    %   QUESTIONS
    %   ===================================================================
    %   1) ??? What's the main call that will return the thresholds ???
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.request_handler
    %   NEURON.xstim.single_AP_sim.predictor.default
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Make sure that we never assign an invalidly signed stimulus ...
    
    %Predictor Options
    %-----------------------------------------------------
    
    %Properties for subclass to use =======================================
    properties
        stim_sign    %Sign to solve for, we need to ensure that we never
        %predict values that are not the correct sign
        logged_data  %NEURON.xstim.single_AP_sim.logged_data
        old_data     %NEURON.xstim.single_AP_sim.solution
        new_data     %NEURON.xstim.single_AP_sim.new_solution
    end
    
    properties
        xstim        %Class: NEURON.simulation.extracellular_stim
        old_stimuli  %Class: NEURON.xstim.single_AP_sim.applied_stimuli
        new_stimuli  %"      "
        dim_reduction_options    %NEURON.xstim.single_AP_sim.dim_reduction_options
        applied_stimulus_matcher %NEURON.xstim.single_AP_sim.applied_stimulus_matcher
        grouper %NEURON.xstim.single_AP_sim.grouper.initialize
        binary_search_adjuster   %NEURON.xstim.single_AP_sim.binary_search_adjuster
    end
    
    properties (Dependent)
        all_done %References the new_data object ...
    end
    
    methods
        function value = get.all_done(obj)
            value = obj.new_data.all_done;
        end
    end
    
    %Object Construction ==================================================
    methods (Static)
        function p = create(predictor_type)
            switch lower(predictor_type)
                case 'default'
                    p = NEURON.xstim.single_AP_sim.predictor.default;
                otherwise
                    error('Predictor type not recognized')
            end
        end
    end
    
    methods
        function initializeSuperProps(obj,logged_data,new_data,xstim_obj,stim_sign)
            %This method should be called by request handler to initialize
            %the properties that this class holds ...
            %
            %    NOTE: We might add a hook to allow initialization of the
            %    subclasses after this ...
            %
            %   INPUTS
            %   ===========================================================
            %   logged_data : NEURON.xstim.single_AP_sim.logged_data
            %   new_data    : NEURON.xstim.single_AP_sim.new_solution
            %
            %
            %    See Also:
            %    NEURON.xstim.single_AP_sim.request_handler
            
            obj.xstim       = xstim_obj;
            obj.stim_sign   = stim_sign;
            obj.logged_data = logged_data;
            obj.old_data    = obj.logged_data.solution;
            obj.new_data    = new_data;
            
            obj.old_stimuli              = obj.old_data.getAppliedStimulusObject(xstim_obj);
            obj.new_stimuli              = obj.new_data.getAppliedStimulusObject(xstim_obj);
            obj.dim_reduction_options    = NEURON.xstim.single_AP_sim.dim_reduction_options;
            obj.applied_stimulus_matcher = NEURON.xstim.single_AP_sim.applied_stimulus_matcher(obj);
            obj.grouper                  = NEURON.xstim.single_AP_sim.grouper(obj);
            obj.binary_search_adjuster   = NEURON.xstim.single_AP_sim.binary_search_adjuster(obj);
        end
        function predictor_info = getThresholdSolutions(obj)
            %
            %
            %   predictor_info = getThresholdSolutions(obj)
            %
            %   MAIN SOLVING METHOD
            %   This method wraps calls to the predictor subclasses taking
            %   care of things that I think every subclass will need.
            %
            %   Abstract subclass method: .getThresholds()
            %
            %   FULL PATH:
            %   NEURON.xstim.single_AP_sim.predictor.getThresholdSolutions
            
            [predictor_info] = obj.getThresholds();
            
            obj.new_data.applyWillSolveLaterMethods();
            
            %This combines new data with old data ...
            obj.new_data.mergeResultsWithOld(obj.logged_data);
        end
    end
    
    %Methods for subclasses to implement ==================================
    methods (Abstract)
        [predictor_info] = getThresholds(obj)
    end
    
    methods
        function initializeSubclassProps(obj) %#ok<MANU>
            %Do nothing
            %The subclass can reimplement this ...
        end
    end
    
    %Methods for subclasses to use ========================================
    methods
        function setSameAsOld(obj,new_indices,old_indices)
            %
            %
            %   setSameAsOld(obj,new_indices,old_indices)
            %
            %   This method should be used when we decide that new indices
            %   will have the same solution as old (logged data) values.
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.getStimulusMatches
            %
            %   FULL PATH:
            %   NEURON.xstim.single_AP_sim.predictor.setSameAsOld
            
            old = obj.old_data;
            new = obj.new_data;
            
            thresholds = old.thresholds(old_indices);
            ranges     = old.ranges(old_indices,:);
            
            %NOTE: We use the same type as the old. We lose a bit of info
            %that specifies that the true source, but we maintain the
            %source of the accuracy of the threshold.
            %
            %   :/  - Ideally we could track both ...
            
            types      = old.predictor_types(old_indices);
            
            new.updateSolutions(new_indices,thresholds,types,ranges);
        end
        function initializeLowDStimulus(obj)
            %initializeLowDStimulus Initializes a low-d representation of the stimuli
            %
            %    initializeLowDStimulus(obj)
            %
            %    This only needs to be called if the predictor is going to use it
            
            
            %TODO: Verify that there is a check that this has been done
            %already ...
            obj.old_stimuli.initializeReducedDimStimulus(obj.new_stimuli,obj.dim_reduction_options);
        end
        function addSolutionResults(obj)
            %I want this method to be what predictors can call when they
            %learn new results ...
            %
            %    This will handle the interface to the saving objects
            %    for logging the results ...
        end
    end
    
end

