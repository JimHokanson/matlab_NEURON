classdef solver < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.solver
    %
    %   This in general will be an abstract class with some helper
    %   methods that other classes can use. This class is responsible for
    %   returning "solved" thresholds for a set of cell locations given a
    %   particular extracellular stimulus configuration.
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.request_handler
    %   NEURON.xstim.single_AP_sim.solver.default
    %   NEURON.xstim.single_AP_sim.predictor_info
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %   NEURON.xstim.single_AP_sim.dim_reduction_options
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    %   NEURON.xstim.single_AP_sim.grouper.initialize
    %   NEURON.xstim.single_AP_sim.binary_search_adjuster
    %   NEURON.xstim.single_AP_sim.threshold_simulation_results
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Make sure that we never assign an invalidly signed stimulus ...
    
    %solver Options
    %-----------------------------------------------------
    
    %Set via .setSystemTester()
    properties (SetAccess = private)
       system_testing = false %Indicates that we are just testing the system
       %performance. Currently this class uses this flag
       %to do a switch on the method:
       %.getThresholdsFromSimulation()
       %
       system_tester  = [] %Object referece to type:
       %    NEURON.xstim.single_AP_sim.system_tester
       %
       %    When .system_testing is true.
    end
    
    %Properties for subclass to use =======================================
    properties
        stim_sign    %Sign to solve for, we need to ensure that we never
        %predict values that are not the correct sign
        logged_data  %NEURON.xstim.single_AP_sim.logged_data
        old_data     %NEURON.xstim.single_AP_sim.solution
        new_data     %NEURON.xstim.single_AP_sim.new_solution
    end
    
    properties
        xstim        %NEURON.simulation.extracellular_stim
        stimulus_manager %NEURON.xstim.single_AP_sim.applied_stimulus_manager
        
        grouper %NEURON.xstim.single_AP_sim.grouper.initialize
        binary_search_adjuster   %NEURON.xstim.single_AP_sim.binary_search_adjuster
        predicter %NEURON.xstim.single_AP_sim.predicter
    end
    
    properties (Dependent)
        all_done    %References the new_data object ...
        dim_reduction_options %NEURON.xstim.single_AP_sim.dim_reduction_options
    end
    
    %Dependent Methods ====================================================
    methods
        function value = get.all_done(obj)
            value = obj.new_data.all_done;
        end
        function value = get.dim_reduction_options(obj)
            value = obj.stimulus_manager.dim_reduction_options;
        end
    end
    
    %Object Construction ==================================================
    methods (Static)
        function s = create(solver_type,xstim_obj)
            %
            %
            %   s = create(solver_type)
            
            switch lower(solver_type)
                case 'default'
                    s = NEURON.xstim.single_AP_sim.solver.default;
                case 'from_old_solver'
                    s = NEURON.xstim.single_AP_sim.solver.from_old_solver;
                otherwise
                    error('Solver type not recognized')
            end
            
            s.xstim = xstim_obj;
            
            s.stimulus_manager = NEURON.xstim.single_AP_sim.applied_stimulus_manager(s);
            s.predicter        = NEURON.xstim.single_AP_sim.predicter(s);
            %s.predicter        = NEURON.xstim.single_AP_sim.gridPredictor(s);
            s.grouper          = NEURON.xstim.single_AP_sim.grouper(s);
            s.binary_search_adjuster   = NEURON.xstim.single_AP_sim.binary_search_adjuster(s);
        end
    end
    
    methods
        function initializeSuperProps(obj,logged_data,new_data,stim_sign)
            %This method should be called by request handler to initialize
            %the properties that this class holds ...
            %
            %    NOTE: We might add a hook to allow initialization of the
            %    subclasses after this. Currently the request handler
            %   makes that call ...
            %
            %   INPUTS
            %   ===========================================================
            %   logged_data : NEURON.xstim.single_AP_sim.logged_data
            %   new_data    : NEURON.xstim.single_AP_sim.new_solution
            %
            %
            %    See Also:
            %    NEURON.xstim.single_AP_sim.request_handler
            
            obj.stim_sign   = stim_sign;
            obj.logged_data = logged_data;
            obj.old_data    = obj.logged_data.solution;
            obj.new_data    = new_data;
            
            %NEURON.xstim.single_AP_sim.applied_stimulus_manager
            obj.stimulus_manager.initialize(obj.xstim,new_data,obj.old_data)
            obj.grouper.reset();
            obj.predicter.reset();
        end
        function setSystemTester(obj,system_tester)
           obj.system_testing = true;
           obj.system_tester  = system_tester;
           obj.new_data.system_testing = true;
        end
        function predictor_info = getThresholdSolutions(obj)
            %
            %
            %   predictor_info = getThresholdSolutions(obj)
            %
            %      **********   MAIN SOLVING METHOD   *************
            %   
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
            %
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.getStimulusMatches
            %
            %   FULL PATH:
            %   NEURON.xstim.single_AP_sim.solver.setSameAsOld
            
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
            
            new.updateSolutions(new_indices,thresholds,types,ranges,false);
        end
        function addSolutionResults(obj,new_indices,thresholds,type,ranges)
            %I want this method to be what predictors can call when they
            %learn new results ...
            %
            %    This will handle the interface to the saving objects
            %    for logging the results ...
            %
            %   FULL PATH:
            %   NEURON.xstim.single_AP_sim.solver.addSolutionResults
            
            new = obj.new_data;
            
            %Call to: NEURON.xstim.single_AP_sim.new_solution.updateSolutions
            new.updateSolutions(new_indices,thresholds,type,ranges,true);
        end
    end
    
end

