function predictor_info = getThresholds(obj)
%
%
%   predictor_info = getThresholds(obj)
%
%   This is a specific implementation for getting thershold data.
%
%   This implementation:
%   -----------------------------------------------------------------------
%   1) Reduces the # of points to solve by finding redundant applied stimuli
%
%
%   FULL PATH:
%   =======================================================================
%   NEURON.xstim.single_AP_sim.predictor.default.getThreshold

%Reduction in the # of points to solve for by finding redundant applied stimuli 
obj.stimulus_manager.reducePointsToSolveByMatchingStimuli();

keyboard

g = obj.grouper;
indices = g.getNextGroup();

while ~isempty(indices)

    %NEURON.xstim.single_AP_sim.predictor.predictThresholds
    predicted_thresholds = obj.predictThresholds(indices);
    
    threshold_result_obj = obj.getThresholdsFromSimulation(indices,predicted_thresholds);

    %NOT YET FINISHED
    threshold_result_obj.logResults();
    
    
    
    %Log results, analyze accuracy, update guessing accordingly ...
    indices = g.getNextGroup();

    if ~isempty(indices)
        
    end
end

%Remaining steps:
%1) Create prediction for indices to run
%    - this class will also for resolution updates ...
%2) Solve for indices
%3) Update results
%4) Create summary of how we did


keyboard

%possible early return
if obj.all_done
    return
end


end