classdef logged_data
% This class is in charge of saveing/loading each data instance and
% maintaining which predictor is being used to generate this information
% especially useful for testing, we are going to want to insure that the
% different predictor methods do not generate different outcomes.
    
    properties
        cell_locations
        pos_threshold
        neg_threshold
        sign
    end
    
    properties
        predictor
    end
    
    methods
        function obj = logged_data(cell_locations, sign)
            % populates properties 
        end
        function [sign, cell_locations] = load_CellLocations(obj)
            %I'm not exactly sure what form the output should take, but
            %this would return the cell_locations of previously run trials
            %as well as the sign they were run with
            % opens from path and reformats 
        end
        function save_CellLocations()
            %called by request_handler thru predictor_obj?
            % saves at right path
        end
        function get_savePath()
            % may or may not actually be necessary here...
        end
        function stim = getStimulus(cell_locations, sign)
            % option A: sends command to get stored stimulus vector. 
            % option B: sends command to obtain old cell_locations and then
            %   regenerates their respective stimuli (as well as the new)
            % This method would need to send its data to the predictor
            % model.
        end
    end

end