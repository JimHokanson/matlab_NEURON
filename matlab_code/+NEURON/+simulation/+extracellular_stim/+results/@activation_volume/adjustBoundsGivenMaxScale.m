function adjustBoundsGivenMaxScale(obj,max_scale,varargin)
%
%   adjustBoundsGivenMaxScale(obj,max_scale)
%
%   Implementation note:
%   -----------------------------------------------------------------
%   This approach currently assumes an axon model where we don't need to
%   adjust bounds in the z direction since the axon is assumed to occupy an
%   infinite length (or much larger than the stimulation region).
%
%
%   IMPROVEMENTS
%   -----------------------------------------------------------------
%   1) Also allow shrinking of bounds to reduce interpolation work ...
%
%   See Also:
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds
%       

%How to determine best growth?
% - for now just increment ...

in.sim_logger = [];
in = processVarargin(in,varargin);

%sim_logger = obj.xstim_obj.sim

too_small = checkBounds(obj,max_scale,'sim_logger',in.sim_logger);

if ~any(too_small)
    return
end

fprintf(2,'Updating bounds to encompass stim at %g\n',max_scale);


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
    
    too_small = checkBounds(obj,max_scale,'sim_logger',in.sim_logger);
    
    done = ~any(too_small);
    
end