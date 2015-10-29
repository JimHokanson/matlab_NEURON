function numeric_dim = getNumericDim(dim_input)
%
%
%   numeric_dim = getNumericDim(dim_input)
%
%   FULL PATH:
%   arrayfcns.xyz.getNumericDim

sl.warning.deprecated('','sl.xyz.getNumericDim','Moving to a better location')

if ischar(dim_input)
    %TODO: Check char length
    numeric_dim = strfind('xyz',dim_input);
    if isempty(numeric_dim) || length(numeric_dim) > 1
        error('Input should be x, y, or z')
    end
else
    numeric_dim = dim_input;
end