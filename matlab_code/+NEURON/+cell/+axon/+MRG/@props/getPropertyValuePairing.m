function [p_v,PV_VERSION] = getPropertyValuePairing(obj,value_array_only)
%
%   p_v = getPropertyValuePairing(obj,*value_array_only)
%
%   INPUTS
%   =====================================================================
%   value_array_only : (default false), if true only the values are
%                      returned
%
%   NOTE: This was put into its own function to allow
%   dual access by:
%   1) placeVariablesInNEURON
%   2) the simulation logger for comparision of models
%   
%   IMPROVEMENTS:
%   ======================================================
%   Sadly this takes a decent amount of time to construct.
%   It would be better to only construct once when
%   necessary ...

PV_VERSION = 1;

%NOTE: If we ever need to change this, we could update this to invalidate
%comparisons between old and new, MAYBE

if ~exist('value_array_only','var')
   value_array_only = false; 
end

p = obj;

p_v = {...
    'v_init'            p.v_init
    'axonnodes'         p.n_internodes+1
    'paranodes1'        p.n_internodes*2
    'paranodes2'        p.n_internodes*2
    'axoninter'         p.n_STIN*p.n_internodes
    'node_diameter'     p.node_diameter
    'node_length'       p.node_length
    'rho_axial_node'    p.rho_axial_node
    'cap_nodal'         p.cap_nodal
    'xraxial_node'      p.xraxial_node
    'xg_node'           p.xg_node
    'xc_node'           p.xc_node
    'fiber_diameter'    p.fiber_diameter
    'paranode_length_1' p.paranode_length_1
    'rho_axial_1'       p.rho_axial_1
    'cm_1'              p.cm_1
    'g_pas_1'           p.g_pas_1
    'xraxial_1'         p.xraxial_1
    'xg_1'              p.xg_1
    'xc_1'              p.xc_1
    'paranode_length_2' p.paranode_length_2
    'rho_axial_2'       p.rho_axial_2
    'cm_2'              p.cm_2
    'g_pas_2'           p.g_pas_2
    'xraxial_2'         p.xraxial_2
    'xg_2'              p.xg_2
    'xc_2'              p.xc_2
    'stin_seg_length'   p.stin_seg_length
    'rho_axial_i'       p.rho_axial_i
    'cm_i'              p.cm_i
    'g_pas_i'           p.g_pas_i
    'xraxial_i'         p.xraxial_i
    'xg_i'              p.xg_i
    'xc_i'              p.xc_i};

if value_array_only
   p_v = [p_v{:,2}]; 
end
