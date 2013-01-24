classdef matching_stimuli
    %
    %   This class documents which stimuli match which stimuli. It also
    %   has some useful properties that are needed for copying thresholds
    %   for redundant stimuli.
    %
    %   This class is currently constructed by the threshold predictor
    %   class. It is up to the threshold predictor class to determine the
    %   criteria by which stimuli are considered the same or different.
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli
    %
    %   Constructed by:
    %       NEURON.simulation.extracellular_stim.threshold_predictor.getStimuliMatches
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Pass certain info into this class constructor so as to allow for
    %   easier extending of the predictor method.
    
   
    properties
        n_old   %# of old stimuli
        n_new   %# of new stimuli
        
        old_index_for_redundant_old_source %For all duplicates this indicates 
        %which index serves as the representative of the set (this
        %representative is also a duplicate but is not indicated as such in
        %the mask)
        
        old_index_for_redundant_old_source__mask %mask indicates that the element
        %is a duplicate of another old element. Currently one duplicate is
        %from each duplicate set is false as it serves as the
        %representative of the set. Ideally there are no duplicates (a bug
        %made it so that some duplicates were present) The method:
        %  NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
        %can be called to remove these duplicates
        
        
        %TODO: FINISH DOCUMENTATION OF PROPERTIES AND METHODS BELOW
        %==================================================================
        
        old_index_for_redundant_new_source
        
        old_index_for_redundant_new_source__mask  %indices represent new stimuli
        %values represent whether an old stimulus is present that matches
        %this stimulus (i.e. value in old_index_for_redundant_new_source)
        %is valid
        
        new_index_for_redundant_new_source
        
        new_index_for_redundant_new_source__mask  %indices represent new stimuli
        %values represent
    end
    
    properties (Dependent)
        new_source_indices_to_learn
        old_index_for_redundant_old_source__redundant_only
        old_index_for_redundant_new_source__redundant_only
        new_index_for_redundant_new_source__redundant_only
    end
    
    methods
        function value = get.new_source_indices_to_learn(obj)
            %New to learn - find entries that don't have a duplicate
            %in the old stimuli or a duplicate in the new stimuli
            %that we'll be testing
            value = find(...
                ~(obj.old_index_for_redundant_new_source__mask | ...
                        obj.new_index_for_redundant_new_source__mask));
        end
        function value = get.old_index_for_redundant_new_source__redundant_only(obj)
            value = obj.old_index_for_redundant_new_source(obj.old_index_for_redundant_new_source__mask);
        end
        function value = get.new_index_for_redundant_new_source__redundant_only(obj)
            value = obj.new_index_for_redundant_new_source(obj.new_index_for_redundant_new_source__mask);
        end
        function value = get.old_index_for_redundant_old_source__redundant_only(obj)
            value = obj.old_index_for_redundant_old_source(obj.old_index_for_redundant_old_source__mask);
        end
    end
    
    methods
        function r_groups = getRedundantOldGroups(obj)
            %
            %
            %   r_groups = getRedundantOldGroups(obj)
            %   
            %   OUTPUTS
            %   ===========================================================
            %   r_groups : (cell array of arrays), each array holds 
            %              a set of indices whose stimuli have been
            %              determined to be the same
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
            
            redundant_indices = find(obj.old_index_for_redundant_old_source__mask);
            
            [u,uI] = unique2(obj.old_index_for_redundant_old_source__redundant_only);
            
            r_groups = cellfun(@(x,y) sort([x; redundant_indices(y)]),num2cell(u),uI','un',0);
        end
    end
    
end

