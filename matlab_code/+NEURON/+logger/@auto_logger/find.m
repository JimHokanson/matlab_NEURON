function ID = find(obj,create_if_not_found)
%
%   ID = find(obj,create_if_not_found)
%
%
%   See Also:
%   
%
%   FULL PATH:
%   NEURON.logger.auto_logger.find
%   NEURON.logger.auto_logger.getNewValue

n_trials_local = obj.n_trials;

if ~create_if_not_found && n_trials_local == 0
    ID = obj.getID();
    return
end

props_local     = obj.getPropNames();
types_local     = obj.getTypeNames();
r_methods_local = obj.getRetrievalMethods();

n_props    = length(props_local);

%Retrieval of current values
%--------------------------------------------------------------------------
all_new_values = cell(1,n_props);
for iProp = 1:n_props
    cur_prop   = props_local{iProp};
    cur_method = r_methods_local{iProp};
    
    %NEURON.logger.auto_logger.getNewValue
    all_new_values{iProp} = obj.getNewValue(cur_prop,cur_method);
end

%If no previous values exist, quit early 
%--------------------------------------------------------------------------
if n_trials_local == 0 && create_if_not_found
    ID = helper__addEntry(obj,all_new_values);
    return
end

%Comparison to previous values
%--------------------------------------------------------------------------
matching_indices = 1:n_trials_local;
for iProp = 1:n_props
    cur_prop   = props_local{iProp};
    cur_type   = types_local{iProp};
    
    
    %NOTE: We might want to move this to a structure ...
    old_value = obj.old_values.(cur_prop);
    
    temp_indices = obj.compare(all_new_values{iProp},old_value,cur_type,matching_indices);
    
    if isempty(temp_indices)
       if create_if_not_found
          ID = helper__addEntry(obj,all_new_values);
       else
          ID = obj.getID(); 
       end
       return
    end
    
    matching_indices = temp_indices;
end

if length(temp_indices) ~= 1
    error('Multiple matches found')
end

ID = obj.getID(temp_indices); 
end


function ID = helper__addEntry(obj,all_values)
    
    types_local = obj.getTypeNames();
    props_local = obj.getPropNames();
    
    %TODO: INSERT PROPERTIES HERE
    n_values = length(all_values);
    
    for iValue = 1:n_values
        cur_value = all_values{iValue};
        cur_prop  = props_local{iValue};
        cur_Type  = types_local{iValue};
        s = obj.old_values;
        switch cur_Type
            case 'simple_numeric'
                s.(cur_prop) = [s.(cur_prop) cur_value]; 
            case 'cellFP'
                s.(cur_prop) = [s.(cur_prop) {cur_value}]; 
                                
%We don't have cases where this is appropriate ....
% % %             case 'matrixFP'
% % %                 s.(cur_prop) = cat(3, s.(cur_prop), cur_value);
            case 'vectorFP'
                %Form matrix, all rows the same size
                s.(cur_prop) = [s.(cur_prop); cur_value]; 
            otherwise
                error('Unhandled case')
        end
        obj.old_values = s;
    end
    
    ID = obj.updateIDandSave(@obj.saveLog);
end