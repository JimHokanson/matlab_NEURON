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
%       - started implementation, I need to change order to be
%       xmin,xmax,ymin,ymax so that we can index into the matrix 1 - 4
%       - I also need to only test the extremes in the position and grow
%       along the max gradient, or for simplicity, the limiting point
%       - in other words, if the limit is the following for a side
%       - 1 2 1 
%         2 3 2         Then we should only test the middle value out
%         1 2 1         until we max, then run this current approach 
%                       after that point
% 
%   See Also:
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds

in.sim_logger = [];
in = processVarargin(in,varargin);

min_history_all = zeros(100,4);
bounds_all      = zeros(100,4);
cur_index       = 0;

[too_small,min_abs_value_per_side] = obj.checkBounds(max_scale,'sim_logger',in.sim_logger);

min_history_all(1,:) = min_abs_value_per_side;

if ~any(too_small)
    return
end

fprintf(2,'Updating bounds to encompass stim at %g, current min bound: %g\n',max_scale,min(min_abs_value_per_side));

%IMPORTANT: This is only valid for the axon model where z shouldn't need to
%be resized ...
done = false;
while ~done
    cur_index = cur_index + 1;
    min_history_all(cur_index,:) = min_abs_value_per_side;
    bounds_all(cur_index,:) = [obj.bounds(1,2) obj.bounds(2,2) obj.bounds(1,1) obj.bounds(2,1)];
    
    if cur_index == 3
        %NOTE: For right now we'll only run this once
        for iSide = 1:4
            if too_small(iSide)
                new_bound = interp1(min_history_all(1:3,iSide),bounds_all(1:3,iSide),max_scale,'linear','extrap');
                switch iSide
                    case 1
                        obj.bounds(1,2) = round2(new_bound,obj.step_size,@floor);
                    case 2
                        obj.bounds(2,2) = round2(new_bound,obj.step_size,@ceil);
                    case 3
                        obj.bounds(1,1) = round2(new_bound,obj.step_size,@floor);
                    case 4
                        obj.bounds(2,1) = round2(new_bound,obj.step_size,@ceil);
                end
            end
        end
        %TODO: Add on some check that things haven't flipped
        %I had pchip interpolation and it made my positive bound negative
        %and my negative bound positive
    else
        
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
    end
    
    [too_small,min_abs_value_per_side] = obj.checkBounds(max_scale,'sim_logger',in.sim_logger);
    
    fprintf(2,'Current min bound: %g, goal: %g\n',min(min_abs_value_per_side),max_scale);
    
    done = ~any(too_small);
    
end