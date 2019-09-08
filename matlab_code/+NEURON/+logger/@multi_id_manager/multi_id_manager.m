classdef multi_id_manager < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.logger.multi_id_manager
    %
    %   The basic idea with this class is that we want to track simulation
    %   types. To do this the simulation is composed of a bunch of parts.
    %   Each part gets tracked on its own with an ID representing a unique
    %   part. Each simulation is then tracked as a combination of its
    %   unique parts.
    %
    %   So for example, the xstim logger tracks four objects that specify
    %   a unique xstim, the electrode, the cell, the tissue, and general
    %   simulation properties. As we change general simulation properties
    %   new unique IDs will be created for that class, where each ID points
    %   to a set of simulation properties. Each time these properties are
    %   changed, a new xstim entry will be created, but the IDs for all the
    %   other classes will stay the same, just the simulation props entry
    %   will change.
    %
    %   With all of this information we can say, if you saved data 
    %   with the ID of 4 for xstim, then we go into xstim and we might
    %   see that for entry #4 we have:
    %   electrode: ID 1 (i.e. never been updated)
    %   cell: ID 2 (i.e. simulations were logged with two different cell props) 
    %   props: ID 2
    %   tissue: ID 3
    %
    %   For each of these IDs, we can go into their own loggers and get
    %   exactly the parameters that were used. Thus for entry #4 (and all
    %   entries), we know all parameters that were used.
    %
    %
    %   Improvements
    %   ------------
    %   1) Build in tracking of creation dates ...
    %
    %   Functions in other files
    %   ------------------------
    %   find - NEURON.logger.multi_id_manager.find
    %
    %   See Also
    %   --------
    %   NEURON.logger.ID_logger
    
    %{
    
    DESIGN DECISIONS
    =================================================================
    1) We'll hold off on how we'll update this until later ...
    2) Don't automatically save, require the parent class to call
            the save function when saving
    3) We pass in the loggable objects to the find function, not the
    instructions on which objects to get. Any complicated instructions on
    how to get the objects should be handled by the parent ...
    
    %}
    
    %{
    
    CALLER RESPONSIBILITIES
    ================================================================
    1) Instantiate via constructor
    2) Deal with output of find
    
    %}
    
    properties
        id_matrix   %[n x 2*m] subclass_type, match number - interleaved
        %
        %   i.e. type1, match1, type2, match2, type3, etc
        %
        class_types %{1 x m} NOTE: The class types should match for all rows
        %so we only need one copy ...
        save_path
    end
    
    properties (Constant)
        VERSION = 1;
    end
    
    properties (Dependent)
        n_rows
    end
    
    methods
        function value = get.n_rows(obj)
            value = size(obj.id_matrix,1);
        end
    end
    %Constructor and SAVE/LOAD  %==========================================
    methods
        function obj = multi_id_manager(save_base_path)
            %
            %
            %   obj = multi_id_manager(save_base_path)
            obj.save_path = fullfile(save_base_path,'MIM.mat');
            obj.loadObject();
        end
        function saveObject(obj)
            s = NEURON.sl.obj.toStruct(obj); %#ok<NASGU>
            
            save(obj.save_path,'s');
        end
        function loadObject(obj)
            %
            %   loadObject(obj)
            if exist(obj.save_path,'file')
                old_save_path = obj.save_path;
                h = load(obj.save_path);
                s = h.s;
                
                if obj.VERSION ~= s.VERSION
                    error('Code needs to be updated to handle data change')
                end
                
                result = NEURON.sl.struct.toObject(obj,s); %#ok<NASGU>
                
                obj.save_path = old_save_path;
            end
        end
    end
    
    %PROCESSING   %========================================================
    methods
        function class_types_local = getClassTypes(obj,id_obj_cell_array)
            %
            %
            %   class_types_local = getClassTypes(obj,id_obj_cell_array)
            
            n_objects = length(id_obj_cell_array);
            class_types_local = cell(1,n_objects);
            for iInput = 1:n_objects
                cur_id = id_obj_cell_array{iInput};
                class_types_local{iInput} = cur_id.class_type;
            end
        end
        function row_entry = getRowEntry(obj,id_obj_cell_array)
            %
            %
            %   row_entry = getRowEntry(obj,id_obj_cell_array)
            %
            %   This function returns a linearized version of the ids
            %
            %   Output
            %   ------
            %   row_entry : a linearized version of the ids as a vector
            %
            %   TODO: It might be desirable to move this to the ID class
            
            %   ???? What is this?????
            %   id_array = [id_obj_cell_arrray{:}]
            %   row_entry = id_array.linearize; %Function NYI
            
            cur_index = 0;
            
            nInputs = length(id_obj_cell_array);
            row_entry = zeros(1,nInputs*2);
            for iInput = 1:nInputs
                cur_id = id_obj_cell_array{iInput};
                
                cur_index = cur_index + 1;
                row_entry(cur_index) = cur_id.type;
                
                cur_index = cur_index + 1;
                row_entry(cur_index) = cur_id.trial_row;
            end
            
        end
    end
    
end

