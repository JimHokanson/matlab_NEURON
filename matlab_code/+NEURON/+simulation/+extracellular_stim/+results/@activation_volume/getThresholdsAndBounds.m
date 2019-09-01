function [abs_thresholds,x,y,z,extras] = getThresholdsAndBounds(obj,max_stim_level,replication_points,varargin)
%
%   [abs_thresholds,x,y,z,extras] = getThresholdsAndBounds(obj,max_stim_level,replication_points)
%
%
%
%   extras:
%       .mean_rep_error
%       .electrode_thresholds
%       .electrode_interaction_thresholds
%       .electrode_z_locations
%
%   See Also:
%       #OBJ.getThresholdsEncompassingMaxScale
%
%   FULL PATH
%   NEURON.simulation.extracellular_stim.results.activation_volume.getThresholdsAndBounds

in.bounds_guess = []; %NYI
in = NEURON.sl.in.processVarargin(in,varargin);

extras = struct;

%Check cache, if a miss, then retrieve data ...
if obj.cached_threshold_data_present && ...
        sign(obj.cached_max_stim_level) == sign(max_stim_level) && ...
        abs(obj.cached_max_stim_level) >= abs(max_stim_level)
    
    abs_thresholds = abs(obj.cached_threshold_data);
    
    %Update bounds for usage below ...
    obj.bounds     = obj.cached_threshold_bounds;
else
    abs_thresholds = abs(obj.getThresholdsEncompassingMaxScale(max_stim_level));
end

%TODO: Move to a separate function ...
%--------------------------------------------------------------------------
if ~isempty(replication_points)
    [abs_thresholds,x,y,z,replication_extras] = helper__createReplicatedData(obj,abs_thresholds,replication_points);
    extras.replication_extras = replication_extras;
else
    [x,y,z] = obj.getXYZlattice(false); %false - return as vectors
end


end

function [replicated_thresholds,x,y,z,extras] = ...
    helper__createReplicatedData(obj,abs_thresholds,replication_points)
%
%   The goal of this function is to replicate data given the locations we
%   wish to replicate the data to. This is specifically for the single
%   electrode case.
%
%   Inputs
%   ------
%   abs_thresholds :
%   replication_points :
%
%   Outputs
%   -------
%   replicated_thresholds :
%   extras : struct
%       .electrode_interaction_thresholds
%       .electrode_thresholds : [x y z elec] - spatially replicated 
%               thresholds per electrode
%   .mean_rep_error


%What is the final z  value that is output?
%It is zero centered on the first electrode ...

%TODO: Document this code and clean it up ...

%ASSUMPTION: Axon model that repeats along z-axis ...
%We're going to change the z-axis so that the volume data is correct
%Consider 2 electrodes separated by a given amount in the z-direction

%
%
%
%        Fixed spacing between electrodes
%            |--------------------|
%          1                         2
%     o---------o
%     |-- INL --|
%
%   NOTE: Our model says in the independent case, the threshold results
%   from 1 would be the same as 2
%
%          1                         2
%     98765456789               98765456789  <= thresholds

%   Example Neuron:
%          1                         2
%     98765456789               98765456789
%          o---------o---------o---------o---------o
%   Threshold from electrode 1: 4
%   Threshold from electrode 2: 8
%   (Algorithm: find where the nodes are relative to the electrode)
%
%   To combine them we must move the results from 2 over by a
%   set of INLs until they cover the same range as 1
%
%   START: (no shift yet)
%
%          1
%     o---------o
%     98765456789
%                                    2
%                               o---------o
%                               98765456789
%                2
%           o---------o---------o---------o  (2 shifted)
%           98765456789
%
%   NOTE: Since we only have one INL of data once we cover one side, we are
%   going to be missing the other side. Below, the location of 1 is set at
%   z = 0. If we are to the right of 1, then we need to make an aditional
%   copy to the left, shifting by the INL. If to the left, then shift to
%   the right. No shift is necessary if it exactly lines up with 1.
%   The final result is:
%
%   All duplicates aligned:
%
%          1
%     o---------o
%     98765456789
%
%                2
%           o---------o
%           98765456789
%       2
% o---------o
% 98765456789   <=Notice how the solution repeats itself (9 === 9)
%
%   These then get merged and the lowest threshold at each point is the
%   final threshold at that location. The final result from above would be:
%
%          1
%     o---------o
%     98765456789         Intermediate lines ...
% 987654567898765456789   <= Combination of results from both 2's
%
%     54565456765    <= Final result (min of each point above)
%
%   Let's see how this holds up to examples:
%
%          1                         2
%     o---------o               o---------o
%     98765456789               98765456789           E1   E2  min
%          o---------o---------o---------o---------o  4    8   4
%     o---------o---------o---------o---------o       9    5   5
%     54565456765  <= final solution from above
%
%   NOTE: This "final solution" thus tells us the minimum stimulus
%   needed to activate a particular neuron from stimulation on either
%   electrode 1 or electrode 2. This process scales up to any number of
%   independent electrodes. The critical assumptions to this are:
%
%   1) the neuron repeats itself with the same properties every INL
%   2) no deviation of neuron in x-y plane as it travels in z
%        - in reality this is probably not true but small enough
%         over distances of interest. If the distances become too
%         large this may no longer be true.


%IMPORTANT: I modified the code so that it was centered on
%z = 0, not on the first electrode ...

z_use = replication_points(:,3);
INL = obj.getInternodeLength;

n_points   = size(replication_points,1);
if n_points == 1
    error('This function should not be called with only a single location')
end
new_points = zeros(2*n_points,3);

%These are the new z-values for the first set of points. The second set of
%points will equal this value, +/- an INL, unless the point is at z = 0,
%then we won't replicate.
first_z_values = mod(z_use,INL);

%To keep track of which solution goes to which electrode. Each electrode
%gets a maximum of 2 points.
electrode_ids = ones(1,2*n_points);

electrode_z_locations = zeros(1,n_points);

cur_point  = 0;
for iPoint = 1:n_points
    
    %Assignment of x-y, these don't change
    %-------------------------------------------------
    cur_point = cur_point + 1;
    new_points(cur_point,1:2) = replication_points(iPoint,1:2);
    electrode_ids(cur_point)  = iPoint;
    
    %Assignment of new z values
    cur_z = first_z_values(iPoint);
    new_points(cur_point,3) = cur_z;
    
    %Addition of a second point to allow for full coverage with
    %the z-range covered by the first electrode
    if cur_z ~= 0
        %Assignment of x-y, these don't change
        %-------------------------------------------------
        cur_point = cur_point + 1;
        new_points(cur_point,1:2) = replication_points(iPoint,1:2);
        electrode_ids(cur_point)  = iPoint;
        new_points(cur_point,3)   = cur_z - INL;
        cur_electrode_z_values = new_points(cur_point-1:cur_point,3);
        [~,I] = min(abs(cur_electrode_z_values));
        electrode_z_locations(iPoint) = cur_electrode_z_values(I);
    %else
        %NULL ASSIGNMENT
        %electrode_z_locations(iPoint) = 0;
    end
end

%Truncate unused points
%------------------------------------------------------
electrode_ids(cur_point+1:end) = [];
new_points(cur_point+1:end,:)  = [];

%Actual data evaluation
%====================================================================
xyz_orig         = obj.getXYZlattice(true);
[V_temp,xyz_new] = arrayfcns.replicate3dData(abs_thresholds,xyz_orig,...
                        new_points,obj.step_size,'z_bounds',[xyz_orig{3}(1) xyz_orig{3}(end)]);

%
%This is debugging code. Errpr from replication analysis. If we do this
%right then any points that overlap and are from one of the two sets from
%the same electrode should have the same value.
%
%   I.E. consider the following solution:
%
%    o-------o
%   89876567898
%
%   Now consider this is spatially replicated in the following way:
%
%      ============   <= spatial region that must be covered
%
%            o-------o
%           89876567898
%    o-------o
%   89876567898
%           ===   <= area of overlap due to not perfectly
%                    solving only from -INL/2 to INL/2
%                    Instead we solve from -(INL/2+e) to (INL/2+e)
%                    which gives us some overlap when replicating
%==========================================================================
I_bad = find(electrode_ids(1:end-1) == electrode_ids(2:end));
all_error = [];
for iPoint = 1:length(I_bad)
    
    index_1 = I_bad(iPoint);
    index_2 = index_1+1;
    
    v_left  = V_temp(:,:,:,index_1);
    v_right = V_temp(:,:,:,index_2);
    
    m1 = squeeze(any(any(~isnan(v_left),1),2));
    m2 = squeeze(any(any(~isnan(v_right),1),2));
    overlap_mask = m1 & m2;
    t_error = abs(squeeze(v_left(:,:,overlap_mask)) - squeeze(v_right(:,:,overlap_mask)));
    
    t_error(isnan(t_error)) = [];
    
    all_error = [all_error; t_error(:)]; %#ok<AGROW>
    
    cur_point = cur_point + 2;
end

mean_rep_error = mean(all_error);

x = xyz_new{1};
y = xyz_new{2};
z = xyz_new{3};

extras.mean_rep_error = mean_rep_error;

%==========================================================================
[~,~,uI] = unique(electrode_ids);

sz = size(V_temp);
electrode_thresholds = zeros(sz(1),sz(2),sz(3),n_points);
for iU = 1:n_points
    %Note, due to replication in z, these should be roughly the same
    electrode_thresholds(:,:,:,iU) = min(V_temp(:,:,:,iU == uI),[],4);
end

extras.electrode_thresholds = electrode_thresholds;
%==========================================================================
electrode_interaction_thresholds = zeros(n_points,n_points);

%Determine lowest stimulation amplitude
%at which the stimuli begin to merge
for i1 = 1:n_points
    for i2 = i1+1:n_points
        t1 = electrode_thresholds(:,:,:,i1);
        t2 = electrode_thresholds(:,:,:,i2);
        threshold_diff =  t1 - t2;
        FV = isosurface(threshold_diff,0);
        
        v = FV.vertices;
        if isempty(v)
            min_vq = NaN;
        else
            %Yikes, isosurface uses meshgrid, so we need
            %to use interp3 or switch x and y
            %
            %NOTE: vq should be zero here ...
            %vq = interp3(threshold_diff,v(:,1),v(:,2),v(:,3));
            vq = interp3(t1,v(:,1),v(:,2),v(:,3));
            min_vq = min(vq(:));
        end
        electrode_interaction_thresholds(i1,i2) = min_vq;
        electrode_interaction_thresholds(i2,i1) = min_vq;
    end
end
extras.electrode_interaction_thresholds = electrode_interaction_thresholds;
%==========================================================================
extras.electrode_z_locations            = electrode_z_locations;
%electrode_thresholds = ...

%NOTE: This is where we combine multiple electrodes together, using the
%lowest threshold at any spatial location
replicated_thresholds = squeeze(min(V_temp,[],4));
% % % % % keep_mask = z >= - half_z_diff & z <= half_z_diff;
% % % % %
% % % % % z = z(keep_mask);
% % % % % replicated_thresholds = replicated_thresholds(:,:,keep_mask);


%Note on following bit:
%=========================================================================
%The ugly change above should ensure that this never happens ...

%3) NaN check in Z
%--------------------------------------------------------------------------
%We currently assume that we can truncate in z, since the solution should
%repeat itself in that dimension. This is not true if the solution is
%the result of z-expansion, where real data doesn't fill the z axis.

%Example
%1   NaN NaN
%2   3   NaN
%4   3   1
%NaN 3   2
%NaN NaN 4

%We'll currently just check that we don't have this problem. It should only
%occur with replicating points that vary in z.
%For each z we need to decide where to interpolate
%==========================================================================
xy_any_NaN = any(isnan(replicated_thresholds),3);
xy_all_NaN = all(isnan(replicated_thresholds),3);

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
    %
    %    -- xy -- |
    %    1 3 1    |
    %    2 3 2    z
    %    4 3 4    |
    %             |
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
    %    for the rows by putting the 1 & 5 next to each other. In addition
    %    if we need 3 values, column 1 doesn't have enough tested values,
    %    but again earlier code which sets the z-axis based on the internode
    %    length must have failed for this to occur.
    %
    
end
%==========================================================================



end