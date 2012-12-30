classdef matcher < handle_light
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.matcher
    %
    %   
    %   METHODS
    %   =======================================================
    %   1) Initialization - from file or scratch
    %   2) Find current definition in previous instances
    %   3) On no match, add on current definition and save
    %   definitions to file ... - this is a manual step in case
    %   we are just testing 
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
       root_data_file
    end
       
    properties
       current_max_index = 0 %Max index of simulations 
       stim_obj             
       cell_props_obj
       
       %We'll implement this later
       %Increment the version # when this happens ...
       %dynamics_matcher
       
       %Steps:
       %--------------------------------------------------------
       %1) New simulation passed in for comparison
       %2) 
       

    end
    
    properties (Constant)
       VERSION = 1;
    end
    
    methods
        function obj = matcher(root_data_file)
            
           import NEURON.simulation.extracellular_stim.sim_logger.matcher.*
            
           obj.root_data_file = root_data_file;
           
           %NOTE: If nothing exists we'll need to create an initialization method ...
           
           if ~exist(root_data_file,'file')
               %Let initialization occur during adding on entry and saving
               %...
           else
               h = load(root_data_file);
               if h.version ~= obj.VERSION
                  error('Version mismatch, case not yet handled')
               end
               obj.current_max_index  = h.current_max_index;
               obj.stim_obj           = stim(h.stim);
               obj.cell_props_obj     = cell_props(h.cell_props);
           end
        end
        function [index,is_new] = getMatchingSimulation(obj,xstim_obj,add_if_not_found)
           
            %Step 1: match stim
            %Step 2: match cell props 
            
                        %TODO:
            %Should do simulation filtering as well ...
            %Notably - temperature ...
            
            done_searching = false;
            index = [];
            is_new = false;
            matching_indices = obj.stim_obj.getMatchingEntries(xstim_obj,obj.current_max_index);
            
            if isempty(matching_indices)
                done_searching = true;
            end
            
            if ~done_searching
                temp = obj.cell_props_obj.getMatchingEntries(xstim_obj,matching_indices);
                %Shift indices back to original input space
                index = matching_indices(temp);
            end
            
            
            %Handle output
            %--------------------------------------------------------------
            if length(index) > 1
                error('Index should be empty or have a singular match')
            end

            if isempty(index) == 1 && add_if_not_found
               is_new = true;
               index  = obj.addSimulation();
            end
        end
    end
    
    methods (Access = private)
        function next_index = addSimulation(obj)
           %
           %    NOTE: This can only be called from getMatchingSimulation
           %    
           %    Called From: getMatchingSimulation
           %        
           
           
           %Step 1: Increment index
           next_index = obj.current_max_index + 1;
           obj.current_max_index = next_index;
                      
           %Step 2: Add searched instance to classes
           obj.stim_obj.addCurrentInstance();
           obj.cell_props_obj.addCurrentInstance();
           
           %Step 3: Retrieve data for saving
           stim       = obj.stim_obj.getSavingStruct();
           cell_props = obj.cell_props_obj.getSavingStruct();
           version = obj.VERSION;
           current_max_index = next_index;
           
           %Step 4: Save data
           save(obj.root_data_file,'stim','cell_props','version','current_max_index');
           
        end
    end
    
end

