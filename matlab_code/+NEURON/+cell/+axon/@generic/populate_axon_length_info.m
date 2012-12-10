function populate_axon_length_info(obj)
%
%   Goal is to calculate the length of each segment
%
%   NOTE: This could be simplified a bit
%   1 - node
%   2 - myeline
%   3 - FLUT - paranode 2
%   4 - n??? - STIN (see n_STIN
%   n+1 FLUT
%   MYSA
%   repeat
%   cap with a node
%
%   See Also:
%       NEURON.cell.axon.MRG.populateSpatialInfo   %Known Caller
%       NEURON.cell.axon.MRG.populate_section_id_info
%       NEURON.cell.axon.MRG.populate_xyz

%START OF CLEANER APPROACH
%repeat_n = 5 + p.n_STIN


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