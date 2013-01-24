function cell_created = createCellInNEURON(obj)
% NEURON.cell.axon.generic.createCellInNEURON

cell_created = true;

cdToModelDirectory(obj) % NEURON.neural_cell.cdToModelDirectory cd's to model HOC_CODE directory

c = obj.cmd_obj;

%dynamics = obj.props_obj.node_membrane_dynamics;
%dll_path = fullfile('mod_files',[dynamics '.dll']);
%c.load_dll(dll_path);

if ~obj.ran_init_code_once
    if ispc
        c.load_dll('mod_files/nrnmech.dll');
    elseif ismac
        c.load_dll('mod_files/i386/.libs/libnrnmech.so');
    else
       error('Non-Mac Unix systems are not yet supported.') 
    end
    obj.ran_init_code_once = true;
end


placeVariablesInNEURON(obj.props_obj,c) % NEURON.cell.axon.generic.props.placeVariablesInNEURON

c.load_file('create_generic_axon.hoc');


%populateSpatialInfo(obj) % should be able to remove when spatial_info class is completed
%obj.cell_populated_in_NEURON = true;