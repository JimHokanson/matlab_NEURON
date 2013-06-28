classdef request_handler
    % This is responsbile for keeping track of what we know and don't
    %   know.
    properties
        parent          %NEURON.xstim
        logged_data % I'm not exactly sure if we want this to
        % instaiante and handle this or not...
    end
    properties
        requested_locations
        current_unknown_indices
        
        final_thresholds
        options
    end
    methods
        function obj = request_handler(parent, sign)
            % get previously logged data
            % we may or may not want to repopulate our known locations just
            % yet...
            obj.parent = parent;
            obj.logged_data = NEURON.single_AP_sim.logged_data(parent, sign); 
            
        end        
        function [unknown, index] = determine_unknown_indices(obj, cell_locations)
            % call: logged_data function to get old data
            % from the values its got and the requested locations, it
            % determines which indices into the requested_locations have
            % already been solved.           
            if isempty(obj.logged_data.cell_locations_old)
                obj.logged_data.load_data();
            end
            old_locations = obj.logged_data.cell_locations_old;
            [match, index] = ismember(cell_locations, old_locations, 'rows');
            unknown = find(~match);
        end        
        function thresholds = getThresholds(obj, cell_locations, predictor)            
            %cell_locations passed in as a cell array needs reformatting...
            [unknown, known_indices] = obj.determine_unknown_indices(obj, cell_locations);
            if isempty(unknown)
                thresholds = sign.*obj.logged_data.old_thresolds(known_indices);
                return
            end
            solver(predictor, obj); %I don't want this to be created 
            % until we know we need it. might have to pass in predictor 
            % type from xstim, and then actully generate the predictor 
            % object here
            thresholds = solver.predictThresholds(known_indices, sign, ...
                                                  cell_locations);
        end     
    end
end

