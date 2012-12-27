classdef threshold_testing_history < handle_light
    %threshold_testing_history
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.results.threshold_testing_history
    
    properties
        n_loops        = 0
        success
        threshold_value
        
        tested_stimuli = zeros(1,20) %
        ap_propogated  = false(1,20) %(logical array)
    end
    
    methods
        function obj = threshold_testing_history()
        
        end
        function logResult(obj,tested_value,ap_fired)
           n_local = obj.n_loops + 1;
           
           obj.tested_stimuli(n_local) = tested_value;
           obj.ap_propogated(n_local)  = ap_fired;
           
           obj.n_loops = n_local;
        end
        function finalizeData(obj,threshold_value)
           obj.tested_stimuli(obj.n_loops+1:end) = [];
           obj.ap_propogated(obj.n_loops+1:end)  = [];
           obj.threshold_value = threshold_value; 
        end
        function str = getSummaryString(obj)
            str = sprintf('SIMULATION FINISHED: THRESHOLD = %0g, n_loops = %d',...
                obj.threshold_value,obj.n_loops); 
        end
    end
    
end

