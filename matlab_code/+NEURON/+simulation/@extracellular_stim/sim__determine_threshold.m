function result_obj = sim__determine_threshold(obj,starting_value)
%sim__determine_threshold
%
%   result_obj = sim__determine_threshold(obj,starting_value)
%
%   OUTPUTS
%   =======================================================================
%   result_obj : NEURON.simulation.extracellular_stim.results.threshold_testing_history
%
%   This method works closely with the following class:
%       NEURON.threshold_cmd
%   This class is available as the property:
%       .threshold_cmd_obj
%
%   See Also:
%       NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
%       NEURON.simulation.extracellular_stim.threshold_analysis
%       NEURON.simulation.extracellular_stim.results.threshold_testing_history
%
%   FULL PATH: NEURON.simulation.extracellular_stim.sim_determine_threshold

    %Important call to make sure everything is synced
    initSystem(obj.ev_man_obj)
    
    setupThresholdInfo(obj)

    result_obj = obj.threshold_analysis_obj.determine_threshold(starting_value);
end