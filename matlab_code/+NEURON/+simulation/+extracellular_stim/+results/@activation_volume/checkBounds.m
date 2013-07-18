function [too_small,min_abs_value_per_side,thresholds_by_side,threshold_xyz] = ...
    checkBounds(obj,max_scale)
%checkBounds
%
%   [too_small,min_abs_value_per_side,thresholds_by_side,threshold_xyz] = checkBounds(obj,max_scale)
%
%   This function gets the thresholds for on all sides of the volume
%   (except in z since an axon model is assumed) and then checks whether or
%   not thresholds on any side are less than the max_scale, indicating that
%   the bounds need to be expanded.
%
%   OUTPUTS
%   =======================================================================
%   too_small : (logical, [1 x 4]), for each side this describes whether
%       the minimum threshold on the side is less than the maximum scale to
%       test (too_small(side) = true),(suggesting the need to test larger
%       values), or false, indicating that the smallest value is less than
%       the maximum scale to test, suggesting the the current bounds
%       encompass all values at that scale ...
%   min_abs_value : ([1 x 4]) for each side this the the minimum amplitude
%       observed
%   thresholds_by_side : (cell array of arrays, [1 x 4]), for each side
%       this are the threshold values
%   threshold_xyz :  (cell array of arrays, [1 x 4], each array contains a
%   cell array shaped in the same way as the threshold data, each value in
%   that cell array contains a [1 x 3], xyz point
%       for example =>
%           thresholds_by_side{1} size [75 x 11]
%           thresholds_by_xyz{1}  => {75 x 11}
%               thresholds_by_xyz{1}{1} => [1 x 3]
%                   
%   Sides: left,right,bottom,top
%
%   INPUTS
%   =======================================================================
%   max_scale :
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim__getThresholdsMulipleLocations
%       NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale
%       NEURON.simulation.extracellular_stim.results.activation_volume.populateVolumeCounts
%
%   FULL PATH:
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds


threshold_sign = sign(max_scale);

[x,y,z]   = obj.getXYZlattice();
xstim_obj = obj.xstim_obj;

%Step 1:  Get xyz
%-------------------------------------------------------------
%NOTE: Here the goal is to get a 2d plane of thresholds corresponding to
%the current bounds. We then merge these locations and ask for the
%thresholds for all points included in these planar bounds. Finally we need
%to take our results and go back to thresholds that are in terms of the
%planes. Alternatively we could solve for each plane separately, but
%internally this is a lot slower than running all points at once.

%NOTE: We don't retrieve values for two sides of the cube under the
%assumption that z has been properly extended given an axon model

cell_xyz_left   = {x(1)   y      z};
cell_xyz_right  = {x(end) y      z};
cell_xyz_bottom = {x      y(1)   z};
cell_xyz_top    = {x      y(end) z};

xyz_sides = {...
    cell_xyz_left ...
    cell_xyz_right ...
    cell_xyz_bottom ...
    cell_xyz_top};

xyz_linear = cell(1,4);
for iSide = 1:4
    xyz_linear{iSide} = helper__getXYZmesh(xyz_sides{iSide});
end

n_elements_per_side = cellfun(@(x) size(x,1),xyz_linear);
xyz_all             = vertcat(xyz_linear{:});

%Step 2: Compute thresholds
%--------------------------------------------------------------------------

if isempty(obj.request_handler)
t_all = xstim_obj.sim__getThresholdsMulipleLocations(...
    xyz_all,...
    'threshold_sign',threshold_sign,...
    'initialized_logger',obj.sim_logger);
else
   r = obj.request_handler;
   s = r.getSolution(xyz_all);
   t_all = s.thresholds;
end



%Step 3: Put thresholds back into a per side basis
%--------------------------------------------------------------------------
I_end   = cumsum(n_elements_per_side);
I_start = [1 I_end(1:end-1)+1];

thresholds_by_side = cell(1,4);
threshold_xyz      = cell(1,4);
for iSide = 1:4
    cur_start = I_start(iSide);
    cur_end   = I_end(iSide);
    [thresholds_by_side{iSide},threshold_xyz{iSide}] = ...
        helper__getThresholdReshaped(t_all(cur_start:cur_end),xyz_sides{iSide},xyz_all(cur_start:cur_end,:));
end

%Step 4: Edge detection
%--------------------------------------------------------------------------
min_abs_value_per_side = zeros(1,4);
for iSide = 1:4
    min_abs_value_per_side(iSide) = min(abs(thresholds_by_side{iSide}(:)));
end

too_small = min_abs_value_per_side < abs(max_scale);


end

function xyz = helper__getXYZmesh(cell_xyz)
[X,Y,Z] = meshgrid(cell_xyz{1},cell_xyz{2},cell_xyz{3});
xyz = [X(:) Y(:) Z(:)];
end

function [thresholds_out,threshold_xyz] = helper__getThresholdReshaped(thresholds_in,xyz_side_cell,xyz_side_matrix)
%
%
%   INPUTS
%   =======================================================================
%   thresholds_in : [1 x n_values], solved thresholds
%   xyz_side_cell : [1 x 3] cell array, each element contains a vector 
%       corresponding to x,y,or z values tested
%   xyz_matrix    : [1 x n_values], corresponding xyz points for each threshold points
%
%   OUTPUTS
%   =======================================================================
%   thresholds_out : 
n_values = size(xyz_side_matrix,1);

sz = cellfun('length',xyz_side_cell);
%Silly meshgrid :/
sz_r = [sz(2) sz(1) sz(3)];
t = reshape(thresholds_in,sz_r);
thresholds_out = squeeze(permute(t,[2 1 3]));

x1 = mat2cell(xyz_side_matrix,ones(1,n_values),3);
x2 = reshape(x1,sz_r);

threshold_xyz = squeeze(permute(x2,[2 1 3 4]));

end