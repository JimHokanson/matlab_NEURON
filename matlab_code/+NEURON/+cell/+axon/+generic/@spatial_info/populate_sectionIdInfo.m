function populate_sectionIdInfo(obj)
%populate_section_id_info
%
%   Section IDs refer to values which distinguish
%   between nodes and internodes 
%
%   POPULATES
%   ==================================
%   .section_ids
%   .center_I

p = obj.props_obj;
%NOTE HARDCODED ASSUMPTION -------------
obj.section_ids = [repmat([1 2*ones(1,p.myelin_n_segs)],1,p.number_internodes) 1];
node_I          = find(obj.section_ids == 1);
obj.center_I    = node_I(ceil(length(node_I)/2));


end