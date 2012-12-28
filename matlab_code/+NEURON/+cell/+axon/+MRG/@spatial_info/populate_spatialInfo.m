function populate_spatialInfo(obj)
%populateSpatialInfo
%
%   Populates spatial info. Ultimately the most important propery this
%   populates is xyz
%
%   KNOWN CALLERS:
%   =======================================================================
%   1) NEURON.simulation.extracellular_stim.event_manager.initSystem
%       => NEURON.cell.axon.MRG.createCellInNEURON
%   
%   2) General requests for xyz data from the cell
%
%   IMPROVEMENTS
%   =======================================================================
%   1) These functions should probably rely more on methods of:
%           NEURON.cell.axon.MRG.props instead of making the assumptions
%           that they do regarding the spatial layout of the cell
%
%   See Also:
%
%   NOTE: These links are out of date
%
%       NEURON.cell.axon.MRG.populate_section_id_info
%       NEURON.cell.axon.MRG.populate_axon_length_info
%       NEURON.cell.axon.MRG.populate_xyz

%NOTE: When spatial props are changed in the props
%class, this property below is changed to be false
if ~obj.spatial_info_up_to_date

%NEURON.cell.axon.MRG.populate_section_id_info
populate_section_id_info(obj)

%NEURON.cell.axon.MRG.populate_axon_length_info
populate_axon_length_info(obj)

%NEURON.cell.axon.MRG.populate_xyz
populate_xyz(obj)

%node_indices     = find(obj.section_ids == 1);
obj.avg_node_spacing = abs(mean(diff(obj.xyz_all(obj.section_ids == 1),3)));

end