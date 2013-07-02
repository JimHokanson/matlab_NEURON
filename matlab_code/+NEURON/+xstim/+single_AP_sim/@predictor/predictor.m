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
    %
    
    %Predictor Options
    %-----------------------------------------------------
    
    properties
    end
    
    %Properties for subclass to use =======================================
    properties
       old_data     %NEURON.xstim.single_AP_sim.solution
       new_data     %class that has yet to be created
    end
    
    properties
       old_stimuli  %Class: NEURON.xstim.single_AP_sim.applied_stimuli
       new_stimuli
    end
    
    methods 
        function initializeSuperProps(obj,old_data,new_cell_locations)
           %This method should be called by request handler to initialize
           %the properties that this class holds ...
           %
           %    NOTE: We might add a hook to allow initialization of the
           %    subclasses after this ...
           %
           %    See Also:
           %    NEURON.xstim.single_AP_sim.request_handler

           
           
           %TODO: This method is not yet implemented ....
           %
           %    UNFINISHED UNFINISHED 
           
           obj.new_data = NEURON.xstim.single_AP_sim.new_solution();
           
           
           
        end
    end
    
    %Methods for subclasses to implement ==================================
    methods (Abstract)
        [solution,predictor_info] = getThresholdSolutions(obj) 
    end
    
    methods
        function initializeSubclassProps(obj) %#ok<MANU>
            %Do nothing
            %The subclass can reimplement this ...
        end
    end
    
    %Methods for subclasses to use ========================================
    methods 
        function createFinalSolution(obj)
           %This will do the work of creating the final solution from
           %new_data and old_data ...
           
           
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

