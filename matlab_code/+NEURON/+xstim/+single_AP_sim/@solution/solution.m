classdef  solution < sl.obj.handle_light
    %
    %   Class:
    %   xstim.single_AP_sim.solution
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
        solve_dates       %NYI
        predictor_types  %[1 x n]
        ranges           %[n x 2]
    end
    
    properties
        hash = 0 %Update this when the object changes ...
    end
    
    methods
        function obj = solution(previous_struct)
            
            if isempty(previous_struct)
                return
            else
                s = previous_struct;
                if s.VERSION ~= obj.VERSION
                    error('Write some update code')
                end
                sl.struct.toObject(obj,s);
            end
            
        end
        function new_obj = getPartialObject(obj,I)
            %new_obj
            
            new_obj = xstim.single_AP_sim.solution([]);
            
            %TODO: Implement this function!
            
            new_obj.cell_locations   = obj.stim_sign(I,:);
            new_obj.thresholds       = obj.
            new_obj.solve_dates       = obj.
            new_obj.predictor_types  %[1 x n]
            new_obj.ranges           %[n x 2]
            
            
            new_obj.hash = now;
            
        end
        function s = getStruct(obj)
            s = sl.obj.toStruct(obj);
        end
        function addToEntry(obj,solve_dates,new_locations,new_thresholds,predictor_types,ranges)
            %
            %   Implementation Notes
            %   ----------------------------------------------
            %   1) We might provide a single predictor type instead of many
            %   and then just replicate inside this function ...
            %
            %   See Also:
            %   
            
            obj.solve_dates     = [obj.solve_dates      solve_dates];
            obj.cell_locations  = [obj.cell_locations;  new_locations];
            obj.thresholds      = [obj.thresholds       new_thresholds];
            obj.predictor_types = [obj.predictor_types  predictor_types];
            obj.ranges          = [obj.ranges;          ranges];
            obj.hash = now;
        end
        function match_result = findLocationMatches(obj,new_cell_locations)
            %
            %
            %   match_result = findLocationMatches(obj,new_cell_locations)
            %
            %   OUTPUTS
            %   ===================================================
            %   match_result : Class : NEURON.xstim.single_AP_sim.solution.match_result 
            %
            %   INPUTS
            %   ===================================================
            %
            %
            %   See Also:
            %   
           
            
            
            
            [mask,loc] = ismember(new_cell_locations,obj.cell_locations);
            
            match_result = NEURON.xstim.single_AP_sim.solution.match_result(obj,mask,loc,new_cell_locations(~mask));
            
            
        end
    end
    
end

