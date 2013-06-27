classdef request_handler
    % This is responsbile for keeping track of what we know and don't
    %   know.
    properties
        parent          %NEURON.xstim
        logged_data_obj % I'm not exactly sure if we want this to
        % instaiante and handle this or not...
    end
    properties
        requested_locations
        current_unknown_indices
        known_locations
        
        final_thresholds
        options
    end
    methods
        function obj = request_handler()
            % get previously logged data
            % we may or may not want to repopulate our known locations just
            % yet...
            
        end        
        function get_oldStim() %this should be renamed
            %Called by: predictor obj 
            % calls a load function from logged_data to obtain previously
            % run cell_locations
            % call: obj.logged_data_obj.loadCellLocations
            % calculates applied stim for the old data and the new data
            % call: something...
        end
        function unknown = determine_unknown_indices(obj)
            % call: logged_data function to get old data
            
            % from the values its got and the requested locations, it
            % determines which indices into the requested_locations have
            % already been solved. This will have to called from some
            % outside function and just return an empty matrix if it has
            % all the locations known already...
            % also populates the current_unknown_indices??? jk this is
            % handled here (this class) too
        end        
        function thresholds = getThresholds(obj, cell_loctions, predictor)
            % call: determine_unknown_indices and passes the result to the
            % predictor. obj.parent.predictor_obj?
            % The predictor we use will determine how we
            % interact with the data here...
            % predictor calls its getThreshold methods with new values
        end     
    end
end

