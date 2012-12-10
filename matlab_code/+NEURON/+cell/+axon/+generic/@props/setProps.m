function setProps(propObj,varargin)
% NEURON.cell.axon.generic.props.setProps
% Set the property values of NEURON.cell.axon.generic.props by inputting
% the propsObj and either a single structure of properties and values, or a list
% of property/value pairs.

% Handle inputs =============================
if nargin < 2
    warning('No properties inputted.')
    return
end

if isstruct(varargin{1})
    propStruct = varargin{1};
    if nargin > 1
        warning('Input must be propObj followed by a single struct or a list of property/value pairs. Additional inputs ignored.')
    end
end

if nargin > 2
   if floor(nargin/2) == nargin/2 % is even?
       error('Input must be propObj followed by a single struct or a list of property/value pairs.')
   end
   
   propStruct = struct;
   for iProp = 1:2:nargin - 1
      curProp = varargin{iProp};
      curVal = varargin{iVal};
      if ~ischar(curProp)
        error('Input must be propObj followed by a single struct or a list of property/value pairs. Atleast one property is not a string')
      end
      propStruct.(curProp) = curVal;
   end
end
% End input handling ===============================

% Assign inputted properies to propsObjs ============
inputProps = fieldnames(propStruct);
nProps = length(fieldnames);

for iProp = 1:nProps
    curProp = inputProps{iProp};
    curVal = propStruct.(curProp);
   if isprop(propObj,curProp)
       propObj.(curProp) = curVal;
   else
       warning('Inputted property %s is not an actual property, ignored. Properties are case-sensitive',curProp) 
       % ideally it would be nice if this method was not case sensitive,
       % but that would involve having a list of all property pairs in this
       % method to compare
   end
end

end