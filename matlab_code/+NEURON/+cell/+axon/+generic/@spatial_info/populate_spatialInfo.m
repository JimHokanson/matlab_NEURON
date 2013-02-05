function populate_spatialInfo(obj)
%populateSpatialInfo
%
%   Populates spatial info. Ultimately the most important propery this
%   populates is xyz
%
%   KNOWN CALLERS:
%   =======================================================================
%   1) NEURON.simulation.extracellular_stim.event_manager.initSystem
%       => NEURON.cell.axon.generic.createCellInNEURON 
%   
%   2) General requests for xyz data from the cell
%
%   IMPROVEMENTS
%   =======================================================================
%   1) These functions should probably rely more on methods of:
%           NEURON.cell.axon.generic.props instead of making the assumptions
%           that they do regarding the spatial layout of the cell
%
%   See Also:
%       NEURON.cell.axon.MRG.spatial_info.populate_sectionIdInfo
%       NEURON.cell.axon.MRG.spatial_info.populate_axonLengthInfo
%       NEURON.cell.axon.MRG.populate_xyz
%
%   FULL PATH: NEURON.cell.axon.generic.spatial_info.populate_spatialInfo

%NOTE: When spatial props are changed in the props
%class, this property below is changed to be false
if ~obj.spatial_info_up_to_date

%NEURON.cell.axon.generic.spatial_info.populate_sectionIdInfo
obj.populate_sectionIdInfo();

%NEURON.cell.axon.generic.spatial_info.populate_axonLengthInfo
populate_axonLengthInfo(obj)

%NEURON.cell.axon.generic.spatial_info.populate_xyz
populate_xyz(obj)

%node_indices     = find(obj.section_ids == 1);
obj.avg_node_spacing = abs(mean(diff(obj.xyz_all(obj.section_ids == 1),3)));

end