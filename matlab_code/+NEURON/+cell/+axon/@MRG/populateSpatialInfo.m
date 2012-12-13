function populateSpatialInfo(obj)
%populateSpatialInfo
%
%   Populates spatial info. Ultimately the most important propery this
%   populates is xyz
%
%   KNOWN CALLERS:
%   =======================================================================
%   NEURON.simulation.extracellular_stim.event_manager.initSystem
%       => NEURON.cell.axon.MRG.createCellInNEURON
%
%   IMPROVEMENTS
%   =======================================================================
%   1) These functions should probably rely more on methods of:
%           NEURON.cell.axon.MRG.props instead of making the assumptions
%           that they do regarding the spatial layout of the cell
%
%   See Also:
%       NEURON.cell.axon.MRG.populate_section_id_info
%       NEURON.cell.axon.MRG.populate_axon_length_info
%       NEURON.cell.axon.MRG.populate_xyz

if ~obj.props_populated
    obj.props_obj.populateDependentVariables();
end

%NEURON.cell.axon.MRG.populate_section_id_info
populate_section_id_info(obj)

%NEURON.cell.axon.MRG.populate_axon_length_info
populate_axon_length_info(obj)

%NEURON.cell.axon.MRG.populate_xyz
populate_xyz(obj)

%node_indices     = find(obj.section_ids == 1);
obj.avg_node_spacing = abs(mean(diff(obj.xyz_all(obj.section_ids == 1),3)));