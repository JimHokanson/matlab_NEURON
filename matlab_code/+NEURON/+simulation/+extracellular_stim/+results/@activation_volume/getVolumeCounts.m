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

in.interp_method = 'linear';
in.max_MB        = 500;
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
%-----------------------------------------------
xstim_obj  = obj.xstim_obj;
sim_logger = xstim_obj.sim__getLogInfo;

%NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale
obj.adjustBoundsGivenMaxScale(signed_max_scale,'sim_logger',sim_logger)

%Step 3: Retrieval of thresholds
%-----------------------------------------------
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

%Step 4
%---------------------------------------------------
%Get counts

[x,y,z] = obj.getXYZlattice(false);

%NOTE: This makes an assumption of interpolating at the 1 micron level
%i.e. the step size is 1 micron (overall units are in microns)
xi_final = (x(1):x(end))';
yi_final = (y(1):y(end))';
zi_final = (z(1):z(end))';

internode_length = obj.getInternodeLength;

F = griddedInterpolant({x,y,z},abs_thresholds,in.interp_method);

nz = length(zi_final);
nx = length(xi_final);
ny = length(yi_final);

%Let's linearize thresholding over x & y, i.e. go by linear indexing

%This # is used to conserve memory to an appropriate level.

REPLICATION_FACTOR = 9; %How many times we create a vector of the max size
%1 thresholds
%2 reshaped thresholds
%3 linear indices
%6 sub indices i,j,k
%9 locations, xyz (only temporary)

n_samples_per_loop = floor(in.max_MB*1e6/(nz*8))/REPLICATION_FACTOR; 
n_samples_per_loop = max(n_samples_per_loop,MIN_SAMPLES_PER_LOOP);
n_samples_total    = nx*ny;

n_loops_total      = ceil(n_samples_total/n_samples_per_loop);


z_indices_offset = 0:n_samples_total:(n_samples_total*(nz-1));

%These values will be used for histc, see explanation on histc 
%usage below
stim_levels_histc = [0; abs(stim_levels(:))];

h = waitbar(0,'Producing Counts');
cur_start_index = 0;
for iLoop = 1:n_loops_total
   
   %Indices will index into x-y points, we'll run all z at once ...
   cur_indices     = cur_start_index+1:cur_start_index+n_samples_per_loop;
   cur_start_index = cur_start_index + n_samples_per_loop;
   
   if cur_indices(end) > n_samples_total
      cur_indices(cur_indices > n_samples_total) = [];
   end
   
   n_current_indices = length(cur_indices);
   
   %replication to account for all z values
   %---------------------------------------------------------------------
   %- this order ensures the x & y values are first then the value at z
   %- this is important for the reshape operation below
   all_indices = bsxfun(@plus,cur_indices(:),z_indices_offset);
   
   [I,J,K] = ind2sub([nx ny nz],all_indices(:));
   
   thresholds_interpolated   = F([xi_final(I) yi_final(J) zi_final(K)]);
   
   %IMPORTANT: the reshaped matrix is [xy by z]
   thresholds_interpolated_r = reshape(thresholds_interpolated,[n_current_indices nz]);
   
   
   
   %Now we want to test all stim levels
   
   %Consider as an example thresholds for 4,6,8
   %- The first bin will be 0 - 4, values in this bin have thresholds below 4
   %- The 2nd bin will be for 4 - 6, here 6 is above threshold ...
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
   
   %This sets a limit on the # of times a bin can be counted in the z
   %dimension since you can only activate an axon once in this model
   N_cumulative(N_cumulative > internode_length) = internode_length;
   
   stim_level_counts = stim_level_counts + sum(N_cumulative,1);
     
   waitbar(iLoop/n_loops_total,h);
end

close(h)

end

