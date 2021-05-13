classdef match_result < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_sim.solution.match_result
    %
    %   See Also
    %   --------
    %   xstim.single_sim.solution
    %   xstim.single_sim.solution.findMatches
    
    properties
       unmatched_locations %[n x 3]
       unmatched_scales %[n]
       solution %xstim.single_sim.solution
    end
    
    properties
       mask
       loc      % 
       
       is_complete_match
    end
    
    properties
       hash
    end
    
    methods
        function obj = match_result(sol_obj,mask,loc,unmatched_locations,unmatched_scales)
           %
           %
           %    obj = match_result(sol_obj,mask,loc,unmatched_locations)
           %
           %    This constructor is called from:
           %    NEURON.xstim.single_sim.solution.findMatches
           %
           %
           %
           %    See Also:
           %    NEURON.xstim.single_sim.solution.findMatches
           
           obj.solution = sol_obj;
           obj.mask = mask;
           obj.is_complete_match = all(mask);
           obj.loc = loc;
           obj.unmatched_locations = unmatched_locations;
           obj.unmatched_scales = unmatched_scales;
           obj.hash = sol_obj.hash; %Record now in case it changes ...
        end
        function new_solution = getFullSolution(obj)
        %
        %   new_solution = getFullSolution(obj)
        %   
        %   Outputs
        %   -------
        %   new_solution : Class: NEURON.xstim.single_AP_sim.solution
                    
            if ~obj.is_complete_match
               error('Operation not allowed for partial matches') 
            end
            
            if obj.hash ~= obj.solution.hash
                error('Solution object has changed')
            end
            
            indices_retrieve = obj.loc;
            new_solution     = obj.solution.getPartialObject(indices_retrieve);
        end
        function [locs,scales] = getUnmatchedEntries(obj)
           locs = obj.unmatched_locations; 
           scales = obj.unmatched_scales;
        end
    end
    
end

