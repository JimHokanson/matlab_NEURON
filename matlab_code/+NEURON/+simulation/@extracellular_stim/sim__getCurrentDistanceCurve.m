function result_obj = sim__getCurrentDistanceCurve(obj,all_distances,varargin)
%sim__getCurrentDistanceCurve
%
%   t_all = sim__getCurrentDistanceCurve(obj,all_distances,varargin)
%
%   INPUTS
%   =======================================================================
%   all_distances: All distances to test
%
%
%   OPTIONAL INPUTS
%   =======================================================================
%   use_sim_logger : (default true)
%
%
%   TODO: - finish documentation
%
%   OUTPUTS
%   =======================================================================
%   result_obj : NEURON.simulation.extracellular_stim.results.current_distance
%
%   See Also:
%       NEURON.simulation.extracellular_stim.results.current_distance
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve

in.use_sim_logger = true;
in.starting_value = 1; %Starting stimulus scale, SIGN is important, applies
%for the first distance tested.
in.base_xyz       = [0 0 0]; %Base location of the electrode ...
in.dim_move       = 2;
in.sim_logger_options = {};
in = NEURON.sl.in.processVarargin(in,varargin);

elec_obj_local   = obj.elec_objs;
thresh_opt_local = obj.threshold_options_obj;

assert(length(elec_obj_local) == 1,'Function is only designed for a singular electrode')
assert(issorted(all_distances),'Distances must be sorted')
assert(isequal(size(in.base_xyz),[1 3]),'Base xyz must be size [1 x 3]')

moveCenter(obj.cell_obj,[0 0 0])

result_obj = NEURON.simulation.extracellular_stim.results.current_distance(...
    in.base_xyz,in.dim_move,all_distances);


if in.use_sim_logger
    
    moveElectrode(elec_obj_local,[0 0 0]);
    
    cell_locations = num2cell(in.base_xyz);
    cell_locations{in.dim_move} = all_distances;
    
    %NEURON.simulation.extracellular_stim.sim__getThresholdsMulipleLocations
    all_thresholds = obj.sim__getThresholdsMulipleLocations(cell_locations,...
        'threshold_sign',sign(in.starting_value),'reshape_output',false,...
        in.sim_logger_options{:});

else
    
    %Changing evaluation order to improve execution speed
    %----------------------------------------------------------------------
    n_steps = length(all_distances);
    
    step_indices_order = zeros(1,n_steps);
    step_indices_order(1) = 1;
    if n_steps > 1
        step_indices_order(2) = n_steps;
        %Going in reverse seems to work much better as rate of change
        %tends to increase with distance
        step_indices_order(3:end) = (n_steps-1):-1:2;
    end
    
    %Initialization of values for loop
    %----------------------------------------------------------------------
    next_stim_start_guess = in.starting_value;
    xyz_electrode         = in.base_xyz;
    all_thresholds        = zeros(1,n_steps);
    
    %Determination of threshold values
    %----------------------------------------------------------------------
    for iStep = 1:n_steps
        
        cur_index  = step_indices_order(iStep);
        
        xyz_electrode(in.dim_move) = all_distances(cur_index);
        moveElectrode(elec_obj_local,xyz_electrode)
        temp = sim__determine_threshold(obj,next_stim_start_guess);
        all_thresholds(cur_index) = temp.stimulus_threshold;
        
        last_error = abs(next_stim_start_guess - all_thresholds(cur_index));
        
        %Interpolation
        %----------------------------------------------------------------------
        if iStep ~= n_steps
            next_index = step_indices_order(iStep+1);
            if iStep == 1
                %Do linear extrapolation with zero threshold at zero distance
                %Might be innaccurate for distances not along node but 0 should
                %be less than current value
                next_stim_start_guess = interp1([all_distances(cur_index) 0],...
                    [all_thresholds(cur_index) 0],all_distances(next_index),'linear','extrap');
            else
                previous_indices = step_indices_order(1:iStep);
                if iStep == 2
                    next_stim_start_guess = interp1(all_distances(previous_indices),...
                        all_thresholds(previous_indices),all_distances(next_index),'linear');
                else
                    %In a very limited test pchip works much better
                    next_stim_start_guess = interp1(all_distances(previous_indices),...
                        all_thresholds(previous_indices),all_distances(next_index),'pchip');
                    
                    %This can improve the results but causes problems
                    %if set inaccurately ...
                    thresh_opt_local.changeGuessAmount(last_error)
                    
                end
            end
        end
        
    end
end


result_obj.tested_distances = all_distances;
result_obj.thresholds       = all_thresholds;

end