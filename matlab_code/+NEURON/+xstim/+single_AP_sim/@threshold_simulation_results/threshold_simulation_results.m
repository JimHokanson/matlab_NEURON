classdef threshold_simulation_results < sl.obj.handle_light
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
% %         function mergeObjects(obj1,obj2)
% %            %This method might be useful for testing and learning
% %            %about how we performed with different algorithms ...
% %         end
    end
    
end

