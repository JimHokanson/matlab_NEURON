function [matching_row,is_new] = find(obj,loggable_classes_cell_array,create_new, varargin)
%find
%
%   [matching_row,is_new] = find(loggable_classes_cell_array,create_new)
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
%   create_new   : if true and no match is found a new one
%           will be created.
%
%   INPUTS
%   ===========================================================
%   loggable_classes_cell_array : (cell array), a cell array of
%               classes that can be logged
%
%
%
%   FULL PATH:
%   NEURON.logger.multi_id_manager.find

is_new = false;

if ~create_new && obj.n_rows == 0
    matching_row = [];
    return
end

ignore = [];
if nargin > 3
    ignore = varargin{1};
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
elseif ~isempty(ignore)
    row_entry_temp = row_entry;
    row_entry_temp(ignore.*2) = inf;
    row_entry_temp(ignore.*2 +1) = inf;
    usable = length(row_entry) - length(ignore);
    temp_sum = sum(~bsxfun(@minus,row_entry_temp,obj.id_matrix),2);
    matching_row = find(temp_sum,usable);
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