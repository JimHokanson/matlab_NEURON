classdef data < handle_light
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.data
    %

    %METHODS IN OTHER FILES
    %---------------------------------------------------------------------
    %NEURON.simulation.extracellular_stim.sim_logger.data.addResults
    %NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
    
    
    properties
        xstim_obj
        data_path
    end
    
    properties
        %.data()
        simulation_number
        current_stimulus_setup_id = 0
        stimulus_setup_objs
        
        %.getThresholds()
        n_points_per_cell       = 0
        
        current_index           = 0
        n_entries_allocated     = 0
        
        applied_stimulus_matrix = []
        threshold_values        = []
        xyz_center              = []
        creation_time           = []
        stimulus_setup_id       = []
        
        %Stimulus Setup :/ Blah!
        
        
        
        
    end
    
    properties (Constant)
        VERSION   = 1
        GROW_SIZE = 10000
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
                obj.n_points_per_cell       = h.n_points_per_cell;
                
                obj.current_index           = h.current_index;
                obj.n_entries_allocated     = h.n_entries_allocated;
                
                obj.applied_stimulus_matrix = h.applied_stimulus_matrix;
                obj.threshold_values        = h.threshold_values;
                obj.xyz_center              = h.xyz_center;
                obj.creation_time           = h.creation_time;
                obj.stimulus_setup_id       = h.stimulus_setup_id;
                
                obj.stimulus_setup_objs     = h.stimulus_setup_objs;
            end
            
            %This call gets an instance of the stimulus setup, which is
            %used for knowing what caused each of the applied stimuli
            %Do I also want to save location as well?
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
        function [applied_stimulus,samples_per_time] = getAppliedStimulus(obj,cell_locations,threshold_sign)
            %
            %
            %   OUTPUTS
            %   ===========================================================
            %   applied_stimulus
            
            
            %NEURON.cell.extracellular_stim_capable.getCellXYZMultipleLocations
            xyz_out = obj.xstim_obj.cell_obj.getCellXYZMultipleLocations(cell_locations);
            
            sz = size(xyz_out);
            
            [t_vec,v_all] = obj.xstim_obj.computeStimulus(...
                'remove_zero_stim_option',1,...
                'xyz_use',reshape(xyz_out,[sz(1)*sz(2) sz(3)]));
            
            v_all = v_all';
            
            applied_stimulus = reshape(v_all,[sz(1) sz(2)*size(v_all,2)]);
            
            if threshold_sign < 0
                applied_stimulus = -1.*applied_stimulus;
            end
            
            samples_per_time = size(applied_stimulus,2)/length(t_vec);
        end
        function [is_matched,thresholds] = getPreviousMatches(obj,new_applied_stimuli,threshold_sign)
            %How to do equivalency testing?????
            %For right now we'll do exact equivalency ...
            
            n_new = size(new_applied_stimuli,1);
            
            [is_matched,matched_location] = ismember(new_applied_stimuli,obj.applied_stimulus_matrix(:,1:obj.current_index),'rows');
            thresholds = NaN(1,n_new);
            thresholds(is_matched) = threshold_sign.*obj.threshold_values(matched_location(is_matched));
        end
        
    end
end

