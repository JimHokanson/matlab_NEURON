function [stim_level_counts,stim_amplitudes] = getVolumeCounts(obj,max_stim_level,varargin)
%getVolumeCounts
%
%   stim_level_counts = getVolumeCounts(obj,stim_levels,varargin)
%
%
%   USAGE NOTES
%   ======================================================================
%   1) Tested stimulus levels currently run from 1 to the max stimulus
%   level
%
%   INPUTS
%   =======================================================================
%   max_stim_level : sign of this value is important. It indicates the
%   maximum stimulus scaling value to use when getting count points.
%
%   OUTPUTS
%   =======================================================================
%   stim_level_counts : (vector, same sign as max_stim_level) For each 
%       stimulus level input this specifies the # of cubic microns.
%
%   OPTIONAL INPUTS
%   =======================================================================
%   replication_points : (default []), This allows us to replicate the
%           results of a single simulation at multiple points. This was
%           originally designed for the single electrode case and for
%           comparing it to two electrodes. Thresholds are currently
%           combined using the min operator.
%   replication_center : (default [0 0 0]), This defines the center of
%           the original data. The data is moved such that the center is
%           located at each replication point.
%   stim_resolution : (default 0.5), This indicates the resolution of 
%   the stimulus amplitudes that are tested, and for which, count data is
%   returned.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Implement gradient testing to ensure that the mesh is significantly
%      refined enough to allow interpolation.
%
%   See Also:
%       griddedInterpolant
%       NEURON.simulation.extracellular_stim
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.results.activation_volume.populateVolumeCounts

%Input Handling
%--------------------------------------------------------------------------
in.replication_points = [];
in.replication_center = [0 0 0];
in.stim_resolution    = 0.5;
in = processVarargin(in,varargin);

%Input Handling
%--------------------------------------------------------------------------
in.stim_resolution = abs(in.stim_resolution);

if max_stim_level < 0
    max_stim_level = floor(max_stim_level);
else
    max_stim_level = ceil(max_stim_level);
end


abs_max_scale = abs(max_stim_level);

n_stim_levels = abs_max_scale; %We'll go from 1 to n

%Threshold retrieval
%--------------------------------------------------------------------------
abs_thresholds = abs(obj.getThresholdsEncompassingMaxScale(max_stim_level));

%Step 4 - Get Counts
%--------------------------------------------------------------------------
if ~isempty(in.replication_points)
    [abs_thresholds,x,y,z] = helper__createReplicatedData(obj,abs_thresholds,in);
else
    [x,y,z] = obj.getXYZlattice(false); %false - return as vectors
end

internode_length = obj.getInternodeLength;
max_z_index_keep = floor(internode_length);
n_z_final = z(end)-z(1);
if n_z_final < max_z_index_keep
    %TODO: Provide more detail in error -> give #s
    error('Insufficient testing volume given length of current fiber')
end

%Faster linear interpolation
%--------------------------------------------------------------------------
%Either we can interpolate on the values, or on the halves
%Interpolating on the halves allows us to skip worrying about the edges
%but slightly reduces the # of points on all sides.

nx = length(x);
ny = length(y);
nz = length(z);

[f1,f2,f3,f4,f5,f6,f7,f8] = helper__getWeights(x,y,z);

%TODO: Remove need for this
dz = z(2)-z(1);

fprintf('Integrating Volume')

percentage_display_mask = false(1,nx);
percentage_display_mask(ceil((0.1:0.1:0.9)*nx)) = true;

%With linear interpolation, if none of the values on the cube (3d) are
%less than the value we are looking for or if any of the values are NaN, 
%then we don't need to bother with interpolating between those values.
all_values_greater = helper__cubeFunction(@and,abs_thresholds > abs_max_scale);
isnan_any_neighbor = helper__cubeFunction(@or,isnan(abs_thresholds));

cube_test_mask = ~(all_values_greater | isnan_any_neighbor);

%We'll use these values to limit the histc function to only
%be over the range of possible outcomes from linear interpolation, i.e. all
%values must be between the minimum and the maximum, which can
%significantly reduce the time for the binary search to find a result as
%the range is often much less than the range of the entire data set
min_cube = floor(helper__cubeFunction(@min,abs_thresholds));
max_cube = ceil(helper__cubeFunction(@max,abs_thresholds));


N = zeros(n_stim_levels,1);
for ix = 1:nx-1    
    %Print progress to command window, keep on same line
    if percentage_display_mask(ix)
        fprintf(', %0.0f%%',100*ix/nx);
    end
    
    if ~any(cube_test_mask(ix,:,:))
        continue
    end
    
    for iy = 1:ny-1
        last_z_index = 0;
        for iz = 1:nz-1
            if cube_test_mask(ix,iy,iz)
                temp = ...
                    f1*abs_thresholds(ix, iy,   iz)   + f2*abs_thresholds(ix+1, iy  , iz)   + ...
                    f3*abs_thresholds(ix, iy+1, iz)   + f4*abs_thresholds(ix+1, iy+1, iz)   + ...
                    f5*abs_thresholds(ix, iy  , iz+1) + f6*abs_thresholds(ix+1, iy  , iz+1) + ...
                    f7*abs_thresholds(ix, iy+1, iz+1) + f8*abs_thresholds(ix+1, iy+1, iz+1);
                
                %TODO: This test should really be a test on iz ...
                if last_z_index + dz > max_z_index_keep
                    %JAH TODO: Fix this, my head hurts and I can't
                    %do this math right now ...
                    temp_indices = last_z_index+1:last_z_index+dz;
                    temp(:,:,temp_indices > max_z_index_keep) = abs_max_scale + 1;
                end
                
                %NOTE: The following few lines of code force the resulting
                %counts to be on a scale from 1 to the maximum stimulus
                %amplitude 
                %i.e. absolute_stim_amplitudes = 1:abs_max_scale
                min_stim_level_cur = min_cube(ix,iy,iz);
                
                %limit the max to abs_max_scale
                max_stim_level_cur = min(max_cube(ix,iy,iz),abs_max_scale);
                
                temp2 = histc(temp(:),min_stim_level_cur:max_stim_level_cur);

                %NOTE: temp2 has one extra bin for exactly equal to the end
                %value which we don't care about ...
                N(min_stim_level_cur+1:max_stim_level_cur) = ...
                            N(min_stim_level_cur+1:max_stim_level_cur) + temp2(1:end-1);
            end
            last_z_index = last_z_index + dz;
        end
    end
end
fprintf('\n'); %Terminates line for progress display.

stim_level_counts = cumsum(N)';
abs_stim_amplitudes   = 1:abs_max_scale;

final_abs_stim_amplitudes = 1:in.stim_resolution:abs_max_scale;

stim_level_counts = interp1(abs_stim_amplitudes,stim_level_counts,final_abs_stim_amplitudes,'pchip');

if sign(max_stim_level) == -1
   stim_amplitudes = -1*final_abs_stim_amplitudes(end:-1:1);
else
   stim_amplitudes = final_abs_stim_amplitudes; 
end

%Optional interpolaton


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

function [replicated_thresholds,x,y,z] = helper__createReplicatedData(obj,abs_thresholds,in)
%
%   The goal of this function is to replicate data given the locations we
%   wish to replicate the data to. This is specifically for the single
%   electrode case.

xyz_orig         = obj.getXYZlattice(true);
[V_temp,xyz_new] = arrayfcns.replicate3dData(abs_thresholds,xyz_orig,...
    in.replication_points,obj.step_size,...
    'data_center',in.replication_center);

x = xyz_new{1};
y = xyz_new{2};
z = xyz_new{3};

replicated_thresholds = squeeze(min(V_temp,[],4));


%3) NaN check in Z
%--------------------------------------------------------------------------
%We currently assume that we can truncate in z, since the solution should
%repeat itself in that dimensionnnn. This is not true if the solution is
%the result of z-expansion, where real data doesn't fill the z axis.

%Example
%1   NaN NaN
%2   3   NaN
%4   3   1
%NaN 3   2
%NaN NaN 4

%We'll currently just check that we don't have this problem. It should only
%occur with replicating points that vary in z.

xy_any_NaN = any(isnan(replicated_thresholds),2);
xy_all_NaN = all(isnan(replicated_thresholds),2);

some_but_not_all_z_NaN = any(xy_any_NaN(:) & ~xy_all_NaN(:));

if any(some_but_not_all_z_NaN)
    error('Code does not yet support partial NaN z axis, counts will be incorrect')
    %NOTE: We can fix this problem by shifting all real data up to higher index
    %z. We would only get one shift per xy location. We would then need to
    %make sure that for each xy location, we have enough real valued z to
    %estimate z at that value. This should always be the case unless higher
    %level code fails to test z properly...
    %
    %    Example 1: Fix to above
    %    1 3 1
    %    2 3 2
    %    4 3 4
    %
    %    This is good for the counts, asssuming we only need 3 values
    %
    %    1   NaN 2
    %    NaN  3  4
    %    5    6  7
    %    NaN  8  9
    %
    %    Could only be shifted to:
    %    1    3   2
    %    NaN  6   4
    %    5    8   9
    %    NaN
    %
    %    Mentally, one can think of this as for each column, taking a node
    %    of Ranvier and varying its row position, we can't break space rules
    %    for the rows by putting the 1 & 5 next to each otehr. In addition
    %    if we need 3 values, column 1 doesn't have enough tested values,
    %    but again earlier code which sets the z-axis based on the internode
    %    length must have failed for this to occur.
    %
    
end

%
%For counting purposes, replace this with:
end