function thresholds = getThresholds(obj,cell_locations,threshold_sign)
%
%
%   INPUTS
%   =======================================================================
%   cell_locations : either [samples by xyz] or {x_values y_values z_values}
%
%   See Also:
%       NEURON.simulation.extracellular_stim.
%
%   FullPath: 
%       NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Allow extending the predictor object class to use different methods
%
%   TODO: Still need to handle repetition indices ...
%   TODO: It would be nice to have some uncertainty associated with each value 
%   TODO: The predictor method is AWFUL
%   TODO: Handle threshold sign propertly. I don't think I have it being 
%   handled correctly when negative.

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
obj.matching_stim_obj = obj.predictor_obj.getStimuliMatches();

m_obj = obj.matching_stim_obj;
%Any old repeats, throw warning
old_stim_indices_use = find(~m_obj.old_is_duplicate_and_not_ref);
if length(old_stim_indices_use) ~= length(m_obj.old_is_duplicate_and_not_ref)
    fprintf(2,'Old applied stimuli have duplicates present, run SOMETHING to clean up\n');
    %NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
    %Need access method in xstim class
end

%These are the indices that we will test further in the function below
new_stim_indices__get_threshold = find(~m_obj.new_is_duplicate_and_not_ref);

new_stim_redundant_indices_with_old_source = ...
            find(m_obj.new_is_duplicate_and_not_ref & m_obj.new_duplicate_has_old_source);
new_stim_redundant_indices_with_new_source = ...
            find(m_obj.new_is_duplicate_and_not_ref & ~m_obj.new_duplicate_has_old_source);

old_stim_redundant_index_sources = m_obj.first_index_of_new_duplicate(new_stim_redundant_indices_with_old_source);        

thresholds(new_stim_redundant_indices_with_old_source) = ...
        obj.threshold_values(old_stim_redundant_index_sources);

if isempty(new_stim_indices__get_threshold)
    return
end

%Step 3 - Find unmatched stimuli & create reasonable running groups
%--------------------------------------------------------------------------
groups_of_indices_to_run = obj.predictor_obj.getGroups(...
                old_stim_indices_use,...
                new_stim_indices__get_threshold);

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

for iGroup = 1:n_groups
    
   t_group = tic; 
    
   current_indices = groups_of_indices_to_run{iGroup};
   n_indices       = length(current_indices);
   
   %Threshold prediction
   %-----------------------------------------------------------------------   
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
          fprintf(2,'WHAT WENT WRONG THAT I HAVE NAN')
      end
      keyboard
   end

   %TODO: Evaluate performance, consider stopping due to known answer ...
   
   
   thresholds(current_indices) = thresholds_local;
   
   threshold_errors = predicted_thresholds - thresholds_local';
   avg_error = mean(abs(threshold_errors));
   
   if iGroup ~= 1
      threshold_options_obj.changeGuessAmount(2*avg_error);
   end
   
   
   obj.addResults(applied_stimulus(current_indices,:),thresholds_local,cell_locations(current_indices,:));
   
   time_run_single_group = toc(t_group);
   
   cur_sim_index = cur_sim_index + n_indices;
   fprintf(2,'Finished %d of %d, avg time per sim: %0.3g, Avg Error Last Run: %0.3g\n',...
       cur_sim_index,n_sims_total,time_run_single_group/n_indices,avg_error);
   
end
toc

%TODO: Handle repetition values here ...

keyboard

end