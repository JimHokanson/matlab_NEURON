function populate_spatialInfo(obj)


if ~obj.sptial_info_up_to_date
   
    p = obj.props_obj;
    n_segs = p.n_segs;
    
    % populate section ID info
    obj.section_ids = ones(1,n_segs);
    obj.center_I = ceil(nsegs)/2;
    
    % populate axon length info
    obj.L_all = p.axon_length*ones(1,n_segs);
    
    % populate xyz
    populate_xyz(obj)
    
    % avg node spacing -- not relevant here, but is it needed?
    
    
end
end