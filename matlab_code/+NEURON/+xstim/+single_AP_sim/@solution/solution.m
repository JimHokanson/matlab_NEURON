classdef  solution < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.solution
    %
    %   IMPROVEMENTS
    %   =======================================
    %   1) DONE Create from previous structure
    %   2) Allow copying of a subset based on indices ...
    %           see method: getPartialObject
    %   3) Allow optimization - some function that goes through and
    %      sorts the data then saves it again
    
    properties (Constant)
        VERSION = 1
    end
    
    properties
        cell_locations   %[n x 3]
        thresholds       %[1 x n]
        solve_dates      %[1 x n]
        predictor_types  %[1 x n]
        ranges           %[n x 2]
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
            
            new_obj = NEURON.xstim.single_AP_sim.solution([]);
            
            new_obj.cell_locations   = obj.cell_locations(I,:);
            new_obj.thresholds       = obj.thresholds(I);
            new_obj.solve_dates      = obj.solve_dates(I);
            new_obj.predictor_types  = obj.predictor_types(I);
            new_obj.ranges           = obj.ranges(I,:);
            new_obj.hash             = now;  
        end
        function appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
           %
           %
           %    appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
           %    
           %    OUTPUTS
           %    ===========================================================
           %    appplied_stim_obj : Class: NEURON.xstim.single_AP_sim.applied_stimuli
           appplied_stim_obj = NEURON.xstim.single_AP_sim.applied_stimuli(xstim_obj,obj.cell_locations); 
        end
        function s = getStruct(obj)
            s = NEURON.sl.obj.toStruct(obj);
        end
        function addToEntry(obj,solve_dates,new_locations,new_thresholds,predictor_types,ranges)
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
            
            obj.solve_dates     = [obj.solve_dates      solve_dates];
            obj.cell_locations  = [obj.cell_locations;  new_locations];
            obj.thresholds      = [obj.thresholds       new_thresholds];
            obj.predictor_types = [obj.predictor_types  predictor_types];
            obj.ranges          = [obj.ranges;          ranges];
            obj.hash = now;
        end
        function match_result = findLocationMatches(obj,new_cell_locations)
            %findLocationMatches
            %
            %   match_result = findLocationMatches(obj,new_cell_locations)
            %
            %   OUTPUTS
            %   ===========================================================
            %   match_result: NEURON.xstim.single_AP_sim.solution.match_result
            %
            %   INPUTS
            %   ===========================================================
            %   new_cell_locations : 
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.solution.match_result
            
            if ~isempty(obj.cell_locations)
                [mask,loc] = ismember(new_cell_locations,obj.cell_locations,'rows');
            else
                n_rows = size(new_cell_locations,1);
                mask = false(n_rows,1);
                loc  = zeros(n_rows,1);
            end
            match_result = NEURON.xstim.single_AP_sim.solution.match_result(obj,mask,loc,new_cell_locations(~mask,:));
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

