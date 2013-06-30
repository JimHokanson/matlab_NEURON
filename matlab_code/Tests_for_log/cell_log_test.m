function cell_log_test()
%
%
%   IMPROVEMENTS
%   =====================================================
%   1) Pass in testing directory
%   2) Get all properties and toggle all
%   3) create novel and test for invalid ID with create_new = false

ids = cell(1,6);

rules = [1 2 0;
         2 3 0;
         1 4 1;
         1 5 0;
         1 6 0];

%First sim ================================================================
sim1 =  NEURON.simulation.extracellular_stim.create_standard_sim();
cell_obj = sim1.cell_obj;
ids{1} = getID(cell_obj);

%Change FiberDiameter =====================================================
cell_obj.props_obj.changeFiberDiameter(8.7);
ids{2} = getID(cell_obj);

%Back to original =========================================================
cell_obj.props_obj.changeFiberDiameter(10);
ids{3} = getID(cell_obj);

%Second Sim ===============================================================
sim2 =  NEURON.simulation.extracellular_stim.create_standard_sim();
cell_obj = sim2.cell_obj;
ids{4} = getID(cell_obj);

%Random prop change =======================================================
cell_obj.props_obj.changeProperty('xc_node', 7);
ids{5} = getID(cell_obj);

cell_obj = sim1.cell_obj;
cell_obj.props_obj.changeProperty('xc_node', 17);
ids{6} = getID(cell_obj);

n_rules = size(rules,1);
for iRule = 1:n_rules
   cur_row = rules(iRule,:);
   flag = ids{cur_row(1)} == ids{cur_row(2)};
   if flag ~= logical(cur_row(3))
       error('Mismatch for ID #%d',iRule)
   end
end


end

function ID = getID(cell_obj)
    log = cell_obj.getLogger;
    ID = log.find(true);
end

%
% FIBER_DEPENDENT_PROPERTIES = {'node_diameter' 'paranode_diameter_1' ...
%     'paranode_diameter_2' 'axon_diameter' 'paranode_length_2'
%     'internode_length' ... 'stin_seg_length' 'number_lemella'
%     'rho_axial_i' 'rho_axial_1' 'rho_axial_2' ... 'cm_i' 'cm_1' 'cm_2'
%     'g_1' 'g_2' 'g_i' 'g_pas_i' 'g_pas_1' 'g_pas_2' 'xraxial_node' ...
%     'xraxial_1' 'xraxial_2' 'xraxial_i' 'xg_1' 'xg_2' 'xg_i' 'xc_1'
%     'xc_2' ... 'xc_i'}

% NON_FIBER_DEPENDENT_PROPERTIES = {'node_length' 'paranode_length_1' ...
%     'space_p1' 'space_p2' 'space_i' 'n_STIN' 'n_internodes' 'v_init' ...
%     'rho_periaxonal' 'rho_axial_node' 'cap_nodal' 'cap_internodal'
%     'cap_myelin' ... 'g_myelin' 'xg_node' 'xc_node'}

%   changeFiberDiameter(obj,new_fiber_diameter)
%   um choose from 5.7, 7.3, 8.7, 10.0, 11.5, 12.8, 14.0, 15.0, 16.0
%
%   changeProperty(obj,varargin)

