function adjustBoundsGivenMaxScale(obj,max_scale,varargin)
%adjustBoundsGivenMaxScale
%
%   adjustBoundsGivenMaxScale(obj,max_scale)
%
%   Implementation note:
%   -----------------------------------------------------------------------
%   This approach currently assumes an axon model where we don't need to
%   adjust bounds in the z direction since the axon is assumed to occupy an
%   infinite length (or much larger than the stimulation region).
%
%
%   IMPROVEMENTS
%   -----------------------------------------------------------------------
%   1) Grow bounds more efficiently than one layer at a time ...
%
%   See Also:
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds

in.sim_logger = [];
in = processVarargin(in,varargin);

[too_small,min_abs_value_per_side] = obj.checkBounds(max_scale,'sim_logger',in.sim_logger);

if ~any(too_small)
    return
end

fprintf(2,'Updating bounds to encompass stim at %g, current min bound: %g\n',max_scale,min(min_abs_value_per_side));

%IMPORTANT: This is only valid for the axon model where z shouldn't need to
%be resized ...
done = false;
while ~done
    
    %indices, bottom, top left, right
    %           -y     y   -x     x
    
    if too_small(1)
       obj.bounds(1,2) = obj.bounds(1,2) - obj.step_size;
    end
    
    if too_small(2)
       obj.bounds(2,2) = obj.bounds(2,2) + obj.step_size; 
    end
    
    if too_small(3)
       obj.bounds(1,1) = obj.bounds(1,1) - obj.step_size;
    end
    
    if too_small(4)
       obj.bounds(2,1) = obj.bounds(2,1) + obj.step_size; 
    end
    
    [too_small,min_abs_value_per_side] = obj.checkBounds(max_scale,'sim_logger',in.sim_logger);
    
    fprintf(2,'Current min bound: %g\n',min(min_abs_value_per_side))
    
    done = ~any(too_small);
    
end