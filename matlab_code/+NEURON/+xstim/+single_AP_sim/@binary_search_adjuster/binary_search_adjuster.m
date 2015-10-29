classdef binary_search_adjuster < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.binary_search_adjuster
    %
    %   The goal of this class is to support adjusting the binary
    %   search resolution based on performance of the predictor.
    %
    %   NOTE: A class or method switch could be used to ask the predictor
    %   to do the adjustment ...
    %
    %
    %   Known in parent AS:
    %       binary_search_adjuster   
    %
    %   See Also:
    %   
    
    properties
        s %Reference to predictor object
        threshold_options %NEURON.simulation.extracellular_stim.threshold_options
    end
    
    methods
        function obj = binary_search_adjuster(s_obj)
            obj.s = s_obj;
            
            %TODO: Eventually we should make a copy of this options
            %class so that we aren't mucking with the users options ...
            %This is low priority
            obj.threshold_options = s_obj.xstim.threshold_options_obj;
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
            
            %NOTE: It is likely this function could be improved ...
            
%           result_obj
%                             d1: '----  Inputs  ----'
%                              s: [1x1 NEURON.xstim.single_AP_sim.solver.default]
%                        indices: [1x25 double]
%           predicted_thresholds: [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
%                             d2: '----  Outputs  ----'
%              actual_thresholds: [1x25 double]
%                        n_loops: [6 16 6 7 8 7 10 7 7 7 12 8 7 8 8 14 12 10 7 16 12 12 8 8 8]
%                         ranges: [25x2 double]
%     threshold_prediction_error: [1x25 double]
%                             d3: '----  For Merged Objects Only  ----'
%                      run_index: []
            
            
            threshold_errors = threshold_results_obj.threshold_prediction_error;
            avg_error = mean(abs(threshold_errors));
            
            %Might change the approach to this ...
            obj.threshold_options.changeGuessAmount(2*avg_error);
        end
    end
    
end

