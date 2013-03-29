function stim_level_counts = getVolumeCounts(obj,max_stim_level,varargin)
%getVolumeCounts
%
%   stim_level_counts = getVolumeCounts(obj,stim_levels,varargin)
%
%   OUTPUTS
%   =======================================================================
%   stim_level_counts : (vector, same sign) For each stimulus level input
%       this specifies the # of cubic microns.
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
%
%   IMPROVEMENTS
%   =======================================================================
%   1) ind2sub could be removed, it is very slow
%   2) Implement gradient testing to ensure that the mesh is significantly
%      refined enough to allow interpolation.
%
%   See Also:
%       griddedInterpolant
%       NEURON.simulation.extracellular_stim
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.results.activation_volume.populateVolumeCounts

%Performance:
%---------------------------------------------------------------------
%This function used to be really slow. It's performance still isn't great.
%Here are some notes:
%
%1) Rewrote linear interpolation to take advantage of constant weights but
%limited memory
%2) Used accumarray instead of histc which in limited testing seemed to
%increase performance as well
%3)


in.replication_points = [];
in.replication_center = [0 0 0];

in = processVarargin(in,varargin);

if sign(max_stim_level) == 1
    stim_levels = 1:max_stim_level;
else
    stim_levels = -1:1:max_stim_level;
end

stim_level_counts = zeros(length(stim_levels),1);

%Step 1: Stim level input processing
%--------------------------------------------------------------------------
if isempty(stim_levels)
    error('stim_levels can not be empty')
end

if ~all(sign(stim_levels) == sign(stim_levels(1)))
    error('All stim levels to test must have the same sign')
end

abs_stim_levels = abs(stim_levels);
%TODO: add issorted check - ascending

abs_max_scale = max(abs_stim_levels);

%Reapply sign
signed_max_scale = abs_max_scale*sign(stim_levels(1));

%Step 2: Stim Bounds determination
%--------------------------------------------------------------------------
xstim_obj  = obj.xstim_obj;
sim_logger = xstim_obj.sim__getLogInfo;

%NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale
obj.adjustBoundsGivenMaxScale(signed_max_scale,'sim_logger',sim_logger)

%Step 3: Retrieval of thresholds
%--------------------------------------------------------------------------
done = false;
while ~done
    
    thresholds = xstim_obj.sim__getThresholdsMulipleLocations(obj.getXYZlattice(true),...
        'threshold_sign',sign(stim_levels(1)),'initialized_logger',sim_logger);
    
    %TODO: Implement gradient testing
    
    %   Determine area of large gradient, test maybe 10 - 20 places
    %   see how they compare to interpolation values at those locations
    %   if they are too different, then change scale and rerun
    %
    %   If they are close, then do interpolation and return result
    done = true;
end

abs_thresholds = abs(thresholds);

%Possible Improvement: Shrink bounds here to only interpolate over
%region where thresholds are within range

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

%This is a temporary variable used to all interpolated values over
%all y and z but only one set of x points
thresh_values_interpolated = zeros(dx,dy*(ny-1),n_z_final);

fprintf('Integrating Volume')

percentage_display_mask = false(1,nx);
percentage_display_mask(ceil((0.1:0.1:0.9)*nx)) = true;

for ix = 1:nx-1
    last_y_index = 0;
    
    %Print progress to command window, keep on same line
    if percentage_display_mask(ix)
        fprintf(', %0.0f%%',100*ix/nx);
    end
    
    %iterating over abs_thresholds
    %- abs_thresholds(ix,:,:)
    if ~any(abs_thresholds(ix,:,:) <= abs_max_scale)
        continue
    end
    
    for iy = 1:ny-1
        last_z_index = 0;
        for iz = 1:nz-1
            thresh_values_interpolated(:,last_y_index+1:last_y_index+dy,last_z_index+1:last_z_index+dz) = ...
                f1*abs_thresholds(ix, iy,   iz)   + f2*abs_thresholds(ix+1, iy  , iz)   + ...
                f3*abs_thresholds(ix, iy+1, iz)   + f4*abs_thresholds(ix+1, iy+1, iz)   + ...
                f5*abs_thresholds(ix, iy  , iz+1) + f6*abs_thresholds(ix+1, iy  , iz+1) + ...
                f7*abs_thresholds(ix, iy+1, iz+1) + f8*abs_thresholds(ix+1, iy+1, iz+1);
            last_z_index = last_z_index + dz;
        end
        last_y_index = last_y_index + dy;
    end
    
    %Let's update counts here.
    %----------------------------------------------------------------
    %- We could wait for all loops over x but this would stress the
    %memory of the computer
    %- We could do this inside the z loop, but the extra function calls
    %would probably slow things down
    
    %This approach is quicker and more efficient than histc but relies
    %heavily on the amplitudes of interest being 1:1:abs_max_scale
    %
    %We could do multiplication
    
    truncated_data = ceil(thresh_values_interpolated(:,:,1:max_z_index_keep));
    ranged_data    = truncated_data(truncated_data <= abs_max_scale);
    if ~isempty(ranged_data)
        %accumarray counts how many of each integer it sees
        %and places that count at the corresponding index, i.e. the
        %value at index
        %7 will tell us how many 7s are presented in 'ranged_data'
        %or more specifically, how many points in space had a threshold
        %between 6 and 7 (as ceil() rounds all these values up to 7
        %
        %Using cumsum we can get the total # of points with thresholds
        %below each integer value.
        N                 = accumarray(ranged_data(:),ones(numel(ranged_data),1),[abs_max_scale 1]);
        N_cumulative      = cumsum(N);
        stim_level_counts = stim_level_counts + N_cumulative;
        
        %This code is equivalent but I find it to be slower ...
        %             N2 = histc(thresh_values_interpolated(:,:,1:max_z_index_keep),stim_levels_histc,3);
        %             N2_xy = reshape(N2,[n_xy n_stim]);
        %             N2_cumulative = cumsum(N2_xy(:,1:end-1),2);
        %             N3_cumulative = sum(N2_cumulative,1);
        %
        %             if any(N_cumulative' ~= N3_cumulative(1:length(N)))
        %                 keyboard
        %             end
    end
    
end

fprintf('\n'); %Terminates line for progress display.

stim_level_counts = stim_level_counts'; %Transpose back to row vector

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

% %1) Get New Bounds
% %--------------------------------------------------------------------------
% n_replication_points = size(in.replication_points,1);
% 
% min_replication_points = min(in.replication_points);
% max_replication_points = max(in.replication_points);
% 
% new_min_extents = obj.bounds(1,:) + min_replication_points;
% new_max_extents = obj.bounds(2,:) + max_replication_points;
% 
% x = new_min_extents(1):obj.step_size:new_max_extents(1);
% y = new_min_extents(2):obj.step_size:new_max_extents(2);
% z = new_min_extents(3):obj.step_size:new_max_extents(3);
% 
% %2) Interpolate all voltages to "new points" on lattice
% %--------------------------------------------------------------------------
% V_temp = NaN(length(y),length(x),length(z),n_replication_points);
% 
% 
% 
% [Xo,Yo,Zo] = meshgrid(xyz_orig{:});
% 
% [Xn,Yn,Zn] = meshgrid(x,y,z);
% 
% for iPoint = 1:n_replication_points
%     shift_x = in.replication_points(iPoint,1) - in.replication_center(1);
%     shift_y = in.replication_points(iPoint,2) - in.replication_center(1);
%     shift_z = in.replication_points(iPoint,3) - in.replication_center(1);
%     V_temp(:,:,:,iPoint) = interp3(Xo+shift_x, Yo+shift_y, Zo+shift_z,abs_thresholds,Xn,Yn,Zn);
% end
% % % 
% % % %Take min over all replicated points, then switch x&y to be correct
% % % replicated_thresholds = permute(min(V_temp,[],4),[2 1 3]);

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