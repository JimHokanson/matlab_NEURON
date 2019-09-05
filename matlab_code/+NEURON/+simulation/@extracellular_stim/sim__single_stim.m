function result_obj = sim__single_stim(obj,scale,auto_expand)
%sim__single_stim
%
%   result_obj = sim__single_stim(obj,scale,*auto_expand)
%
%   This function runs a single extracellular stimulation and returns the
%   result to the user.
%
%   Inputs
%   ------
%   scale: (Units: uA) 
%       This is the factor that gets multipled by the stimulus waveform to 
%       determine the final stimulus amplitude. 
%
%   Optional Inputs
%   ---------------
%   auto_expand : (default false) 
%       If true the simulation will be expanded until the recorded membrane
%       potential is no longer rising. Specific rules for expansion are
%       handled in:
%           NEURON.simulation.extracellular_stim.threshold_analysis
%       
%       
%
%   Outputs
%   -------
%   result_obj: NEURON.simulation.extracellular_stim.results.single_sim
%
%   See Also
%   --------
%   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
%   NEURON.simulation.extracellular_stim.sim__determine_threshold
%   NEURON.simulation.extracellular_stim.results.single_sim
%
%   Full Path
%   ---------
%   NEURON.simulation.extracellular_stim.sim__single_stim

if ~exist('scale','var')
    error('Scale input must be provided')
end

if ~exist('auto_expand','var')
    auto_expand = false;
end

%Important call to make sure everything is synced
%NEURON.simulation.extracellular_stim.init__simulation
obj.init__simulation();

%NEURON.simulation.extracellular_stim.threshold_analysis
result_obj = obj.threshold_analysis_obj.run_stimulation(scale,auto_expand);

end