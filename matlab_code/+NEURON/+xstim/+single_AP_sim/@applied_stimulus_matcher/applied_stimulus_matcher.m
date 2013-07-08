classdef applied_stimulus_matcher < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    %
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) We could eventually allow loose matching of stimuli based 
    %   on some distance metric ...
    %
    %
    
    
    
    properties
       p %Reference to predictor object
       %
       %   Needs access to:
       %   1) new solution data
       %   2) old stimuli
       %   3) new stimuli
    end
    
    %Properties for later application ...
    properties
       redundant_indices  %Indices of the new data which are deemed to be
       %the same as other indics of the new data ...
       source_indices     %Indices whose solutions match the redundant indices
       %
       %    i.e. threshold(source_indices(#)) = threshold(redundant_indices(#))
    end
    
    methods
        function obj = applied_stimulus_matcher(p_obj)
           obj.p = p_obj; 
        end

        function applyStimulusMatches(obj)
           %
           %
           %    Pipeline:
           %    ===================================================
           %    1) this class determines matches, registers function
           %    handle with the new_data object
           %    2) on finishing, the new_data object calls this registered
           %    function ...
           
           n = obj.p.new_data;
           if isempty(obj.redundant_indices)
               error('This method should not be called when there are not redundant indices') 
           end
           
           n.copySolutions(obj.source_indices,obj.redundant_indices);
        end
    end
    
end

