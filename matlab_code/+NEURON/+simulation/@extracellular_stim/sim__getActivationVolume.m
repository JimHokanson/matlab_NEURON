function act_obj = sim__getActivationVolume(obj,varargin)
%
%   act_obj = sim__getActivationVolume(obj)
%
%   OUTPUTS
%   =======================================================================
%   act_obj : Class: NEURON.simulation.extracellular_stim.results.activation_volume
%
%   FULL PATH:
%   =======================================================================
%   NEURON.simulation.extracellular_stim.sim__getActivationVolume

act_obj = NEURON.simulation.extracellular_stim.results.activation_volume(obj,varargin{:});


end