clear_classes
clc

%First sim ================================================================
sim1 =  NEURON.simulation.extracellular_stim.create_standard_sim();
cell = sim1.cell_obj;
log = cell.getLogger;
ID1 = log.find(true);

%Change FiberDiameter =====================================================
cell.props_obj.changeFiberDiameter(8.7);
log = cell.getLogger;
ID2 = log.find(true);

%Back to original =========================================================
cell.props_obj.changeFiberDiameter(10);
log = cell.getLogger;
ID3 = log.find(true);

%Second Sim ===============================================================
sim2 =  NEURON.simulation.extracellular_stim.create_standard_sim();
cell = sim2.cell_obj;
log = cell.getLogger;
ID4 = log.find(true);

%Random prop change =======================================================
cell.props_obj.changeProperty('xc_node', 7);
log = cell.getLogger;
ID5 = log.find(true);

cell = sim1.cell_obj;
cell.props_obj.changeProperty('xc_node', 17);
log = cell.getLogger;
ID6 = log.find(true);


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

