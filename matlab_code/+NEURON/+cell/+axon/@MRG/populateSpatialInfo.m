function populateSpatialInfo(obj)
%populateSpatialInfo
%
%   TODO: Describe function
%
%
%   KNOWN CALLERS:
%   ==================================================
%       createCellInNEURON
%       NEURON.simulation.extracellular_stim.event_manager.initSystem;  
%
%   Need to include more about assumptions ...

if ~obj.props_populated
    obj.props_obj.populateDependentVariables();
end

%NEURON.cell.axon.MRG.populate_section_id_info
populate_section_id_info(obj)

%NEURON.cell.axon.MRG.populate_axon_length_info
populate_axon_length_info(obj)

%NEURON.cell.axon.MRG.populate_xyz
populate_xyz(obj)

