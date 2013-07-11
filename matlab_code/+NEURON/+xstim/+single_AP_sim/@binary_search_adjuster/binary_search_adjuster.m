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
        threshold_options %NEURON.simulation.extracellular_stim.threshold_options
    end
    
    methods
        function obj = binary_search_adjuster(p_obj)
            obj.p = p_obj;
            
            %TODO: Eventually we should make a copy of this options
            %class so that we aren't mucking with the users options ...
            %This is low priority
            obj.threshold_options = p_obj.xstim.threshold_options_obj;
        end
        function adjustSearchParameters(obj,threshold_results_obj)
            %
            %
            %    INPUTS
            %    ===========================================================
            %    threshold_results_obj: This object is created by the
            %           local solver when running simulations to compute
            %           thresholds.
            %       Class:NEURON.xstim.single_AP_sim.threshold_simulation_results
            %
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.predictor.threshold_simulation_results
            
            
            
            
        end
    end
    
end

