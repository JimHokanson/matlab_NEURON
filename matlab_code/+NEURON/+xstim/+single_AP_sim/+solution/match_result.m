classdef match_result < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.solution.match_result
    %
    %   See Also:
    %   xstim.single_AP_sim.solution
    
    properties
       unmatched_locations
       solution %xstim.single_AP_sim.solution
       mask
       loc
       is_complete_match
    end
    
    properties
       hash
    end
    
    methods
        function obj = match_result(sol_obj,mask,loc,unmatched_locations)
           obj.solution = sol_obj;
           obj.mask     = mask;
           obj.is_complete_match = all(mask);
           obj.loc      = loc;
           obj.unmatched_locations = unmatched_locations;
           obj.hash     = sol_obj.hash; %Record now in case it changes ...
        end
        function new_solution = getFullSolution(obj)
        %
        %
        %   NOTE: Only allow this for a full match
            
            %1) Check that hash is the same
            %2) 
            if obj.hash ~= obj.solution.hash
                error('Solution object has changed')
            end
            
            new_solution = obj.solution.getPartialObject(obj.loc);
            
        end
    end
    
end

