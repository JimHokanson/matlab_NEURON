classdef applied_stimulus_matcher < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    %
    %   This class is responsible for determining solutions that are
    %   identifical based on having the same applied stimulus. It also
    %   is responsible for determining what "the same" is.
    %
    %   This class should mainly be interfaced through:
    %       NEURON.xstim.single_AP_sim.applied_stimulus_manager
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) We could eventually allow loose matching of stimuli based 
    %   on some distance metric ...
    %   2) We might want to more clearly expose what interface this class 
    %   has that is used by the applied_stimulus_manager
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_manager
    %
    %   MAIN METHODS 
    %   ===================================================================
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.getStimulusMatches
    
    %Options ==============================================================
    properties
       %None currently ... 
    end
    
    properties
       stim_manager %NEURON.xstim.single_AP_sim.applied_stimulus_manager
    end
    
    properties
       %.getStimulusMatches()
       d1 = '---- Populate with applyStimulusMatchInfo ----'
       match_info_computed = false

       redundant_new_indices__with_old_source
       old_index_sources
       
       redundant_new_indices__with_new_source  %Indices of the new data 
       %which are deemed to be the same as other indics of the new data ...
       new_index_sources     %Indices whose solutions match the redundant indices
       
       %.applyStimulusMatchInfo()
       d2 = '----  Populate with getUniqueOldIndices ----'
       unique_old_indices %This is important for doing prediction. The new
       %approach for thresholding saves redundant information for quicker
       %lookup. If we are using stimuli and thresholds for prediction we
       %will want to ignore redundant old stimuli
       unique_new_indices
    end
    
    methods
        function obj = applied_stimulus_matcher(stim_man_obj)
           obj.stim_manager = stim_man_obj;
        end
        function reset(obj)
           obj.match_info_computed = false;
           %Yes, some rely on being empty!
           
           %TODO: Create method that copies
           %from the default values with the ability to ignore
           %copying certain properties ...
           
           obj.redundant_new_indices__with_old_source = [];
           obj.old_index_sources = [];
           obj.redundant_new_indices__with_new_source = [];
           obj.new_index_sources  = [];
           obj.unique_old_indices = [];
           obj.unique_new_indices = [];
           
           
           %Reset other properties ????
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
        function unique_old_indices = getUniqueOldIndices(obj)
            if ~obj.match_info_computed
               obj.getStimulusMatches();
            end 
            unique_old_indices = obj.unique_old_indices;
        end
        function applyStimulusMatchInfo(obj)
            %
            %
            %   In general this should be called by the
            %   applied_stimulus_manager.
            %
            %
            %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.applyStimulusMatchInfo
            
            if ~obj.match_info_computed
               obj.getStimulusMatches();
            end
            
            if ~isempty(obj.redundant_new_indices__with_old_source)
                obj.stim_manager.setSameAsOld(...
                        obj.redundant_new_indices__with_old_source,...
                        obj.old_index_sources);
            end
            
            if ~isempty(obj.redundant_new_indices__with_new_source)
                new_solution = obj.stim_manager.new_data;
                new_solution.addWillSolveLaterIndices(...
                        obj.redundant_new_indices__with_new_source,...
                        @obj.applyStimulusMatchesCallback);
            end
        end
    end
    
end

