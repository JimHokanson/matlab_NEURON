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
    'number_internodes'             p.number_internodes
    'node_length'                   p.node_length
    'node_diameter'                 p.node_diameter
    'node_capacitance'              p.node_capacitance
    'myelin_n_segs'                 p.myelin_n_segs
    'myelin_length'                 p.myelin_length
    'fiber_diameter'                p.fiber_diameter
    'myelin_conductance'            p.myelin_conductance
    'myelin_capacitance'            p.myelin_capacitance
    'node_dynamics'                 p.node_dynamics};


if value_array_only
   p_v = [p_v{:,2}]; 
end
