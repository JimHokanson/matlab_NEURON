classdef  solution < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_sim.solution
    %
    %   See Also
    %   --------
    %   NEURON.simulation.extracellular_stim.results.single_sim
    %   NEURON.xstim.single_sim.request_handler
    %   NEURON.xstim.single_sim.logged_data
    
    properties (Constant)
        VERSION = 1
    end
    
    properties
        cell_locations  %[n x 3]
        tested_scales   %[1 x n]
        success  	%[1 x n]
        tissue_fried    %[1 x n]
        initial_stim_time   %[1 x n]
        final_stim_time     %[1 x n]
        membrane_potential  %{1 x n}
        ap_propagated   %[1 x n]
        solve_dates 	%[1 x n]
    end
    
    properties
        hash = 0 %Update this when the object changes ...
    end
    
    methods
        function obj = solution(previous_struct)
            %
            %
            %   obj = solution(previous_struct)
            %
            %   This may be called from the logged_data class if the
            %   logged_data class is reloading it from disk.
            %
            %   See Also
            %   NEURON.xstim.single_sim.logged_data
            
            if isempty(previous_struct)
                return
            else
                s = previous_struct;
                if s.VERSION ~= obj.VERSION
                    error('Write some update code')
                end
                NEURON.sl.struct.toObject(obj,s);
            end
        end
        function new_obj = getPartialObject(obj,I)
            %
            %
            %   new_obj = getPartialObject(obj,I)
            %
            %   Inputs
            %   ------
            %
            
            new_obj = NEURON.xstim.single_sim.solution([]);
            
            new_obj.cell_locations = obj.cell_locations(I,:);
            new_obj.tested_scales = obj.tested_scales(I);
            new_obj.success = obj.success(I);
            new_obj.tissue_fried = obj.tissue_fried(I);
            new_obj.initial_stim_time = obj.initial_stim_time(I);
            new_obj.final_stim_time = obj.final_stim_time(I);
            new_obj.membrane_potential = obj.membrane_potential(I);
            new_obj.ap_propagated  = obj.ap_propagated(I);
            new_obj.solve_dates = obj.solve_dates(I);
            new_obj.hash = now;
        end
        function appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
            %
            %
            %    appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
            %
            %    Outputs
            %    -------
            %    appplied_stim_obj : NEURON.xstim.single_AP_sim.applied_stimuli
            appplied_stim_obj = NEURON.xstim.single_AP_sim.applied_stimuli(xstim_obj,obj.cell_locations);
        end
        function s = getStruct(obj)
            s = NEURON.sl.obj.toStruct(obj);
        end
        function addToEntry(obj,new_data)
            %
            %
            %   addToEntry(obj,solve_dates,new_locations,new_thresholds,predictor_types,ranges)
            %
            %   Implementation Notes
            %   -----------------------------------------------------------
            %   1) We might provide a single predictor type instead of many
            %   and then just replicate inside this function ...
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.solution.addToEntry
                        
            nd = new_data;
            
            m = nd.solved;
            
            obj.solve_dates     = [obj.solve_dates      nd.solve_dates(m)];
            obj.cell_locations  = [obj.cell_locations;  nd.cell_locations(m,:)];
            obj.tested_scales = [obj.tested_scales nd.tested_scales(m)];
            obj.success = [obj.success nd.success(m)];
            obj.tissue_fried = [obj.tissue_fried nd.tissue_fried(m)];
            obj.initial_stim_time = [obj.initial_stim_time nd.initial_stim_time(m)];
            obj.final_stim_time = [obj.final_stim_time nd.final_stim_time(m)];
            obj.membrane_potential = [obj.membrane_potential nd.membrane_potential(m)];
            obj.ap_propagated = [obj.ap_propagated nd.ap_propagated(m)];
            obj.solve_dates = [obj.solve_dates nd.solve_dates(m)];
            
            obj.hash = now;
        end
        function match_result = findMatches(obj,cell_locations,scales)
            %findLocationMatches
            %
            %   match_result = findMatches(obj,new_cell_locations)
            %
            %   Outputs
            %   -------
            %   match_result : NEURON.xstim.single_sim.solution.match_result
            %
            %   Inputs
            %   ------
            %   cell_locations :
            %   scales : 
            %
            %   See Also
            %   --------
            %   NEURON.xstim.single_sim.solution.match_result
            
            m_old = [cell_locations scales(:)];
            m_new = [obj.cell_locations obj.tested_scales(:)];
            
            if ~isempty(obj.cell_locations)
                [mask,loc] = ismember(m_old,m_new,'rows');
            else
                n_rows = size(cell_locations,1);
                mask = false(n_rows,1);
                loc  = zeros(n_rows,1);
            end
            %Inputs
            match_result = NEURON.xstim.single_sim.solution.match_result(...
                obj,...
                mask,...
                loc,...
                cell_locations(~mask,:),...
                scales(~mask));
        end
        function flag = issorted(obj)
            flag = issorted(obj.cell_locations,'rows');
        end
    end
    
    methods
        function sorted_obj = getSortedObject(obj)
            %getSortedObject
            %
            %    sorted_obj = getSortedObject(obj)
            %
            %    NOTE: This should be used with caution because it
            %    creates a new object. This was written for a static
            %    method in logged_data
            
            [~,I] = sortrows(obj.cell_locations);
            sorted_obj = obj.getPartialObject(I);
        end
    end
    
end

