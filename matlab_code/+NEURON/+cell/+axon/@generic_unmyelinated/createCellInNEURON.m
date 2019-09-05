function cell_created = createCellInNEURON(obj)
% NEURON.cell.axon.generic_unmyelinated.createCellInNEURON



cell_created = true;

cdToModelDirectory(obj) % NEURON.neural_cell.cdToModelDirectory cd's to model HOC_CODE directory

c = obj.cmd_obj;

%JAH TODO: How does this differ from:
%NEURON.cmd/load_standard_dll (line 303)
if ~obj.ran_init_code_once
    if ispc
        c.load_dll('mod_files/nrnmech.dll');
    elseif ismac
        %This may vary ...
        keyboard
        c.load_dll('mod_files/i386/.libs/libnrnmech.so');
    else
       error('Non-Mac Unix systems are not yet supported.') 
    end
    obj.ran_init_code_once = true;
end


placeVariablesInNEURON(obj.props_obj,c) % NEURON.cell.axon.generic_unmyelinated.props.placeVariablesInNEURON

c.load_file('create_generic_unmyelinated_axon.hoc');