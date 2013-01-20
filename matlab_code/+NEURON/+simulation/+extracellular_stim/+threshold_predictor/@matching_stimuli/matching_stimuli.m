classdef matching_stimuli
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli
    
    properties
        n_old
        n_new
        
%         old_is_part_of_duplicate_set %For each old element, whether it has duplicates
%         new_is_part_of_duplicate_set %"                 "
%         
%         %These properties elminiate duplicates which are source elements.
%         %For each set of duplicates, one member in the group is set as a
%         %reference. For new stimuli with duplicates to old stimuli, an old
%         %stimulus will always be the reference. For new stimuli that only
%         %have duplicates among new stimuli, the first duplicate entry is
%         %deemed the reference. 
%         old_is_duplicate_and_not_ref %Ideally this is all false
%         new_is_duplicate_and_not_ref
%         
%         %I dislike these names, might change ...
%         first_index_of_old_duplicate
%         first_index_of_new_duplicate
%         
%         %NOTE: Old duplicates must have an old first
%         %source
%         new_duplicate_has_old_source %logical array, if 
%         
        old_index_for_redundant_old_source
        old_index_for_redundant_old_source_mask
        
        %NOTE: Theire is no 
        old_index_for_redundant_new_source
        old_index_for_redundant_new_source_mask
        
        new_index_for_redundant_new_source
        new_index_for_redundant_new_source_mask
        
        
        
        
        
    end
    
    %TODO: Provide explicit methods which clarify the junk
    %property names above ...
    
    methods
    end
    
end

