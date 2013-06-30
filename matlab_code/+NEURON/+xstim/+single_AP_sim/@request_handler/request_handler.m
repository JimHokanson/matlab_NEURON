classdef request_handler
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.request_handler
    %
    %   This is responsbile for keeping track of what we know and don't
    %   know.
    
    properties
        parent  %Class: NEURON.xstim
        sim_id  %
        
        logged_data %Class: NEURON.xstim.single_AP_sim.logged_data
    end
    
    properties
        requested_locations
        current_unknown_indices
        
        final_thresholds
        options
    end
    
    methods
        function obj = request_handler(parent,sign,cell_locations)
            % get previously logged data
            % we may or may not want to repopulate our known locations just
            % yet...
            obj.parent   = parent;
            
            xstim_logger = parent.getLogger;
            
            %
            ID = xstim_logger.getInstanceID();
            
            keyboard
            
            %obj.logged_data = NEURON.xstim.single_AP_sim.logged_data(parent,sign);
            
            %NEURON.xstim.single_AP_sim.logged_data
            %obj.logged_data = NEURON.single_AP_sim.logged_data(parent, sign); 
            
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

