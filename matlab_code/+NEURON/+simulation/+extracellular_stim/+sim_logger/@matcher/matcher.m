classdef matcher < NEURON.sl.obj.handle_light
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.matcher
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Implement matching for simulation properties (temp, time,
    %   solver)
    %   2) Implement dynamics matching
    %       - we currently check type, hh, fh, etc, but not the properties
    %   associated with these models
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
    %
    %
    %   Relevant Related Classes
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
    %   NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props
    
    
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
        
        stim_obj        %Class: NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
        cell_props_obj  %Class: NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props
        
        %We'll implement this later
        %Increment the version # when this happens ...
        %dynamics_matcher
        
    end
    
    properties (Constant)
        VERSION = 1;
    end
    
    methods
        function obj = matcher(paths_obj)
            %
            %
            %   obj = matcher(paths_obj)
            %
            %   Normally the sim_logger constructor calls this class.
            
            import NEURON.simulation.extracellular_stim.sim_logger.matcher.*

            if ~exist('paths_obj','var')
               paths_obj = NEURON.simulation.extracellular_stim.sim_logger.pathing; 
            end
                
            obj.root_data_file = paths_obj.main_table_path;
            
            %NOTE: If nothing exists we'll need to create an initialization method ...
            
            if ~exist(obj.root_data_file,'file')
                %Let initialization occur during adding on entry and saving ...
                obj.stim_obj           = stim();
                obj.cell_props_obj     = cell_props();
            else
                h = load(obj.root_data_file);
                if h.version ~= obj.VERSION
                    error('Version mismatch, case not yet handled')
                end
                obj.current_max_index  = h.current_max_index;
                obj.stim_obj           = stim(h.stim);
                obj.cell_props_obj     = cell_props(h.cell_props);
            end
        end
        function [index,is_new] = getMatchingSimulation(obj,xstim_obj,add_if_not_found)
            %
            %
            %   [index,is_new] = getMatchingSimulation(obj,xstim_obj,add_if_not_found)
            %
            %
            
            %Step 1: match stim
            %Step 2: match cell props
            
            %TODO:
            %Should do simulation filtering as well ...
            %Notably - temperature ...

            
            %IMPORTANT: The matching methods currently also populate
            %the instance to match as well. These should ideally be
            %separated into two separate calls to be more obvious.
            is_new = false;
            
            %NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
            matching_indices = obj.stim_obj.getMatchingEntries(xstim_obj,obj.current_max_index);

            %NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props.getMatchingEntries
            temp = obj.cell_props_obj.getMatchingEntries(xstim_obj,matching_indices);
            %Shift indices back to original input space
            index = temp;
            %index = matching_indices(temp);
            
            
            
            %Handle output
            %--------------------------------------------------------------
            if length(index) > 1
                formattedWarning('\nMultiple matches observed for sim_logger, using first instance\n%s\n%s\n%s',...
                    ['Matching Indices: ' mat2str(index)], ...
                    'See static method:','NEURON.simulation.extracellular_stim.sim_logger.matcher.removeIndices')
                
                index = index(1); %Use oldest
            end
            
            if isempty(index) && add_if_not_found
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
                        
            save(obj)
        end
        function save(obj)
            %Retrieve data for saving
            
            %Submitted requests to not throw mlint warning for save
            %function as well as the ability to ignore these messages
            %within the scope of a function/method
            stim       = obj.stim_obj.getSavingStruct(); %#ok<NASGU>
            cell_props = obj.cell_props_obj.getSavingStruct(); %#ok<NASGU>
            version    = obj.VERSION; %#ok<NASGU>
            current_max_index = obj.current_max_index; %#ok<NASGU,PROP>
            
            %Save data
            save(obj.root_data_file,'stim','cell_props','version','current_max_index'); 
        end
    end
    
    methods (Static)
        function removeIndices(indices_remove)
           %
           %    NEURON.simulation.extracellular_stim.sim_logger.matcher.removeIndices(indices_remove)
           
                obj = NEURON.simulation.extracellular_stim.sim_logger.matcher;
                
                indices_remove = unique(indices_remove);
                
                if any(indices_remove < 0) || any(indices_remove > obj.current_max_index)
                   error('Indices specified for removal are outside the valid range of 1:%d',...
                       obj.current_max_index)
                end
                
                obj.stim_obj.deleteIndices(indices_remove);
                obj.cell_props_obj.deleteIndices(indices_remove);
                
                obj.current_max_index = obj.current_max_index - length(indices_remove);
                
                save(obj)
        end
    end
    
end

