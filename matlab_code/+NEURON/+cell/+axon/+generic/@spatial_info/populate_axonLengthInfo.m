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
%       NEURON.cell.axon.MRG.populateSpatialInfo   %Known Caller
%       NEURON.cell.axon.MRG.populate_section_id_info
%       NEURON.cell.axon.MRG.populate_xyz

%START OF CLEANER APPROACH
%repeat_n = 5 + p.n_STIN

%{
sid_node_internode = repmat([1 2*ones(1,p.n_segs_myelin)]);

sid_total = [repmat(sid_node_internode,[1 p.n_internodes]) 1];

1 2 2 2 2 2 2 2     1 2 2 2 2 2 2       1

L(sid_total == 1) = p.node_length;
L(sid_total == 2) = p.myelin_length;

%}



section_ids_local = obj.section_ids;
p = obj.props_obj; %(Class NEURON.cell.axon.MRG.props) 
n_sections_total = length(section_ids_local);
L_all            = zeros(1,n_sections_total);
[~,uI] = unique2(section_ids_local); %Reduces comparisons
%NOTE: Ideally we would just use known structure but haven't
%coded that up yet
%NOTE: unique values will be 1:2, uI{1} = 1, uI{2} = 2

L_all(uI{1}) = p.node_length;
L_all(uI{2}) = p.myelin_length;

obj.L_all = L_all;



end