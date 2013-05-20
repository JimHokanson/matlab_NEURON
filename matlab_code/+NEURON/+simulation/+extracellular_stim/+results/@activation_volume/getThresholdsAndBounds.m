function [abs_thresholds,x,y,z] = getThresholdsAndBounds(obj,max_stim_level,replication_points,replication_center)

%Check cache, if a miss, then retrieve data ...

if obj.cached_threshold_data_present && sign(obj.cached_max_stim_level) == sign(max_stim_level) && abs(obj.cached_max_stim_level) >= abs(max_stim_level)
   abs_thresholds = abs(obj.cached_threshold_data);
   
   %Update bounds for usage below ...
   obj.bounds     = obj.cached_threshold_bounds;
else
   abs_thresholds = abs(obj.getThresholdsEncompassingMaxScale(max_stim_level)); 
end

%TODO: Move to a separate function ...
%Step 4 - Get Counts
%--------------------------------------------------------------------------
if ~isempty(replication_points)
    [abs_thresholds,x,y,z] = helper__createReplicatedData(obj,abs_thresholds,replication_points,replication_center);
else
    [x,y,z] = obj.getXYZlattice(false); %false - return as vectors
end


end

function [replicated_thresholds,x,y,z] = helper__createReplicatedData(obj,abs_thresholds,replication_points,replication_center)
%
%   The goal of this function is to replicate data given the locations we
%   wish to replicate the data to. This is specifically for the single
%   electrode case.

xyz_orig         = obj.getXYZlattice(true);
[V_temp,xyz_new] = arrayfcns.replicate3dData(abs_thresholds,xyz_orig,...
    replication_points,obj.step_size,...
    'data_center',replication_center);

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
end