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
       p        %Subclass of: NEURON.xstim.single_AP_sim.predictor
       indices
       predicted_thresholds
    end
    
    %OUTPUTS ==============================================================
    properties
       d2 = '---- OUTPUTS -----' 
       actual_thresholds
       n_loops
       ranges %[n x 2]
    end
    
    %This can be for merged objects to keep track of progression
    %with different prediction loops
    properties
       run_index 
    end
    
    methods
        function obj = threshold_simulation_results(p_obj)
           obj.p = p_obj;
        end
        function logResults(obj)
            
        end
% %         function mergeObjects(obj1,obj2)
% %            %This method might be useful for testing and learning
% %            %about how we performed with different algorithms ...
% %         end
    end
    
end

