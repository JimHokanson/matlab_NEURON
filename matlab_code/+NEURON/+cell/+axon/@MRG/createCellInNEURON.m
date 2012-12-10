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

cdToModelDirectory(obj)

%Shortening variable for easier reference in code below
c = obj.cmd_obj; %Class: Neuron.cmd

%This allows us to insert the MRG channel dynamics
c.load_dll('mod_files/nrnmech.dll');

%This puts all of the variables that are specific to the MRG model into
%NEURON, so that the hoc code below works.
placeVariablesInNEURON(obj.props_obj,c)

%Run the hoc file
c.load_file('create_mrg_axon.hoc');

%NEURON.cell.axon.MRG.populateSpatialInfo
%This will allow us to know things about the 3d spatial setup of the model
%for applying the correct extracellular stimulus to it later

%NEURON.cell.axon.MRG.populateSpatialInfo
populateSpatialInfo(obj)

obj.cell_populated_in_NEURON = true;

end
