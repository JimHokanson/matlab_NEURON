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
%   FullPath: NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds



if iscell(cell_locations)
   [X,Y,Z] = meshgrid(cell_locations{:});
   cell_locations = [X(:) Y(:) Z(:)];
end




%Step 1 - retrieve applied potential - make a method ...
%-------------------------------------------------------------------------
[applied_stimulus,samples_per_time] = obj.getAppliedStimulus(cell_locations,threshold_sign);

obj.n_points_per_cell = samples_per_time;

%Step 2 - Find Previous matches
%--------------------------------------------------------------------------
[is_matched,thresholds] = obj.getPreviousMatches(applied_stimulus,threshold_sign);

unmatched_indices = find(~is_matched);
if isempty(unmatched_indices)
    return
end

%Step 3 - Find unmatched stimuli & create reasonable running groups
%--------------------------------------------------------------------------
predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor();
groups_of_indices_to_run = predictor_obj.getGroups(...
    applied_stimulus(unmatched_indices,:),...
    cell_locations(unmatched_indices,:),...
    obj.applied_stimulus_matrix,...
    obj.threshold_values,...
    obj.xyz_center);

n_groups = length(groups_of_indices_to_run);

%Step 4 - Get thresholds for remaining data
%--------------------------------------------------------------------------
xstim_obj = obj.xstim_obj;
cell_obj  = xstim_obj.cell_obj;
for iGroup = 1:n_groups
   current_indices =  unmatched_indices(groups_of_indices_to_run{iGroup});
   
   n_indices = length(current_indices);
   
   %TODO: Predict threshold - separate method
   %TODO: It would be nice to have some uncertainty associated with each value
   
   thresholds_local = zeros(1,n_indices);
   starting_value = threshold_sign;
   for iIndex = 1:n_indices
      current_index = current_indices(iIndex); 
      
      %Move cell 
      cell_obj.moveCenter(cell_locations(current_index,:));
      
      %NEURON.simulation.extracellular_stim.sim__determine_threshold
      %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
      %NEURON.simulation.extracellular_stim.results.threshold_testing_history
      result_obj = xstim_obj.sim__determine_threshold(starting_value);
      
      thresholds_local(current_index) = result_obj.stimulus_threshold;
      
      %Do test
      
   end
   
   thresholds(current_indices) = thresholds_local;
   
   obj.addResults(applied_stimulus(current_indices,:),thresholds_local,cell_locations(current_indices,:));
   
   
end


keyboard

end