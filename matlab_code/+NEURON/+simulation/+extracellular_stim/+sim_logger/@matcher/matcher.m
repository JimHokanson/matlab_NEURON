classdef matcher
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.matcher
    %
    %   
    %   METHODS
    %   =======================================================
    %   1) Initialization - from file or scratch
    %   2) Find current definition in previous instances
    %   3) On no match, add on current definition and save
    %   definitions to file ...
    %   4) Eventually support pseudo-matching, where we can
    %   relate new results to old results that are similar ...
    
    %Stimulation Matching
    %-----------------------------------------
    %Version - for updating
    %        - only 1 is currently defined ...
    %Type    - numeric, split on how to compare
    %        - only 1 is currently defined ...
    %        - 

    properties
       current_index 
       stim_obj             
       cell_props_obj
       
       %We'll implement this later
       %Increment the version # when this happens ...
       %dynamics_matcher
    end
    
    properties (Constant)
       VERSION = 1;
    end
    
    methods
        function obj = matcher(root_data_file)
            
           import NEURON.simulation.extracellular_stim.sim_logger.matcher.*
            
           %NOTE: If nothing exists we'll need to create an initialization method ...
           
           if ~exist(root_data_file,'file')
               %Initialize from scratch
           else
               h = load(root_data_file);
               if h.version ~= obj.VERSION
                  error('Version mismatch, case not yet handled')
               end
               obj.current_index  = h.current_index;
               obj.stim_obj       = stim(h.stim);
               obj.cell_props_obj = cell_props(h.cell_props);
           end
        end
    end
    
end

