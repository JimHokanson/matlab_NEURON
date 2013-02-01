function placeVariablesInNEURON(obj,c)
% NEURON.cell.axon.generic_unmyelinated.props.placeVariablesInNEURON

p = obj;
p.populateDependentVariables(); % NEURON.cell.axon.generic_unmyelinated.props.populateDependentVariables

p_v = obj.getPropertyValuePairing();

% check that no variables are empty and all are numeric
for iProp = 1:size(p_v,1)
   curVal = p_v{iProp,2};
   if isempty(curVal) || ~isnumeric(curVal)
      error('All properties must be defined numerically before sending to NEURON.')
   end
end

%PUKE VARIABLES INTO NEURON
c.writeNumericProps(p_v(:,1),p_v(:,2));

%Update dirty bit
obj.props_up_to_date_in_NEURON = true;
end