function t_all = sim__getCurrentDistanceCurve(obj,distance_steps,dim,starting_value)
%sim__getCurrentDistanceCurve
%
%   t_all = sim__getCurrentDistanceCurve(obj,distance_steps,dim,starting_value)
%
%   INPUTS
%   =====================================================
%   distance_steps : steps at which to evaluate threshold
%   dim            : numeric value, either 1, 2, or 3 for x,y,z
%                    NOTE: for axons they travel along z ...
%   starting_value : starting stimulus level, SIGN is important
%
%   
%   IMPROVEMENTS
%   =====================================================
%   1) Eventually return a result object
%   2) Should have class that explicity tries to estimate thresholds from
%      previous thresholds ...
%
%   class: NEURON.simulation.extracellular_stim
%
%   See Also:
%       
%

elec_obj_local      = obj.elec_objs;
threshold_obj_local = obj.threshold_cmd_obj;
if length(elec_obj_local) ~= 1
    error('Function assumes only a single electrode')
end

moveCenter(obj.cell_obj,[0 0 0])

next_stim_start_guess = starting_value;
%Check assumptions
%Move electrode relative to cell
nSteps = length(distance_steps);
t_all  = zeros(1,nSteps);
elec_location = zeros(1,3);
for iStep = 1:nSteps

    
    elec_location(dim) = distance_steps(iStep);
    moveElectrode(elec_obj_local,elec_location)
    t_all(iStep) = sim__determine_threshold(obj,next_stim_start_guess);

    %ADJUSTING GUESS FOR NEXT LOOP
    %----------------------------------------------------------------------
    if iStep > 1 && iStep ~= nSteps
       %Adjust things accordingly
       %threshold_obj_local
       %    => guess_amount
       %NOTE: Could probably improve this ...
       %NOTE: Tried spline, not nearly as good
       next_stim_start_guess = interp1(distance_steps(1:iStep),t_all(1:iStep),distance_steps(iStep+1),'pchip','extrap');
       
       %Only needs to be set once ...
       if iStep == 2
           %I originally had just equal to the threshold accuracy
           %If I hit that target, then I only need to run twice to
           %determine threshold with sufficient resolution, once below, and
           %once above
           threshold_obj_local.guess_amount = 2*threshold_obj_local.threshold_accuracy;
       end
       %NOTE: We don't want to hit the target exactly, because we are not
       %sure which side we will end up on. Instead we want to bound the
       %side, then go the other direction and bound the side again
       %Here we guess low, hope to get a no AP, and then go high and get an AP
       next_stim_start_guess = next_stim_start_guess - threshold_obj_local.guess_amount/2; 
    else
       next_stim_start_guess = t_all(iStep); 
    end
    %disp(iStep) %debugging
    
end

end