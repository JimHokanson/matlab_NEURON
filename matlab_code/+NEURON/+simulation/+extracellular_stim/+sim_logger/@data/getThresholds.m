function thresholds = getThresholds(obj,cell_locations,threshold_sign)
%
%
%   INPUTS
%   =======================================================================
%   cell_locations : either [samples by xyz] or {x_values y_values z_values}
%   threshold_sign : Whether the stimulus should look for a positive or
%           negative threshold. Expected values are 1 (positive) or -1 (negative).
%           See paragraph below for more details.
%
%   Threshold Sign Handling
%   -----------------------------------------------------------------------
%   If the threshols sign is negative, the applied stimuli are multiplied
%   by -1 so as to find a positive threshold. This is of course equivalent
%   to a negative threshold with the originally applied stimuli, before
%   multiplying by -1. Before returning thresholds from this function the
%   threshold is once again flipped so as to provide negative thresholds.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Allow extending the predictor object class to use different methods
%   2) It would be nice to have some uncertainty associated with each value
%   3) The predictor method is AWFUL
%   4) Create a simulation class which allows simulating the results of
%   this class for testing results
%   5) Create a results summary class
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim_logger.getThresholds
%       NEURON.simulation.extracellular_stim.sim__create_logging_data
%
%   FullPath:
%       NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds

obj.desired_threshold_sign = threshold_sign;

if iscell(cell_locations)
    [X,Y,Z] = meshgrid(cell_locations{:});
    cell_locations = [X(:) Y(:) Z(:)];
end
obj.new_cell_locations = cell_locations;

n_new_inputs_total = size(cell_locations,1);

thresholds = NaN(1,n_new_inputs_total);

%Step 1 - retrieve applied potential
%--------------------------------------------------------------------------
%NEURON.simulation.extracellular_stim.sim_logger.data.getAppliedStimulus
obj.setNewAppliedStimulus();

%Step 2 - create predictor object
%--------------------------------------------------------------------------
obj.predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor(...
    obj.new_stimuli_matrix,...
    obj.applied_stimulus_matrix,...
    obj.xyz_center,....
    obj.new_cell_locations,...
    obj.threshold_values);

%Step 2 - Find Previous matches & redundant old stimuli ...
%--------------------------------------------------------------------------
%NEURON.simulation.extracellular_stim.threshold_predictor.getStimuliMatches
obj.matching_stim_obj = obj.predictor_obj.getStimuliMatches();

m_obj = obj.matching_stim_obj;
%Any old repeats, throw warning
old_stim_indices_use = find(~m_obj.old_index_for_redundant_old_source__mask);
if length(old_stim_indices_use) ~= m_obj.n_old
    fprintf(2,'Old applied stimuli have duplicates present, run SOMETHING to clean up\n');
    %NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
    %Need access method in xstim class
end

%These are the indices that we will test further in the function below
new_stim_indices__get_threshold = m_obj.new_source_indices_to_learn;

thresholds(m_obj.old_index_for_redundant_new_source__mask) = ...
    obj.threshold_values(m_obj.old_index_for_redundant_new_source__redundant_only);

if isempty(new_stim_indices__get_threshold)
    thresholds = helper__cleanupThresholds(thresholds,m_obj,threshold_sign);
    return
end

%Step 3 - Find unmatched stimuli & create reasonable running groups
%--------------------------------------------------------------------------
%TODO: This approach should be mexed
groups_of_indices_to_run = obj.predictor_obj.getGroups(old_stim_indices_use,new_stim_indices__get_threshold);

%Step 4 - Get thresholds for remaining data
%--------------------------------------------------------------------------
xstim_obj     = obj.xstim_obj;
cell_obj      = xstim_obj.cell_obj;
t_start_all   = tic;
n_sims_total  = sum(cellfun('length',groups_of_indices_to_run));
cur_sim_index = 0;

%TODO: Eventually we should make a copy of this options
%class so that we aren't mucking with the users options ...
%This is low priority
threshold_options_obj = xstim_obj.threshold_options_obj;

%NOTE: We don't want to set redundant inputs true here as we will use
%this to help with prediction, which won't benefit from redundant
%information
new_threshold_learned_mask = false(1,n_new_inputs_total);

n_groups = length(groups_of_indices_to_run);
for iGroup = 1:n_groups
    
    t_group = tic;
    
    current_indices = groups_of_indices_to_run{iGroup};
    n_indices       = length(current_indices);
    
    %Threshold prediction
    %-----------------------------------------------------------------------
    %NEURON.simulation.extracellular_stim.threshold_predictor.predictThresholds
    predicted_thresholds = obj.predictor_obj.predictThresholds(...
        old_stim_indices_use,...
        find(new_threshold_learned_mask),...
        current_indices,...
        thresholds); %#ok<FNDSB>
    
    thresholds_local = zeros(1,n_indices);
    for iIndex = 1:n_indices
        current_index = current_indices(iIndex);
        
        %Move cell
        cell_obj.moveCenter(cell_locations(current_index,:));
        
        %NEURON.simulation.extracellular_stim.sim__determine_threshold
        %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
        %NEURON.simulation.extracellular_stim.results.threshold_testing_history
        result_obj = xstim_obj.sim__determine_threshold(predicted_thresholds(iIndex));
        
        thresholds_local(iIndex) = result_obj.stimulus_threshold;
        
        if isnan(thresholds_local(iIndex))
            error('Something went wrong, NaN encountered')
        end
    end
    
    new_threshold_learned_mask(current_indices) = true;
    
    %TODO: Evaluate performance. Consider stopping due to known answer ...
    
    
    thresholds(current_indices) = thresholds_local;
    
    
    %Error handling, updating guessing approach to improve binary search
    %----------------------------------------------------------------------
    threshold_errors = predicted_thresholds - thresholds_local';
    avg_error = mean(abs(threshold_errors));
    
    %TODO: This should be moved up to the start
    %We might consider doing this when we have an idea of accuracy ...
    if iGroup ~= 1
        threshold_options_obj.changeGuessAmount(2*avg_error);
    end
    
    %NEURON.simulation.extracellular_stim.sim_logger.data.addResults
    obj.addResults(current_indices,thresholds_local)
    
    time_run_single_group = toc(t_group);
    
    cur_sim_index = cur_sim_index + n_indices;
    fprintf(2,'Finished %d of %d, avg time per sim: %0.3g, Avg Error Last Run: %0.3g\n',...
        cur_sim_index,n_sims_total,time_run_single_group/n_indices,avg_error);
    
end
toc

thresholds = helper__cleanupThresholds(thresholds,m_obj,threshold_sign);

end

function thresholds = helper__cleanupThresholds(thresholds,m_obj,threshold_sign)
%
%
%   thresholds = helper__cleanupThresholds(thresholds,m_obj,threshold_sign)

%Copying of repetitive new indices here ...
%NEURON.simulation.extracellular_stim.threshold_predictor.matching_stimuli
thresholds(m_obj.new_index_for_redundant_new_source__mask) = ...
    thresholds(m_obj.new_index_for_redundant_new_source__redundant_only);

if threshold_sign == -1
    thresholds = -1*thresholds;
end
end