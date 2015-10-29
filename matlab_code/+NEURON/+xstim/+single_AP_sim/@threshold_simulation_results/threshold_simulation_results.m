classdef threshold_simulation_results < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.threshold_simulation_results
    %
    
    
    properties (Constant)
        
    end
    
    %INPUTS ===============================================================
    properties
       d1 = '----  Inputs  ----'
       s        %SC: NEURON.xstim.single_AP_sim.solver
       indices  %Indices into new data that we solved for ...
       predicted_thresholds
    end
    
    %OUTPUTS ==============================================================
    properties
       d2 = '----  Outputs  ----' 
       actual_thresholds
       n_loops
       ranges %[n x 2]
    end
    
    properties (Dependent)
       n
       threshold_prediction_error
       avg_error
    end
    
    
    methods 
        function set.predicted_thresholds(obj,value)
           if size(value,1) > 1
               value = value';
           end
           obj.predicted_thresholds = value;
        end
        function value = get.n(obj)
           value = length(obj.indices); 
        end
        function value = get.threshold_prediction_error(obj)
           value = obj.actual_thresholds - obj.predicted_thresholds;
        end
        function value = get.avg_error(obj)
           value = mean(abs(obj.threshold_prediction_error));
        end
    end
    
    %This can be for merged objects to keep track of progression
    %with different prediction loops
    properties
       d3 = '----  For Merged Objects Only  ----'
       run_index
       index_count = 0
    end
    
    methods
        function obj = threshold_simulation_results(s_obj)
           obj.s = s_obj;
        end
        function logResults(obj)
           % 
           %  logResults(obj)
           
           %Call to: NEURON.xstim.single_AP_sim.solver.addSolutionResults
           obj.s.addSolutionResults(obj.indices,obj.actual_thresholds,1,obj.ranges);
        end
        function mergeObjects(obj1,obj2)
           %This method might be useful for testing and learning
           %about how we performed with different algorithms ...
           
           obj1.indices              = [obj1.indices                obj2.indices];
           obj1.predicted_thresholds = [obj1.predicted_thresholds   obj2.predicted_thresholds];
           obj1.actual_thresholds    = [obj1.actual_thresholds      obj2.actual_thresholds];
           obj1.n_loops              = [obj1.n_loops                obj2.n_loops];
           obj1.ranges               = [obj1.ranges;                obj2.ranges];
           if obj1.run_index 
              obj1.run_index = ones(1,obj1.n);
              obj1.index_count = 1;
           end
           
           obj1.index_count = obj1.index_count + 1;
           obj1.run_index   = [obj1.run_index       obj1.index_count*ones(1,obj2.n)];
           
        end
    end
    
end

