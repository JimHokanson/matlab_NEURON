function populate_axonLengthInfo(obj)
%
%   Goal is to calculate the length of each segment
%
%
%
%   FULL PATH
%       NEURON.cell.axon.generic.spatial_info.populate_axonLengthInfo
%
%
%   See Also:
%       NEURON.cell.axon.generic.props
%       NEURON.cell.axon.generic.spatial_info.
%   
%
% Populates: 
%  .L_all
%
%   NOTE: This could be simplified a bit
%   1 - node
%   2 - myelin
%   repeat
%   cap with a node
%
%   See Also:
%       NEURON.cell.axon.generic.populateSpatialInfo   %Known Caller
%       NEURON.cell.axon.generic.populate_section_id_info
%       NEURON.cell.axon.generic.populate_xyz

section_ids_local = obj.section_ids;
p = obj.props_obj; %(Class NEURON.cell.axon.generic.props) 
n_sections_total = length(section_ids_local);

L_all            = zeros(1,n_sections_total);
L_all(section_ids_local == 1) = p.node_length;
L_all(section_ids_local == 2) = p.myelin_length./p.myelin_n_segs;

obj.L_all = L_all;

end