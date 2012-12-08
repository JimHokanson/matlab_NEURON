function createCellInNEURON(obj)
% NEURON.cell.axon.generic.createCellInNEURON


cdToModelDirectory(obj) % NEURON.neural_cell.cdToModelDirectory cd's to model HOC_CODE directory

c = obj.cmd_obj;

dynamics = obj.props_obj.node_membrane_dynamics;
dll_path = fullfile('mod_files',[dynamics '.dll']);
c.load_dll(dll_path); % place channel dynamics dll here

placeVariablesInNEURON(obj.props_obj,c) % NEURON.cell.axon.generic.props.placeVariablesInNEURON

c.load_file('create_generic_axon.hoc');


populateSpatialInfo(obj)

obj.cell_populated_in_NEURON = true;