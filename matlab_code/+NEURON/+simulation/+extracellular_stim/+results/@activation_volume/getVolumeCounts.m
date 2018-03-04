function [stim_level_counts,extras] = getVolumeCounts(obj,max_stim_level,varargin)
%getVolumeCounts
%
%   [stim_level_counts,extras] = getVolumeCounts(obj,max_stim_level,varargin)
%
%   Inputs
%   ------
%   max_stim_level : sign of this value is important. It indicates the
%           maximum stimulus scaling value to use when getting count points.
%
%
%   TODO: Change this output to its own class ...
%
%   Outputs
%   -------
%   stim_level_counts : (vector, same sign as max_stim_level) For each 
%           stimulus level input this specifies the # of micron voxels
%           that have thresholds lower than the stimulus amplitude.
%
%   extras : 
%         .stim_amplitudes  : 
%         .xyz_cell         :
%         .N                : 
%         .threshold_extras : see getThresholdsAndBounds method
%         .z_saturation_threshold : 2d matrix of max stim value
%               required to saturate activation in z-dimension for a single
%               x-y location. In other words, the maximum threshold along z
%               for a given x-y
%
%
%   Optional Inputs
%   ---------------
%   replication_points : (default []), This allows us to replicate the
%           results of a single simulation at multiple points. This was
%           originally designed for the single electrode case and for
%           comparing it to two electrodes. Thresholds are currently
%           combined using the min operator, i.e. a particular site is
%           activated at the lower of two (or more) stimulation thresholds.
%   stim_resolution : (default 0.1), 
%           Bin width of the count histogram.
%           This indicates the resolution of the stimulus amplitudes that 
%           are tested, and for which, count data are returned.
%
%           
%   min_amp : (defaul 1), This is the minimum amplitude that
%           should be counted.
%   bounds_guess : default []
%   quick_test : default false
%
%   Improvements
%   ------------
%   1) Implement gradient testing to ensure that the mesh is significantly
%      refined enough to allow interpolation.
%
%   2) Incorporate:
%   NEURON.simulation.extracellular_stim.results.activation_volume.volume_counts
%
%   See Also:
%       griddedInterpolant
%       NEURON.simulation.extracellular_stim
%       NEURON.simulation.extracellular_stim.results.activation_volume.getThresholdsAndBounds
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.results.activation_volume.getVolumeCounts
%

%Input Handling
%--------------------------------------------------------------------------
in.replication_points = [];
in.stim_resolution    = 0.1;
in.min_amp            = 1;
in.bounds_guess       = [];
in.quick_test         = false;
in = NEURON.sl.in.processVarargin(in,varargin);

%Input Handling
%--------------------------------------------------------------------------
in.stim_resolution = abs(in.stim_resolution);

MIN_AMP = abs(in.min_amp);

if max_stim_level < 0
    max_stim_level = floor(max_stim_level);
    final_stim_amplitudes = -MIN_AMP:-in.stim_resolution:max_stim_level;
else
    max_stim_level = ceil(max_stim_level);
    final_stim_amplitudes = MIN_AMP:in.stim_resolution:max_stim_level;
end

abs_max_scale = abs(max_stim_level);

%Threshold retrieval
%--------------------------------------------------------------------------
%NEURON.simulation.extracellular_stim.results.activation_volume.getThresholdsAndBounds
[abs_thresholds,x,y,z,threshold_extras] = ...
    obj.getThresholdsAndBounds(max_stim_level,in.replication_points);

xyz_cell = {x y z};

internode_length = obj.getInternodeLength;
max_z_index_keep = floor(internode_length);
n_z_final        = z(end)-z(1); %# of final values in z after interpolation
%NOTE: This suggests we are interpolating down to 1 unit (1 micron)
if n_z_final < max_z_index_keep
    %TODO: Provide more detail in error -> give #s
    %This should never happen if our z-bounding algorithm works right ...
    %We'll check just in case ...
    error('Insufficient testing volume given length of current fiber')
end

%Faster linear interpolation
%--------------------------------------------------------------------------


%       helper_cubeFunction 
%
%Combines the results of apply the function repetitively to all 8 corners
%of a cube.
%
%The output size of the final variable is 1 smaller in all 3 dimensions.
%i.e. sz [5,6,7] will go to sz [4 5 6]
%
%i.e. a 3d matrix of sz(2,2,2) is only sufficient for 1 cube.

%With linear interpolation, if none of the values on the cube (3d) are
%less than the value we are looking for or if any of the values are NaN, 
%then we don't need to bother with interpolating between those values.
all_values_greater = helper__cubeFunction(@and,abs_thresholds > abs_max_scale);
isnan_any_neighbor = helper__cubeFunction(@or,isnan(abs_thresholds));

interpolate_cube_mask = ~(all_values_greater | isnan_any_neighbor);

%These values are in 3d, and specify for each set of 8 points that make up
%cubes for interpolating, the maximum and minimum values. In other words
%we are going to do linear interpolation in 3d. A standard approach to
%doing this requires 8 weighting points (the 8 corners of a cube). It is
%impossible for linear interpolation of points inside the cube to yield
%values that are less than the smallest corner of the cube, or greater than
%the maximum corner of the cube. This helps us to determine whether or not
%we want to even bother interpolating, and what bounds we should use when
%counting thresholds using histc. By restricting our edges we can speed up
%the execution time of histc.
%
%These functions round down and up to the nearest resolution for testing.
min_cube = floor(helper__cubeFunction(@min,abs_thresholds)/in.stim_resolution)*in.stim_resolution;
max_cube = ceil(helper__cubeFunction(@max,abs_thresholds)/in.stim_resolution)*in.stim_resolution;

%NOTE: We don't need to count higher than maximum value requested for testing
max_cube = min(max_cube,abs_max_scale);

%Although, we don't count values above our max, we need to count below our 
%min to get accurate counts, otherwise the cumulative counts will be off ...
%
%This mask will be used to insert 0 as an edge in histc
use_zero_edge = min_cube < MIN_AMP;

%Next, we want to decide based on the minimum value where to assign
%the counts for histc. NOTE: histc is going to operate over different
%ranges depending on the observed range of the data. (See note above on
%this)
%
%   This formula is a bit tricky, an example below 
%
%NOTE: The round should not be necessary and is only for floating point
%rounding errors. The value should be very close to an index because of the
%rounding done above. We are just trying to avoid warnings/errors when
%indexing in the future using this number.
N_start_indices = round((min_cube-MIN_AMP)/in.stim_resolution) + 2;

N_start_indices(use_zero_edge) = 1;

%EXAMPLE
%==========================================================================
%in.stim_resolution = 0.1
%
%observed_value 1.63 %NOTE: This should get assigned to a threshold of 1.7
%
%max_cube(ix,iy,iz) = 1.8 <- not important for example
%min_cube(ix,iy,iz) = 1.3
%
%MIN_AMP = 1
%
%N = histc(1.63,[1.3 1.4 1.5 1.6 1.7 1.8])
%
%[1.3 1.4 1.5 1.6 1.7 1.8]    <- histc edges
%             x               <- match in histc, i.e. 1.63 i.e. 1.6 <= 1.63 < 1.7
% 1   2   3   4   5   6       <- indices, i.e. N(4) = 1
%
%final amplitudes based on MIN_AMP = 1  
%1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 etc  <- max not shown 
%1  2   3   4   5   6   7   8
%
%Thus, we want to assign index of 4 (values between 1.6 and 1.7) to 8 (1.7
%is first valid threshold value)
%
%or for the full length
%N(1) -> final(5)   <- in this case we want to start at 5
%so that anything that is between 1.3 and 1.4 goes to having a threshold
%of 1.4 (final index 5) NOTE: We are ignoring things that are exactly equal to 1.3 ...
%as these will get put in the mix of 1.4. This is part of the noise
%expected from doing a histogram ... (if it ever even happens in reality)
%
%N(2) -> final(6)
%N(3) -> final(7)
%N(4) -> final(8)  <- this is what we wanted for 1.63 
%
%
%LET'S TEST OUR EQUATION:
%---------------------------------------------
%round((1.3 - 1)/.1) + 2 => 5 
%
%What if we have a value less than MIN_AMP
%
%MIN_AMP = 1
%min_cube(ix,iy,iz) = 0.6
%
%[0 1 1.1 1.2 1.3 1.4 etc] NOTE: The 2nd value is MIN_AMP, not 0.6
%                           we add a zero to accurately count the values
%                           that are between 0 and MIN_MAP as being
%                          at threshold by MIN_AMP
%
%NOTE: In this case we want our first index to be at 1, i.e.
%anything between 0 and MIN_AMP goes to the first index in our final
%amplitudes

N = zeros(length(final_stim_amplitudes),1);

%  :/   I don't like all these variables ...
%We might want to make all of this a class ...
if in.quick_test
   stim_level_counts       = N + 1;
   z_saturation_threshold  = 1;
else
   [N,z_saturation_threshold] = ...
       integrate(x,y,z,max_z_index_keep,in.stim_resolution,N_start_indices,interpolate_cube_mask,min_cube,max_cube,use_zero_edge,abs_thresholds,N,MIN_AMP);
   stim_level_counts     = cumsum(N)';
end

extras.stim_amplitudes  = final_stim_amplitudes;
extras.xyz_cell         = xyz_cell;
extras.N                = N;
extras.threshold_extras = threshold_extras;
extras.z_saturation_threshold = z_saturation_threshold;
extras.raw_abs_thresholds   = abs_thresholds;

end

function [N,z_saturation_threshold] = integrate(x,y,z,max_z_index_keep,stim_resolution,N_start_indices,interpolate_cube_mask,min_cube,max_cube,use_zero_edge,abs_thresholds,N,MIN_AMP)


nx = length(x);
ny = length(y);

%nz = length(z);
%See redefinition below for ensuring that we only run
%as many z as we need, ran into a negative value problem with
%first_z_index_delete

[f1,f2,f3,f4,f5,f6,f7,f8] = helper__getWeights(x,y,z);

%Compute points in loop to display progress
%---------------------------------------------------------------
percentage_display_mask = false(1,nx);
percentage_display_mask(ceil((0.1:0.1:0.9)*nx)) = true;

%For computing z-saturation ...
z_saturation_threshold = NaN(x(end)-x(1),y(end)-y(1));

sz = size(f1);
dx = sz(1);
dy = sz(2);
dz = sz(3);

nz = ceil(max_z_index_keep/dz);

fprintf('Integrating Volume')
tic;

n_z_total = dz*nz; %z(end) - z(1);
n_over    = n_z_total - max_z_index_keep; %# of extra  values
%we will have on the last iteration
%
%i.e. if we are going in steps of 20 (dz = 20), and we only need to have 30 values
%we'll have 10 extra values on the last iteration.
%
%Now we need to translate this back to a local index, because the size
%of our data is only going to be 20, not 40
%
%We could do end-n_over+1:end or get the correct correction factor here
first_z_index_delete = dz - n_over + 1;


for ix = 1:nx-1    
    %Print progress to command window, keep on same line
    if percentage_display_mask(ix)
        fprintf(', %0.0f%%',100*ix/nx);
    end
    
    
    if ~any(interpolate_cube_mask(ix,:,:))
        continue
    end
    
    cur_x = dx*(ix-1)+1;
    for iy = 1:ny-1
        cur_y = dy*(iy-1)+1;
        for iz = 1:nz-1
            cur_z = dz*(iz-1)+1;
            if interpolate_cube_mask(ix,iy,iz)
                temp = ...
                    f1*abs_thresholds(ix, iy,   iz)   + f2*abs_thresholds(ix+1, iy  , iz)   + ...
                    f3*abs_thresholds(ix, iy+1, iz)   + f4*abs_thresholds(ix+1, iy+1, iz)   + ...
                    f5*abs_thresholds(ix, iy  , iz+1) + f6*abs_thresholds(ix+1, iy  , iz+1) + ...
                    f7*abs_thresholds(ix, iy+1, iz+1) + f8*abs_thresholds(ix+1, iy+1, iz+1);
                
                if iz == nz-1 && n_over ~= 0
                    temp(:,:,first_z_index_delete:end) = NaN;
                end

                z_saturation_threshold(cur_x:cur_x+dx-1,cur_y:cur_y+dy-1) = ...
                    max(z_saturation_threshold(cur_x:cur_x+dx-1,cur_y:cur_y+dy-1),max(temp,[],3));
                
                %NOTE: min and max are precomputed on the original data 
                %set and rounded appropriately (floor - min & ceil - max)
                cur_min_threshold = min_cube(ix,iy,iz);
                cur_max_threshold = max_cube(ix,iy,iz);
                                
                
                %NOTE: When going to max amplitude we add an eps 
                %just in case the stim_resolution doesn't ammend itself
                %to landing nicely on the final value ...
                if use_zero_edge(ix,iy,iz)
                    %If everything is less than the hardcoded minimum
                    %value to evaluate, then our result is to assign
                    %all valid entries (non-z bounded) to the first entry
                    if cur_max_threshold < MIN_AMP
                        %NOTE: This is a sum on a logical, not on the
                        %threshold values themselves. We can't
                        %take the length as some of the values may
                        %be invalid from the z-bounding done above
                        temp2(1) = temp2(1) + sum(temp(:) < MIN_AMP);
                        continue
                    else
                        %Some are below the minimum amplitude, some are not
                        %Introduce an extra bin between 0 and MIN_AMP
                        %to make sure the cumulative sum is correct
                        %
                        %NOTE: cur_N_start_index should already be modified accordingly
                        threshold_bin_edges = [0 MIN_AMP:stim_resolution:cur_max_threshold];
                    end
                else
                    threshold_bin_edges = cur_min_threshold:stim_resolution:cur_max_threshold;
                end

                temp2 = histc(temp(:),threshold_bin_edges);

                %NOTE: temp2 has one extra bin for exactly equal to the end
                %value which we don't care about ...
                %
                %NOTE: I was going to pass in an array of N_end_indices, but
                %length(edges) was much easier to implement
                %
                %NOTE: Typically we would do - 1, to account for 
                %start + length being 1 greater than the end
                %ex. from 3 to 5 => 3:5 contains 3 elements
                %3 + 3 = 6 => subtract 1 to get back to 5
                %
                %   For histc we have an extra bin at the end, which is for
                %   the case in which we have something exactly equal to
                %   the last value (which we should basically never have
                %   with floating point numbers like this)
                %
                cur_N_start_index = N_start_indices(ix,iy,iz);
                N(cur_N_start_index:cur_N_start_index+length(threshold_bin_edges)-2) = ...
                            N(cur_N_start_index:cur_N_start_index+length(threshold_bin_edges)-2) + temp2(1:end-1);
            end %end of z
        end
    end
end
fprintf('\n'); %Terminates line for progress display.
toc;

end


function [f1,f2,f3,f4,f5,f6,f7,f8] = helper__getWeights(x,y,z)
%
%   TODO: Finish checks ...
%
%

%TODO: These should be integers, check
dx = x(2)-x(1);
dy = y(2)-y(1);
dz = z(2)-z(1);

%TODO: Check that dx, dy, and dz are constant for all x,y,z

%weights - 1d only
%-------------------------------------------
%This approach enforces 1 um integration ...
%We'll also go with integrating on the interior of cubes as this avoids
%edge effects
%i.e let's say we have values 0, 10, 20, 30, etc
%let's say we want to integrate to get 0:30
%for the first integration we could integrate from 0 - 10, then 10 to
%20, but this will double count 10
%so alternatively we'll evaluate from 0.5 to 9.5, then 10.5 to 19.5
%
%   These weights basically go from 0 to 1, to indicate how close they
%   are to either edge. There is a slight correction to take into
%   account integrating at half values instead of on the integers.
%
x2 = ((1:dx)/dx - 0.5/dx)'; %vector in 1st dimension, i.e. column vector
y2 = (1:dy)/dy - 0.5/dy;    %row vector
z2 = permute((1:dz)/dz - 0.5/dz,[1 3 2]); %vector in 3rd dimension

%replication of weights to 3d
%-------------------------------------------
x2_3d = repmat(x2,[1  dy dz]);
y2_3d = repmat(y2,[dx 1  dz]);
z2_3d = repmat(z2,[dx dy 1]);

%Subtract 1 to indicate how close we are to the other side of the cube
%for any given dimension (x,y, or z)
x1_3d = 1 - x2_3d;
y1_3d = 1 - y2_3d;
z1_3d = 1 - z2_3d;

%point centered weights
%-------------------------------------------
f1 = x1_3d.*y1_3d.*z1_3d;  %1 1 1
f2 = x2_3d.*y1_3d.*z1_3d;  %2 1 1
f3 = x1_3d.*y2_3d.*z1_3d;  %1 2 1
f4 = x2_3d.*y2_3d.*z1_3d;  %2 2 1
f5 = x1_3d.*y1_3d.*z2_3d;  %1 1 2
f6 = x2_3d.*y1_3d.*z2_3d;  %2 1 2
f7 = x1_3d.*y2_3d.*z2_3d;  %1 2 2
f8 = x2_3d.*y2_3d.*z2_3d;  %2 2 2

end

function result = helper__cubeFunction(f,value)
%
%   This function evaluates a function at all corners of a cube and links
%   the results of each evaluation, which is useful for functions which
%   link over all points like, max(), min(), and(), and or(), where we want
%   to know, for example, the max of all points that make up the corner of
%   a cube
%
%   i.e. max(all_corner_points) => r =  max(corner1,corner2)
%            r = max(r,corner3), r = max(r,corner4), etc
%

result = f(        value(1:end-1,1:end-1,1:end-1) ,...
                   value(1:end-1,1:end-1,2:end  ));
result = f(result, value(1:end-1,2:end  ,1:end-1));
result = f(result, value(1:end-1,2:end  ,2:end  ));
result = f(result, value(2:end  ,1:end-1,1:end-1));
result = f(result, value(2:end  ,1:end-1,2:end  ));
result = f(result, value(2:end  ,2:end  ,1:end-1));
result = f(result, value(2:end  ,2:end  ,2:end  ));


end

