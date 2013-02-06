function populate_spatialInfo(obj)


if ~obj.spatial_info_up_to_date
   
    p = obj.props_obj;
    n_segs = p.n_segs;
    
    % populate section ID info
    obj.section_ids = ones(1,n_segs);
    obj.center_I = ceil(n_segs)/2;
    
    % populate axon length info
    obj.L_all = (p.axon_length/n_segs)*ones(1,n_segs);
    
    % populate xyz
    populate_xyz(obj)
    
    % avg node spacing - entire axon is composed of "nodes" but still must
    % be determined
    obj.avg_node_spacing = abs(mean(diff(obj.xyz_all(:,3))));
    
    
end
end