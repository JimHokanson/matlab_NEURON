function placeVariablesInNEURON(obj,c)
% NEURON.cell.axon.generic.props.placeVariablesInNEURON

p = obj;
p.populateDependentVariables(); % NEURON.cell.axon.generic.props.populateDependentVariables

p_v = {...
    'number_internodes'                  p.number_internodes
    'node_length'                   p.node_length
    'node_diameter'                 p.node_diameter
    'myelin_n_segs'                 p.myelin_n_segs
    'myelin_length'                 p.myelin_length
    'fiber_diameter'                p.fiber_diameter
    'myelin_conductance'            p.myelin_conductance
    'myelin_capacitance'            p.myelin_capacitance
    'node_dynamics'                 p.node_dynamics};

% check that no variables are empty and all are numeric
for iProp = 1:size(p_v,1)
   curVal = p_v{iProp,2};
   if isempty(curVal) || ~isnumeric(curVal)
      error('All properties must be defined numerically before sending to NEURON.')
   end
end

%PUKE VARIABLES INTO NEURON
c.writeNumericProps(p_v(:,1),p_v(:,2));
end