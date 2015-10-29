function [new_data,xyz_new_data] = replicate3dData(data,xyz_data,replication_points,step_size,varargin)
%
%   [new_data,xyz_new_data] = arrayfcns.replicate3dData(data,xyz_data,replication_points,step_size,varargin)
%
%   This function takes 3d grid data represented by values and vectors that
%   specify its x,y,z coordinates, and replicates that data to a set of
%   points.
%
%   OUTPUTS
%   =======================================================================
%   new_data : (dims: x y z n_replication points), 
%   xyz_new_data : {x y z}, each element specifies the vector along which
%           the data has been evaluated
%
%   INPUTS
%   =======================================================================
%   xyz_cell : (cell [1x3]), {x y z} where x,y,and z represent vectors that
%           describe the spatial layout of data
%   replication_points : [points x xyz], points to replicate the data at
%   step_size : 1 element, step size for evaluating new data. For example,
%           the x data is evaluated from min_x:step_size:max_x where min_x
%           and max_x are the minimum and maximum x values in the new data
%           set after replicating the 
%
%   OPTIONAL INPUTS
%   =======================================================================
%   data_center : (default [0 0 0]), [x y z], center of the data. This
%           center is moved to each replication point.
%   z_bounds    : (default []), [min max], if specified uses the bounds
%           specified instead of basing it on the data ...
%
%
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Allow step size to be 1 element or 3 elements for specifying
%   different steps for x,y,and z
%   2) Bring out interp options to the user
%   3) Allow 3d interpolation on singleton dimensions
%
%   FULL PATH:
%       arrayfcns.replicate3dData

in.data_center = [0 0 0];
in.z_bounds    = [];
in = NEURON.sl.in.processVarargin(in,varargin);

%1) Get New Bounds
%--------------------------------------------------------------------------
n_replication_points   = size(replication_points,1);

min_replication_points = min(replication_points);
max_replication_points = max(replication_points);

%These two lines assume that the data is sorted ...
min_bounds = cellfun(@(x) x(1),xyz_data) - in.data_center;
max_bounds = cellfun(@(x) x(end),xyz_data) - in.data_center;

new_min_extents = min_bounds + min_replication_points;
new_max_extents = max_bounds + max_replication_points;

x = new_min_extents(1):step_size:new_max_extents(1);
y = new_min_extents(2):step_size:new_max_extents(2);

if isempty(in.z_bounds)
    z = new_min_extents(3):step_size:new_max_extents(3);
else
    z = in.z_bounds(1):step_size:in.z_bounds(2);
end

xyz_new_data = {x y z};

%2) Interpolate all voltages to "new points" on lattice
%--------------------------------------------------------------------------
new_data = NaN(length(x),length(y),length(z),n_replication_points);

for iPoint = 1:n_replication_points
    shift_x = replication_points(iPoint,1) - in.data_center(1);
    shift_y = replication_points(iPoint,2) - in.data_center(2);
    shift_z = replication_points(iPoint,3) - in.data_center(3);
    
    %NOTE: griddedInterpolant has a big bug in 2011b, fixed in 2012a
    
    temp_x_old = xyz_data{1}+shift_x;
    temp_y_old = xyz_data{2}+shift_y;
    temp_z_old = xyz_data{3}+shift_z;
    
    F = griddedInterpolant({temp_x_old,temp_y_old,temp_z_old},data,'linear','none');
    new_data(:,:,:,iPoint) = F(xyz_new_data);
end
