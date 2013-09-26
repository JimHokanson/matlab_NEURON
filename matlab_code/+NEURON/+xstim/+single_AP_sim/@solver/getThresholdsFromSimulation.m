function threshold_simulation_results = getThresholdsFromSimulation(obj,new_indices,predicted_thresholds)
%
%   
%   threshold_simulation_results = getThresholdsFromSimulation(obj,new_indices,predicted_thresholds)
%
%
%   This method runs the actual NEURON simulations to compute thresholds.
%
%   OUTPUTS
%   =======================================================================
%   threshold_simulation_results : NEURON.xstim.single_AP_sim.threshold_simulation_results
%   
%   INPUTS
%   =======================================================================
%   new_indices : indices from obj.new_data to solve thresholds for
%
%
%   See Also:
%   NEURON.xstim.single_AP_sim.solver.default.
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.solver.threshold_simulation_results


%Possible short circuit
%--------------------------------------------------------------------------
%If we are testing than we pass the request to the system_tester object
%which must 

if obj.system_testing
   threshold_simulation_results = obj.system_tester.getThresholdsFromSimulation(obj,new_indices,predicted_thresholds);
   return
end


%TODO: We should also check the bounds ...
%That we don't exceed the min and max bounds ...
if any(sign(predicted_thresholds) ~= obj.stim_sign)
   %NOTE: We could replace with a default value 
   error('Stim sign different from sign of predicted thresholds')
end

%SETUP 
%--------------------------------------------------------------------------
cell_locations = obj.new_data.cell_locations(new_indices,:);
xstim_local    = obj.xstim;
cell_local     = xstim_local.cell_obj;

n_indices  = length(new_indices);
thresholds = zeros(1,n_indices);

%Some additional logging ...
n_loops    = zeros(1,n_indices);
ranges     = zeros(n_indices,2);

%Display setup
%--------------------------------------------------------------------------
if n_indices > 9
   %I want to do a countdown from 9 to 1 to indicate finishing
   display_number = zeros(1,n_indices);
   display_number(ceil((0.1:0.1:0.9)*n_indices)) = 9:-1:1;
end

for iIndex = 1:n_indices
    if n_indices > 9 && display_number(iIndex) ~= 0
          fprintf('%d,',display_number(iIndex)) 
    end

    %Move cell
    cell_local.moveCenter(cell_locations(iIndex,:));

    %NEURON.simulation.extracellular_stim.sim__determine_threshold
    %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    
    result_obj = xstim_local.sim__determine_threshold(predicted_thresholds(iIndex));

%                             n_loops: 8
%                         n_above: 4
%                         n_below: 4
%                  threshold_info: [1x1 NEURON.cell.threshold_info]
%              stimulus_threshold: 4.5313
%                  tested_stimuli: [1 3 5 4 4.5000 4.7500 4.6250 4.5625]
%                   response_type: [4 4 1 4 4 1 1 1]
%         last_threshold_stimulus: 4.5625
%     last_non_threshold_stimulus: 4.5000
%               last_threshold_vm: [321x21 double]
    
    %NEURON.simulation.extracellular_stim.results.threshold_testing_history
    thresholds(iIndex) = result_obj.stimulus_threshold;
    
    n_loops(iIndex)  = result_obj.n_loops;
    ranges(iIndex,1) = result_obj.last_non_threshold_stimulus;
    ranges(iIndex,2) = result_obj.last_threshold_stimulus;
    
    if isnan(thresholds(iIndex))
        error('Something went wrong, NaN encountered')
    end
end

r = NEURON.xstim.single_AP_sim.threshold_simulation_results(obj);
r.indices              = new_indices;
r.predicted_thresholds = predicted_thresholds;
r.actual_thresholds    = thresholds;
r.n_loops              = n_loops;
r.ranges               = ranges;

threshold_simulation_results = r;

end