classdef xstim
    
    properties
        request_handler_obj
        logged_data_obj
        predictor_obj
    end
    
    methods
        function thresholds = sim__getThresholdsMultipleLocations(obj, sign, cell_locations)
            % basic steps: 
            % 1 - initialize the request_handler 
            % Which then goes and inits the logged_Data (pass in the sign)
            % call: request_handler.getThresholds
            % 2 - has request_handler return indices of unknown
            %     cell_locations
            % 3 - sends these reduced (potentially) cell_locations to the 
            %     predictor_obj. Along with the sign. predictor_obj
            % 4 - predictor_obj sees if the matrix is emmpty and returns
            %     early.
            % 4 - OR predictor interacts w/ request_handler to manage data?
            
            % Step 2-4 not done here directly, but thru request_handler_obj
        end
    end
end