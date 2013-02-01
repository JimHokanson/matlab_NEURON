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
    'axon_capacitance'             p.axon_capacitance
    'axial_resistivity'            p.axial_resistivity
    'axon_length'                  p.axon_length
    'axon_diameter'                p.axon_diameter
    'n_segs'                       p.n_segs
    'axon_dynamics'                p.axon_dynamics
};


if value_array_only
   p_v = [p_v{:,2}]; 
end
