function populate_axon_length_info(obj)
%populate_axon_length_info  Goal is to calculate the length of each segment
%
%   POPULATES:
%   =======================================================================
%   .L_all
%
%   See Also:
%       NEURON.cell.axon.MRG.populateSpatialInfo        %Known Caller
%       NEURON.cell.axon.MRG.populate_section_id_info
%       NEURON.cell.axon.MRG.populate_xyz

node_internode_lengths = [...
    p.node_length
    p.paranode_length_1
    p.paranode_length_2
    repmat(p.stin_seg_length,1,p.n_STIN)
    p.paranode_length_2
    p.paranode_length_1];

obj.L_all = [repmat(node_internode_lengths,1,p.n_segs) p.node_length];

% % % % section_ids_local = obj.section_ids;
% % % % 
% % % % p = obj.props_obj; %(Class NEURON.cell.axon.MRG.props) 
% % % % n_sections_total = length(section_ids_local);
% % % % L_all            = zeros(1,n_sections_total);
% % % % 
% % % % [~,uI] = unique2(section_ids_local); %Reduces comparisons
% % % % %NOTE: Ideally we would just use known structure but haven't
% % % % %coded that up yet
% % % % %NOTE: unique values will be 1:4, uI{1} = 1, uI{2} = 2
% % % % 
% % % % L_all(uI{1}) = p.node_length;
% % % % L_all(uI{2}) = p.paranode_length_1;
% % % % L_all(uI{3}) = p.paranode_length_2;
% % % % L_all(uI{4}) = p.stin_seg_length;
% % % % 
% % % % obj.L_all = L_all;



end