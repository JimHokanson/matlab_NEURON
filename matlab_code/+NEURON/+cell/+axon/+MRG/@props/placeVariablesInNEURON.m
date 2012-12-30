function placeVariablesInNEURON(obj,c)
%placeVariablesInNEURON
%
%   placeVariablesInNEURON(obj,c)
%
%   INPUTS
%   =======================================================================
%   c : class NEURON.cmd, this is the main class that allows us to run
%   commands in NEURON. 
%
%   IMPROVEMENTS
%   =======================================================================
%   NOTE: Eventually we could only place into NEURON any variables that
%   have changed 


if obj.n_STIN ~= 6
    error('Code doesn''t handle changing this yet')
end

p_v = obj.getPropertyValuePairing();

%PUKE VARIABLES INTO NEURON
c.writeNumericProps(p_v(:,1),p_v(:,2));

%Update dirty bit
obj.props_up_to_date_in_NEURON = true;