function createCellInNEURON(obj)
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

%NEURON.neural_cell.cdToModelDirectory
cdToModelDirectory(obj)

%Shortening variable for easier reference in code below
c = obj.cmd_obj; %Class: Neuron.cmd

%This allows us to insert the MRG channel dynamics
c.load_dll('mod_files/nrnmech.dll');

%This puts all of the variables that are specific to the MRG model into
%NEURON, so that the hoc code below works.
%NEURON.cell.axon.MRG.props.placeVariablesInNEURON
placeVariablesInNEURON(obj.props_obj,c)

%Run the hoc file
c.load_file('create_mrg_axon.hoc');

%Spatial info - changed so that property requests recompute the spatial
%info as necessary

end
