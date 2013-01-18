function cell_created = createCellInNEURON(obj)
%createCellInNEURON  Creates the cell in NEURON
%
%   Creates the cell in NEURON and populates other variables, see below
%   
%   Class: NEURON.cell.axon.MRG
%
%   This function:
%   -----------------------------------------------------------------------
%   1) Changes the current path to the model directory
%   2) Loads channel dynamics methods
%   3) Creates the anatomy
%
%
%   NOTE: This function might need some more delineation between
%   initialization and repeated runs, specifically with respect to running
%   the create_mrg_axon.hoc

%First, check if we need to run this ...
p = obj.props_obj;  %Class: NEURON.cell.axon.MRG.props

if p.props_up_to_date_in_NEURON
   cell_created = false;
   return 
else
   cell_created = true;
end

%NEURON.neural_cell.cdToModelDirectory
obj.cdToModelDirectory();

%Shortening variable for easier reference in code below
c = obj.cmd_obj; %Class: Neuron.cmd

if ~obj.cell_initialized_in_neuron_at_least_once
    %This allows us to insert the MRG channel dynamics
    if ispc
        c.load_dll('mod_files/nrnmech.dll');
    elseif ismac
        c.load_dll('mod_files/i386/.libs/libnrnmech.so');
    else
       error('Non-Mac Unix systems are not yet supported.') 
    end
    
    obj.cell_initialized_in_neuron_at_least_once = true;
end

%This puts all of the variables that are specific to the MRG model into
%NEURON, so that the hoc code below works.
%NEURON.cell.axon.MRG.props.placeVariablesInNEURON
obj.props_obj.placeVariablesInNEURON(c)
%NOTE: This method will ensure that the props are up to date

%Run the hoc file
c.load_file('create_mrg_axon.hoc');

end
