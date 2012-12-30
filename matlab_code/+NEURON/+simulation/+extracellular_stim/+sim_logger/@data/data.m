classdef data < handle_light
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.data
    %
    
    %DATA FILE FORMAT
    %======================================================================
    %1) Applied Stimulus
    %
    %
    %   rows are observations, columns are data points on cell, data points
    %   from different times are concatenated after all points on the cell
    %   from a single time
    %   [point1_time1 point2_time1 point3_time1 point1_time2 point2_time2 etc]
    %
    %
    %
    %2) Relevant Stimulus Setup - This would let us know which type of stimuli
    %caused the applied stimulus observed, as differences in electrode setup
    %and magnitude are not something that differenties different groupings
    %of data, only stimulus durations and properties of the cell
    %3) Estimated critical transmembrane voltage? - i.e. at what voltage is
    %an action potential initiated. This could be useful in estimating
    %new data
    %
    %4) # of points per cell - indicates divisions that are time based
    %
    %5) Date of creating data
    
    
    properties
        xstim_obj
        data_path
    end
    
    properties
        simulation_number
        current_index           = 0
        applied_stimulus_matrix = []
        creation_time           = []
        n_points_per_cell       = []
        stimulus_setup_id       = []
        %Stimulus Setup :/ Blah!
        
        stimulus_setup_objs
        
        current_stimulus_setup_id = []
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    %INITIALIZATION =======================================================
    methods
        function obj = data(xstim_obj,simulation_number,data_path)
            %
            %   TODO: Clean up and document
            %
            
            obj.simulation_number = simulation_number;
            obj.xstim_obj = xstim_obj;
            obj.data_path = data_path;
            
            if exist(data_path,'file')
                h = load(data_path);
                if h.VERSION ~= obj.VERSION
                    error('Unhandled version mismatch')
                end
                obj.current_index           = h.current_index;
                obj.applied_stimulus_matrix = h.applied_stimulus_matrix;
                obj.creation_time           = h.creation_time;
                obj.n_points_per_cell       = h.n_points_per_cell;
                obj.stimulus_setup_id       = h.stimulus_setup_id;
                obj.stimulus_setup_objs     = h.stimulus_setup_objs;
            end
            
            stimulus_setup_obj = NEURON.simulation.extracellular_stim.sim_logger.stimulus_setup(xstim_obj);
            
            index = find(stimulus_setup_obj == obj.stimulus_setup_objs);
            
            if length(index) > 1
                error('Expecting singular or empty match')
            end
            
            if isempty(index)
                if isobject(obj.stimulus_setup_objs)
                    obj.stimulus_setup_objs(end+1) = stimulus_setup_obj;
                else
                    obj.stimulus_setup_objs = stimulus_setup_obj;
                end
                obj.current_stimulus_setup_id = length(obj.stimulus_setup_objs);
            else
                obj.current_stimulus_setup_id = index;
            end
        end
    end
    
    %ADDING DATA ==========================================================
    methods

    end
end

