function cell_created = createCellInNEURON(obj)
%createCellInNEURON  Creates the cell in NEURON
%
%   cell_created = createCellInNEURON(obj)
%
%   Creates the cell in NEURON.
%
%   OUTPUTS
%   =======================================================================
%   cell_created : See definition in NEURON.neural_cell.createCellInNEURON 
%
%   This function:
%   -----------------------------------------------------------------------
%   1) Changes the current path to the model directory
%   2) Loads channel dynamics methods
%   3) Creates the anatomy
%
%   NOTE: This function might need some more delineation between
%   initialization and repeated runs, specifically with respect to running
%   the create_mrg_axon.hoc
%
%   FULL PATH
%   NEURON.cell.axon.MRG.createCellInNEURON

p = obj.props_obj;  %Class: NEURON.cell.axon.MRG.props
if p.props_up_to_date_in_NEURON
   cell_created = 0;
   return
end

%NEURON.neural_cell.cdToModelDirectory
obj.cdToModelDirectory();

%Shortening variable for easier reference in code below
c = obj.cmd_obj; %Class: Neuron.cmd

if ~obj.cell_initialized_in_neuron_at_least_once
    %This allows us to insert the MRG channel dynamics
    c.load_standard_dll;
    
    obj.cell_initialized_in_neuron_at_least_once = true;
    cell_created = 1;
else
    cell_created = 2;
end

%This puts all of the variables that are specific to the MRG model into
%NEURON, so that the hoc code below works.
%NEURON.cell.axon.MRG.props.placeVariablesInNEURON
obj.props_obj.placeVariablesInNEURON(c)
%NOTE: This method will ensure that the props are up to date

%Run the hoc file
c.load_file('create_mrg_axon.hoc');

end
