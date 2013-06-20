classdef multi_id_manager < sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.logger.multi_id_manager
    
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
        %
        %   Properties to load and save ...
        %   id_matrix
        %   class_types
        %
        function saveObject(obj)
            w = warning('off','MATLAB:structOnObject');
            s = struct(obj);
            warning(w);
            
            if exist('properties_remove','var')
                s = rmfield(s,properties_remove);%#ok<NASGU>
            end
            
            save(obj.save_path,'s');
        end
        function loadObject(obj)
            if exist(obj.save_path,'file')
                h = load(obj.save_path);
                s = h.s;
                
                if obj.VERSION ~= s.VERSION
                    s = obj.update(s);
                end
                
                result = sl.struct.toObject(obj,s); %#ok<NASGU>
            end
            
        end
    end
    
    %PROCESSING   %========================================================
    methods
        function [matching_row,is_new] = find(obj,loggable_classes_cell_array,varargin)
            %find
            %
            %   [matching_row,is_new] = find(loggable_classes_cell_array,varargin)
            %
            %   NOTE: This is not a logger, so it doesn't need to return an
            %   id. This would be implemented by the caller.
            %
            %   OUTPUTS
            %   ===========================================================
            %   matching_row : the row that matches the current object
            %           values. If no match is found the output will be
            %           empty [], unless users specifies to create a new
            %           value if not found (see optional inputs)
            %   is_new       : whether or not a new entry has been created
            %
            %   INPUTS
            %   ===========================================================
            %   loggable_classes_cell_array : (cell array), a cell array of
            %               classes that can be logged
            %
            %   OPTIONAL INPUTS (property/value pairs)
            %   ===========================================================
            %   create_if_not_found : (default true), if true and no match
            %           is found a new one will be created.
            
            in.create_if_not_found = true;
            in = sl.in.processVarargin(in,varargin);
            
            create_new = in.create_if_not_found;
            
            is_new = false;
            
            if ~create_new && obj.n_rows == 0
                matching_row = [];
                return
            end
            
            %STEP 1: Acquire previous IDS (or new ones)
            %--------------------------------------------------------------
            n_classes   = length(loggable_classes_cell_array);
            all_ids     = cell(1,n_classes);
            abort_match = false;
            
            for iClass = 1:n_classes
                cur_class       = loggable_classes_cell_array{iClass};
                temp_logger     = cur_class.getLogger();
                temp_id         = temp_logger.find(create_new);
                
                if ~temp_id.isValid
                    if ~create_new
                        %NOTE: This indicates that a subset did not match
                        %so we won't be able to match in this class either.
                        %Since we are not creating a new entry, and don't
                        %need the ID information for adding, we might as
                        %well stop now.
                        abort_match = true;
                        break
                    else
                        %TODO: Add details on which logger did this ...
                        error('There was a request to create a new ID which the logger did not respect')
                    end
                end
                all_ids{iClass} = temp_id;
            end
            
            if abort_match
                matching_row = [];
                return
            end
            
            %Creation of row from ID data, and comparision to previous
            %-----------------------------------------------------------
            row_entry = getRowEntry(obj,all_ids);
            
            if obj.n_rows == 0
                matching_row = [];
            else
                matching_row = find(~sum(abs(bsxfun(@minus,row_entry,obj.id_matrix)),2));
            end
            
            %Addition of the entry if necessary
            %--------------------------------------------------------------
            if create_new && isempty(matching_row)
                is_new = true;
                
                %class_types_local = obj.getClassTypes(id_obj_cell_array); %What is this s'posed to be?
                class_types_local = obj.getClassTypes(all_ids);
                if obj.n_rows == 0
                    obj.class_types = class_types_local;
                else
                    %TODO: Should verify this matches the
                    %current property ...
                end
                obj.id_matrix = vertcat(obj.id_matrix,row_entry);
            end
            
        end
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

