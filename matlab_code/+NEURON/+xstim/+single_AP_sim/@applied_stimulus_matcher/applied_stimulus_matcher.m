classdef applied_stimulus_matcher < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    %
    %   This class is responsible for determining solutions that are
    %   identifical based on having the same applied stimulus. It also
    %   is responsible for determining what "the same" is.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) We could eventually allow loose matching of stimuli based 
    %   on some distance metric ...
    %   2) We might want to more clearly expose what interface this class 
    %   has that is used by the applied_stimulus_manager
    %
    %
    %   MAIN METHODS 
    %   ===================================================================
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.getStimulusMatches
    
    properties
       stim_manager
    end
    
    %Properties for later application ...
    properties
       %.getStimulusMatches()
       match_info_computed = false
       
       unique_old_indices
       
       redundant_new_indices__with_old_source
       old_index_sources
       
       redundant_new_indices__with_new_source  %Indices of the new data 
       %which are deemed to be the same as other indics of the new data ...
       new_index_sources     %Indices whose solutions match the redundant indices
       
       %.applyStimulusMatchInfo()
       
    end
    
    methods
        function obj = applied_stimulus_matcher(stim_man_obj)
           obj.stim_manager = stim_man_obj;
        end
        function applyStimulusMatchesCallback(obj)
           %
           %
           %    Pipeline:
           %    ===================================================
           %    1) this class determines matches, registers function
           %    handle with the new_data object
           %    2) on finishing, the new_data object calls this registered
           %    function ...
           
           n = obj.stim_manager.new_data;
           if isempty(obj.redundant_new_indices__with_new_source)
               error('This method should not be called when there are not redundant indices') 
           end
           
           n.copySolutions(obj.new_index_sources,obj.redundant_new_indices__with_new_source);
        end
    end
    
    %Public Methods =======================================================
    methods
        function applyStimulusMatchInfo(obj)
            if ~obj.match_info_computed
               obj.getStimulusMatches();
            end
            
            if ~isempty(obj.redundant_new_indices__with_old_source)
                obj.stim_manager.setSameAsOld(...
                        obj.redundant_new_indices__with_old_source,...
                        obj.old_index_sources);
            end
            
            if ~isempty(obj.redundant_new_indices__with_old_source)
                new_solution = obj.stim_manager.new_data;
                new_solution.addWillSolveLaterIndices(...
                        obj.redundant_new_indices__with_old_source,...
                        @obj.applyStimulusMatchesCallback);
            end
        end
    end
    
end

