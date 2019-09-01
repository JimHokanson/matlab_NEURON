classdef multi_id_manager < NEURON.sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.logger.multi_id_manager
    %
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Build in tracking of creation dates ...
    
    
    
    
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
            obj.save_path = fullfile(save_base_path,'MIM.mat');
            obj.loadObject();
        end
        function saveObject(obj)
            s = NEURON.sl.obj.toStruct(obj); %#ok<NASGU>
            
            save(obj.save_path,'s');
        end
        function loadObject(obj)
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
            %   OUTPUT
            %   ===========================================================
            %   row_entry : a linearized version of the ids as a vector
            %
            %   TODO: It might be desirable to move this to
            %   the ID class
            %
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

