function stim_level_counts = getVolumeCounts(obj,stim_levels,varargin)
%getVolumeCounts
%
%   stim_level_counts = getVolumeCounts(obj,stim_levels,varargin)
%   
%   OUTPUTS
%   =======================================================================
%   stim_level_counts : for each stimulus level input this specifies the #
%       of cubic microns
%
%   OPTIONAL INPUTS
%   =======================================================================
%   interp_method : (default 'linear'), this is the interpolation method
%       used for griddedInterpolant
%   max_MB        : (default 500), how much memory (roughly) to use during
%           interpolation. This unfortunately didn't end up having as much
%           of an effect on speed as I expected 
%           I tested 200 MB to 8 GB with no appreciable difference in
%           overall speed.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) ind2sub could be removed, it is very slow
%   2) implement filtering - to avoid double counting with replications ...
%   3) Implement gradient testing to ensure that the mesh is significantly
%      refined enough to allow interpolation.
%
%   See Also:
%       griddedInterpolant
%       NEURON.simulation.extracellular_stim
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.results.activation_volume.populateVolumeCounts

MIN_SAMPLES_PER_LOOP = 100;

in.interp_method      = 'linear';
in.max_MB             = 500;
in.replication_points = []; 
in.replication_center = [0 0 0];
in = processVarargin(in,varargin);


stim_level_counts = zeros(1,length(stim_levels));

%Step 1: Stim level input processing
%---------------------------------------------------------------
%This is a little messy :/
if isempty(stim_levels)
    error('stim_levels can not be empty')
end

if ~all(sign(stim_levels) == sign(stim_levels(1)))
    error('All stim levels to test must have the same sign')
end

abs_max_scale = max(abs(stim_levels));

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
%   if they are close, then do interpolation and return result
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

%The code below makes an assumption of interpolating at the 1 micron level
%i.e. the step size is 1 micron (overall units are in microns)
xi_final = (x(1):x(end))';
yi_final = (y(1):y(end))';
zi_final = (z(1):z(end))';

%This code only supports axon models. For axon models we will limit
%interpolation to the internode length as we assume the axon is infinite
%and is the same when shifted by the internode length.
internode_length = obj.getInternodeLength;
max_z_index_keep = floor(internode_length);

%griddedInterpolant is a new Matlab class for repeated interpolation calls
F = griddedInterpolant({x,y,z},abs_thresholds,in.interp_method);

%This is needed below for going from linear indices to actual xyz points
nx = length(xi_final);
ny = length(yi_final);
nz = length(zi_final);

if nz < max_z_index_keep
   %TODO: Provide more detail in error -> give #s
   error('Insufficient testing volume given length of current fiber') 
end

%Let's linearize thresholding over x & y, i.e. go by linear indexing

%This # is used to conserve memory to an appropriate level.

REPLICATION_FACTOR = 9; %How many times we create a vector of the max size
%1 thresholds
%2 reshaped thresholds
%3 linear indices
%6 sub indices i,j,k
%9 locations, xyz (only temporary)

%8 - represents # of bytes per sample (double)
n_samples_per_loop = floor(in.max_MB*1e6/(nz*8))/REPLICATION_FACTOR; 
n_samples_per_loop = max(n_samples_per_loop,MIN_SAMPLES_PER_LOOP);
n_xy_samples_total = nx*ny;
n_loops_total      = ceil(n_xy_samples_total/n_samples_per_loop);

z_indices_offset = 0:n_xy_samples_total:(n_xy_samples_total*(nz-1));

%These values will be used for histc, see explanation on histc usage below
stim_levels_histc = [0; abs(stim_levels(:))];

h = waitbar(0,'Producing Counts');
cur_start_index = 0;
for iLoop = 1:n_loops_total
   
   %Generation of indices for traversing x-y points
   %----------------------------------------------------------------------
   %Indices will index into x-y points, we'll run all z at once ...
   cur_indices     = (cur_start_index + 1):(cur_start_index + n_samples_per_loop);
   cur_start_index = cur_start_index + n_samples_per_loop;
   
   if cur_indices(end) > n_xy_samples_total
      cur_indices(cur_indices > n_xy_samples_total) = [];
   end
   
   n_current_indices = length(cur_indices);
   
   %replication to account for all z values
   %---------------------------------------------------------------------
   %- this order ensures the x & y values are first then the value at z
   %- this is important for the reshape operation below
   all_indices = bsxfun(@plus,cur_indices(:),z_indices_offset);
   
   [I,J,K] = ind2sub([nx ny nz],all_indices(:));
   
   %Call to interpolation object to perform interpolation
   %Output is of the form samples x xyz
   thresholds_interpolated = F([xi_final(I) yi_final(J) zi_final(K)]);
   
   %Reshape the matrix to be [xy by z]
   thresholds_interpolated_r = reshape(thresholds_interpolated,[n_current_indices nz]);
   
   %Truncation to account for maximum internode length
   thresholds_interpolated_r(:,max_z_index_keep+1:end) = [];   
   
   %Now we want to calculate how many points have threshold below each
   %tested stimulus level.
   %-----------------------------------------------------------------------
   %Consider as an example thresholds for 4,6,8
   %- N = histc(x,edges)
   %
   %  N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1)      
   %
   %- For N(1), this will count the points between 0 and 4. Note that above
   %we padded the thresholds with a leading zero.
   %- We will not try to correct for the < Edges(k+1), instead of <=. This
   %implies way more numerical accuracy than we actually have.
   %- N(2) is for values which are between 4 & 6
   %- If we add N(1) + N(2), we get the # of points for which 6 is above
   %threshold.
   %- By operating in the 2nd dimension, we sum for each x-y point along
   %the values in z, i.e. N is a count along z
   %- The number of rows in N corresponds to the # of x-y points
   %(n_current_indices)
   %- The number of columns corresponds to each threshold division
   N = histc(thresholds_interpolated_r,stim_levels_histc,2);
   
   %- The cumalative sum is used as things which are above one threshold
   %are above all other thresholds tested. In other words, if a point has a
   %threshold below 4, it is also below 6
   %- The last bin indicates values equal to the highest value. We'll 
   %ignore this for now
   N_cumulative = cumsum(N(:,1:end-1),2);

   %- Summing in this dimension leaves in place counts for each stimulus
   %level that we are testing.
   stim_level_counts = stim_level_counts + sum(N_cumulative,1);
     
   waitbar(iLoop/n_loops_total,h);
end

close(h)

end

function [replicated_thresholds,x,y,z] = helper__createReplicatedData(obj,abs_thresholds,in)
%
%   The goal of this function is to replicate data given the locations we
%   wish to replicate the data to. This is specifically for the single
%   electrode case ...


%Ideally this code would be redone to be MUCH cleaner 
%-> interpolate all to same grid
%-> min on all

%1) Get New Bounds
%--------------------------------------------------------------------------
n_replication_points = size(in.replication_points,1);

min_replication_points = min(in.replication_points);
max_replication_points = max(in.replication_points);

new_min_extents = obj.bounds(1,:) + min_replication_points;
new_max_extents = obj.bounds(2,:) + max_replication_points;

x = new_min_extents(1):obj.step_size:new_max_extents(1);
y = new_min_extents(2):obj.step_size:new_max_extents(2);
z = new_min_extents(3):obj.step_size:new_max_extents(3);

%2) Interpolate all voltages to "new points" on lattice
%--------------------------------------------------------------------------
V_temp = NaN(length(y),length(x),length(z),n_replication_points);

xyz_orig = obj.getXYZlattice(true);

[Xo,Yo,Zo] = meshgrid(xyz_orig{:});

[Xn,Yn,Zn] = meshgrid(x,y,z);

%NOTE: Assumed zero center of replication for original ...



for iPoint = 1:n_replication_points
   shift_x = in.replication_points(iPoint,1) - in.replication_center(1);
   shift_y = in.replication_points(iPoint,2) - in.replication_center(1);
   shift_z = in.replication_points(iPoint,3) - in.replication_center(1);
   V_temp(:,:,:,iPoint) = interp3(Xo+shift_x, Yo+shift_y, Zo+shift_z,abs_thresholds,Xn,Yn,Zn);
end

%Take min over all replicated points, then switch x&y to be correct
replicated_thresholds = permute(min(V_temp,[],4),[2 1 3]);

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