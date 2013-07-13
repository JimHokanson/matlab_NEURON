function result_obj = sim__determine_threshold(obj,starting_value)
%sim__determine_threshold
%
%   result_obj = sim__determine_threshold(obj,starting_value)
%
%   result_obj = sim__determine_threshold(obj,threshold_sign)
%
%   INPUTS
%   =======================================================================
%   starting_value : (units uA), This is the starting value to test for
%           finding a stimulus threshold.
%   threshold_sign : The sign of the threshold is based on the sign of the
%       input. At a minimum a positive or negative number should be
%       specified to determine if the applied stimuli are multiplied by a
%       positive or negative number to determine threshold.
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
%   FULL PATH: 
%       NEURON.simulation.extracellular_stim.sim_determine_threshold

    if ~exist('starting_value','var')
        error('A starting stimulus value must be specified')
    end

    %Important call to make sure everything is synced
    obj.init__simulation();
    
    %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    result_obj = obj.threshold_analysis_obj.determine_threshold(starting_value);
end