classdef multi_id_manager < sl.obj.handle_light
    %
    
    properties
        id_matrix   %[n x 2*m] subclass_type, match number - interleaved
        class_types %{1 x m} NOTE: The class types should match for all rows
        %so we only need one copy ...
        %n_rows      %TODO: make dependent on variables above using get method
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
    
    methods
        function obj = multi_id_manager()
        end
    end
    methods
        function matching_row = find(loggable_classes_cell_array)
            %
            %   NOTE: This is not a logger, so it doesn't need to return an
            %   id
            %
            
            %varargin - loggable classes or loggers ...
            %
            %    I'm not sure what I want the input to this to look like
            %
            %    I might want to pass in ids here, or alteratively, I might
            %    want to pass in classes ....
            %
            
            n_classes = length(loggable_classes_cell_array);
            
            all_ids = cell(1,n_classes);
            
            for iClass = 1:n_classes
                cur_class = loggable_classes_cell_array{iClass};
                temp_logger = cur_class.getLogger();
                all_ids{iClass} = temp_logger.find();
            end
            
            row_entry = getRowEntry(obj,all_ids);
            
            if obj.n_rows == 0
                matching_row = [];
            else
                matching_row = find(bsxfun(@minus,obj.id_matrix,row_entry));
            end
            
        end
        function addEntry(obj,id_obj_cell_array)
            
            class_types_local = obj.getClassTypes(id_obj_cell_array);
            
            if next_row == 1
                %Add definition of class types
                obj.class_types = class_types_local;
            else
                %TODO: Should verify this matches current property ...
                %This should also be done in find ...
            end
            
            next_row = obj.n_rows + 1;
            obj.id_matrix(next_row,:) = obj.getRowEntry(id_obj_cell_array);
            
        end
        function class_types_local = getClassTypes(obj,id_obj_cell_array)
            n_objects = length(id_obj_cell_array);
            class_types_local = cell(1,n_objects);
            for iInput = 1:n_objects
                cur_id = id_obj_cell_array{iInput};
                class_types_local{iInput} = cur_id.super_class_string;
            end
        end
        function row_entry = getRowEntry(obj,id_obj_cell_array)
            %varargin - entries are ids
            
            cur_index = 0;
            
            nInputs = length(id_obj_cell_array);
            row_entry = zeros(1,nInputs*2);
            for iInput = 1:nargin
                cur_index = cur_index + 1;
                cur_id = id_obj_cell_array{iInput};
                row_entry(cur_index) = cur_id.subclass_type;
                cur_index = cur_index + 1;
                row_entry(cur_index) = cur_id.subclass_match_number;
            end
            
        end
    end
    
end

