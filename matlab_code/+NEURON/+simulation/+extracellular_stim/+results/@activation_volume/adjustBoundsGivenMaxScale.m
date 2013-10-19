function adjustBoundsGivenMaxScale(obj,max_scale)
%adjustBoundsGivenMaxScale
%
%   adjustBoundsGivenMaxScale(obj,max_scale)
%
%   This method adjusts the testing bounds of the object so that the all
%   tissue with thresholds less than or equal to the maximum scale are
%   encompassed within the bounds.
%
%   This involves finding the thresholds at the current bounds. If any of
%   the thresholds are less than the maximum stimulus to test, we grow the
%   bounds.
%
%   INPUTS
%   =======================================================================
%   max_scale  : signed max stimulus scale to make sure to encompass with
%                the bounds
%
%
%   Performance note:
%   -----------------------------------------------------------------------
%   The growth of the bounds is less efficient than requesting stimulus
%   thresholds over the appropriate range to begin with. Reasons for this
%   include:
%       1) overhead associated with code
%       2) currently very poor threshold prediction given exptrapolation
%               - there is room for improvement here ...
%       3) in general better peformance given extremes of the stimulus
%       inputs and the ability to improve prediction methods given more
%       data
%
%   For this reason it is desirable to accurately know the bounds as
%   quickly as possible.
%
%   At the same time overgrowth of the bounds results in additional work
%   solving extra simulations.
%
%   Implementation note:
%   -----------------------------------------------------------------------
%   This approach currently assumes an axon model where we don't need to
%   adjust bounds in the z direction since the axon is assumed to occupy an
%   infinite length (or much larger than the stimulation region).
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
%   2) In higher level function after getting thresholds ensure that we
%   never observed reverse recruitment order as this would invalidate
%   the results from this object. In other words, we should never see lower
%   thresholds on an outer shell than on an inner shell. If this happens it
%   is unclear how far we need to grow the bounds before we have
%   encompassed all stimulus activity for a given threshold. Given the
%   right stimuli this is technically possible to accomplish, so an error
%   checking mechanism should be in place.
%       min_shells = min(...) %Would need to finish code
%       Where is the center?
%       center can be defined as the minimum
%       if any(diff(min_shells) > 0)
%           error
%       end
%   NOTE: We already observe this depending upon the location of electrodes
%   NOTE: This needs to be in a higher level function to ensure that we
%   have all thresholds available (at the coarse resolution)
%
%   See Also:
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds
%
%   FULL PATH
%       NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale

min_history_all = zeros(10,4); %10 is a guess of how many times we expand
bounds_all      = zeros(10,4);
cur_index       = 0;

MAX_SCALE_FUDGE_FACTOR = 0.5;

[too_small,min_abs_value_per_side] = obj.checkBounds(max_scale);

min_history_all(1,:) = min_abs_value_per_side;

if ~any(too_small)
    return
end

fprintf('Updating bounds to encompass a stimulation scale at %g, Current min: %0.1f\n',max_scale,min(min_abs_value_per_side));

%IMPORTANT: This is only valid for the axon model where z shouldn't need to be resized ...
done = false;
while ~done
    cur_index                    = cur_index + 1;
    min_history_all(cur_index,:) = min_abs_value_per_side;
    bounds_all(cur_index,:)      = obj.bounds(1:4);
    
    if cur_index == 3  %NOTE: For right now we'll only run this once ...
        for iSide = 1:4
            if too_small(iSide)
                if abs(min_history_all(3,iSide) > min_history_all(2,iSide))
                    %NOTE: This could be improved ...
                    %We are only using two points
                    
                    %This is severly overestimating ...
                    
                    %new_bound = interp1(min_history_all(1:3,iSide),bounds_all(1:3,iSide),max_scale,'linear','extrap');
                    
                    new_bound = interp1(min_history_all(1:3,iSide),bounds_all(1:3,iSide),MAX_SCALE_FUDGE_FACTOR*max_scale,'linear','extrap');
                    
                    %DEBUG PLOTTING ...
                    %                 plot(min_history_all(1:3,iSide),bounds_all(1:3,iSide),'-o')
                    %                 hold all
                    %                 plot(max_scale,new_bound,'-o');
                    %                 hold off
                    
                    obj.setBoundValue(iSide,new_bound);
                else
                    obj.growBounds(iSide);
                end
            end
        end
    else
        obj.growBounds(find(too_small)); %#ok<FNDSB>
    end
    
    [too_small,min_abs_value_per_side] = obj.checkBounds(max_scale);
    
    %NOTE: This is where I was thinking of putting in some logic that
    %looked for where the minimum might be, and then only testing in that
    %area instead of testing the entire side
    %-----------------------------------------------------------------------
    %     %Crap we need to take into account only reshaping some dimensions ...
    %     i.e. xsides will grow if y changes
    %
    %    2:end-1 if both y's a reshaped
    %    1:end-1 if only top (bottom?) is changed
    %    2:end  if ...
    %
    %     thresh_diff = cell(1,4);
    %     for iSide = 1:4
    %        thresh_diff = thresh2{iSide}(2:end-1,:) - thresh{iSide};
    %     end
    
    fprintf('Current min: %0.1f\n',min(min_abs_value_per_side));
    
    done = ~any(too_small);
end

fprintf('Final Bounds:: %s\n',obj.getBoundsString);