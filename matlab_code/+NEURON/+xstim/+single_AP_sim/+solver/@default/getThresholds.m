function predictor_info = getThresholds(obj)
%
%
%   predictor_info = getThresholds(obj)
%
%   This is a specific implementation for getting threshold data.
%
%   This implementation:
%   -----------------------------------------------------------------------
%   1) Reduces the # of points to solve by finding redundant applied stimuli
%   2) 
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.predictor.default.getThreshold

predictor_info = []; %Not sure what I want to put here ....

%Reduction in the # of points to solve for by finding redundant applied stimuli
%NEURON.xstim.single_AP_sim.applied_stimulus_manager.reducePointsToSolveByMatchingStimuli
obj.stimulus_manager.reducePointsToSolveByMatchingStimuli();

if obj.new_data.all_done
   return 
end

%NEURON.xstim.single_AP_sim.new_solution.summarize
obj.new_data.summarize();

%NEURON.xstim.single_AP_sim.grouper
g = obj.grouper;
t_group = tic;
indices = g.getNextGroup();
n_indices = length(indices);

p_local = obj.predicter;
b_local = obj.binary_search_adjuster;
cur_sim_index = 0;

%TODO: Change time for maximum stimulus here to avoid warning messing
%things up ...


while ~isempty(indices)
    
    fprintf('%s %d:%d =>',datestr(now,'HH:MM:SS'),cur_sim_index+1,cur_sim_index+n_indices) 
    %NEURON.xstim.single_AP_sim.predicter.predictThresholds
    predicted_thresholds = p_local.predictThresholds(indices);
    
    fprintf('Prediction: %0.1fs, ',toc(t_group))
    
    threshold_result_obj = obj.getThresholdsFromSimulation(indices,predicted_thresholds);
    %Class: NEURON.xstim.single_AP_sim.threshold_simulation_results

    threshold_result_obj.logResults();

    fprintf('Last Index: %d, group avg time: %0.3g, error: %0.3g\n',...
        cur_sim_index,toc(t_group)/n_indices,threshold_result_obj.avg_error);
    
    cur_sim_index = cur_sim_index + n_indices;

    %Start of the next loop
    %----------------------------------------------------------------------
    %The grouper might eventually want the previous results
    t_group   = tic;
    indices   = g.getNextGroup();
    n_indices = length(indices);
    
    if ~isempty(indices)
        %analyze accuracy, update guessing accordingly ...
        b_local.adjustSearchParameters(threshold_result_obj)
    end
end

%????


end