function result_obj = sim__single_stim(obj,scale,auto_expand)
%sim__single_stim
%
%   result_obj = sim__single_stim(obj,scale)
%
%   This function runs a single extracellular stimulation and returns the
%   result to the user.
%
%   INPUTS
%   =======================================================================
%   scale: This is the factor that gets multipled by the stimulus waveform
%          to determine the final stimulus amplitude. Units: uA
%
%   OUTPUTS
%   =======================================================================
%   result_obj: Class: NEURON.simulation.extracellular_stim.results.single_sim
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim__determine_threshold
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.sim__single_stim

if ~exist('auto_expand','var')
    auto_expand = false;
end

%Important call to make sure everything is synced
obj.init__simulation();

if ~exist('scale','var')
    error('Scale input must be provided')
end

%NEURON.simulation.extracellular_stim.threshold_analysis
result_obj = obj.threshold_analysis_obj.run_stimulation(scale,auto_expand);

end