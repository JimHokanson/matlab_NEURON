classdef binary_search_adjuster < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.binary_search_adjuster
    %
    %   The goal of this class is to support adjusting the binary
    %   search resolution based on performance of the predictor.
    %
    %   NOTE: A class or method switch could be used to ask the predictor
    %   to do the adjustment ...
    
    properties
       p %Reference to predictor object
    end
    
    methods
        function obj = binary_search_adjuster(p_obj)
           obj.p = p_obj;
        end
        function adjustSearchParameters(obj,threshold_results_obj)
            
        end
    end
    
end

