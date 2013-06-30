function output_indices = compare(obj, new, old, type, input_indices)
%
%
%   output_indices = compare(obj, new, old, type, input_indices)
%
%depending on the type find the appropriate comparison method
%return indices of the same prop...
%
%   See Also:
%   
%
%   FULL PATH:
%   ===========================================================
%   NEURON.logger.auto_logger

%NOTE: This shouldn't be needed ...
if isempty(input_indices)
    output_indices = [];
    return;
end

switch type
    case 'simple_numeric'
        temp_indices = find(new == old(input_indices));
    case 'cellFP'
        %- each old element is an entry in a cell array
        %- the entries themselves are arrays
        %- the values inside should be considered floating point
        %   so we need to do a floating point comparison
        
        %old = {[1 2 3] [1 2 3 4 5 6] [0 100 0] };
        
        truncated_values = old(input_indices);
        
        %Remove dimensions that are not the same length
        %------------------------------------------------------
        same_size   = cellfun('length',truncated_values) == length(new);
        temp_matrix = vertcat(truncated_values{same_size});
        
        %Use matrix comparision function for final comparison
        %------------------------------------------------------
        I = obj.compare(new,temp_matrix,'vectorFP',1:size(temp_matrix,1));
        
        %Adjust indices to match input scale ...
        %-----------------------------------------------------
        same_size_indices = find(same_size);
        temp_indices      = same_size_indices(I);
    case 'matrixFP'
        temp        = old(:,:,input_indices);
        difference  = sum(sum(abs(bsxfun(@minus, new, temp))));
        fp_is_different = difference > 10*eps;
        
        temp_indices = find(~any(fp_is_different,2));
        
    case 'vectorFP'
        %STATUS: DONE
        temp         = old(input_indices,:);
        difference   = bsxfun(@minus, new, temp);
        
        %NOTE: somewhat arbitrary comparison
        %TODO: Add reasoning for this in design decision
        %
        %i.e. for now we want to compare equal to within
        %computation error, not roughly equal where we might
        %decide 3.001 is close enough to 3 that we don't care
        %
        %The latter is very difficult to do, especially with
        %a wide range of numbers ...
        fp_is_different = abs(difference) > 10*eps;
        
        temp_indices = find(~any(fp_is_different,2));
    otherwise
        error('Type %s not recognized',type)
end

output_indices = input_indices(temp_indices);

%method = getCompar
%ind = find(~cellfun(method, new, old));
end