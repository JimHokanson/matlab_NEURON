function populate_axonLengthInfo(obj)
%populate_axonLengthInfo  Goal is to calculate the length of each segment
%
%   POPULATES:
%   =======================================================================
%   .L_all
%
%   See Also:
%       NEURON.cell.axon.MRG.spatial_info.populate_spatialInfo   %Known Caller


p = obj.props_obj; %(Class NEURON.cell.axon.MRG.props) 

%NOTE HARDCODED ASSUMPTIONS -----------------------------------------------
node_internode_lengths = [...
    p.node_length
    p.paranode_length_1
    p.paranode_length_2
    repmat(p.stin_seg_length,p.n_STIN,1)
    p.paranode_length_2
    p.paranode_length_1]'; %Make row vector, current layout implies column vector

obj.L_all = [repmat(node_internode_lengths,1,p.n_internodes) p.node_length];

end