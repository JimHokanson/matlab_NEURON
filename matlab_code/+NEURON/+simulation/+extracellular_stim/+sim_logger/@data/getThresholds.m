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

%Step 1 - retrieve applied potential
%--------------------------------------------------------------------------
%NEURON.simulation.extracellular_stim.sim_logger.data.getAppliedStimulus
obj.setNewAppliedStimulus();

%Step 2 - create predictor object
%--------------------------------------------------------------------------
obj.predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor(...
                        obj.new_stimuli_matrix,...
                        obj.applied_stimulus_matrix);
                    
%Step 2 - Find Previous matches
%--------------------------------------------------------------------------
[is_matched,thresholds] = obj.getPreviousMatches();



is_matched = is_matched'; %Make row vector, TODO: fix in function 

unmatched_indices = find(~is_matched);
if isempty(unmatched_indices)
    return
end

%Step 3 - Dimensionality Reduction
%--------------------------------------------------------------------------


[new_low_dimension,old_low_dimension] = predictor_obj.rereduceDimensions(...
                                            applied_stimulus,obj.applied_stimulus_matrix);

                                        
keyboard                                        
                                        
%NOTE: This is one spot where we can enforce some distance, below which two
%points are considered to be the same ...
%NOT YET IMPLEMENTED ...
if isempty(old_low_dimension)
   red 
else
    
end

%Step 2.5 - Removal of repetitive stimuli 
%-----------------------------------------------------------------
[~,IA] = unique(applied_stimulus(unmatched_indices,:),'rows');

is_repetition_mask     = true(1,length(unmatched_indices));
is_repetition_mask(IA) = false; 
repetition_indices     = unmatched_indices(is_repetition_mask);
unmatched_indices      = unmatched_indices(IA);

%Step 3 - Find unmatched stimuli & create reasonable running groups
%--------------------------------------------------------------------------

[groups_of_indices_to_run,more_repetition_indices] = ...
    predictor_obj.getGroups(...
        applied_stimulus(unmatched_indices,:),...
        cell_locations(unmatched_indices,:),...
        obj.applied_stimulus_matrix,...
        obj.threshold_values,...
        obj.xyz_center);

%Translation of indices back to original indexing level
%--------------------------------------------------------------------------
n_groups = length(groups_of_indices_to_run);
for iGroup = 1:n_groups
   groups_of_indices_to_run{iGroup} = unmatched_indices(groups_of_indices_to_run{iGroup}); 
end
more_repetition_indices = unmatched_indices(more_repetition_indices);    
 
repetition_indices = [repetition_indices more_repetition_indices];

%Step 4 - Get thresholds for remaining data
%--------------------------------------------------------------------------
xstim_obj = obj.xstim_obj;
cell_obj  = xstim_obj.cell_obj;
t_start_all = tic;
n_sims_total  = sum(cellfun('length',groups_of_indices_to_run));
cur_sim_index = 0;

%TODO: Eventually we should make a copy of this class so that we aren't
%mucking with the users options ...
%This is low priority

thershold_options_obj = xstim_obj.threshold_options_obj;

for iGroup = 1:n_groups
    
   t_group = tic; 
    
   current_indices = groups_of_indices_to_run{iGroup};
   
   n_indices = length(current_indices);
   
   %Threshold prediction
   %-----------------------------------------------------------------------   
   predicted_thresholds = predictor_obj.predictThresholds( ...
       applied_stimulus(current_indices,:),...
           obj.applied_stimulus_matrix,...
           obj.threshold_values,...
           threshold_sign);
   
   %predicted_thresholds: (column vector)
   %
   %
       
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
      thershold_options_obj.changeGuessAmount(2*avg_error);
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