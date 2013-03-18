function [too_small,min_abs_value_per_side] = checkBounds(obj,max_scale,varargin)
%checkBounds
%
%   [too_small,min_abs_value_per_side] = checkBounds(obj,max_scale,varargin)
%
%   
%   IMPROVEMENTS
%   =======================================================================
%   1) Change output return order to match bounds indexing order:
%       x_min,x_max,y_min,y_max -> left,right,bottom,top
%       This would allow us to index 1:4 bounds(1) -> too_small(1)
%
%
%   Return 4 sides activation volume, not interpolated
%
%   Sides: bottom, top, left, right
%
%   OPTIONAL INPUTS
%   ===================================================
%   sim_logger : (default []), 
%
%   See Also:
%       NEURON.simulation.extracellular_stim.sim__getThresholdsMulipleLocations
%
%   FULL PATH: 
%       NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds

in.sim_logger = [];
in = processVarargin(in,varargin);

threshold_sign = sign(max_scale);

[x,y,z]   = obj.getXYZlattice();
xstim_obj = obj.xstim_obj;

%Step 1:  Get xyz
%-------------------------------------------------------------
cell_xyz_bottom = {x y(1) z};
cell_xyz_top    = {x y(end) z};
cell_xyz_left   = {x(1) y z};
cell_xyz_right  = {x(end) y z};

cell_xyz_all = {...
        cell_xyz_bottom ...
        cell_xyz_top ...
        cell_xyz_left ...
        cell_xyz_right};
    
xyz_linear = cell(1,4);
for iSide = 1:4
    xyz_linear{iSide} = getXYZmesh(cell_xyz_all{iSide});
end

n_elements_per_side = cellfun(@(x) size(x,1),xyz_linear);
xyz_all = vertcat(xyz_linear{:});

%Step 2: Compute thresholds
%--------------------------------------------------------------------------
t_all = xstim_obj.sim__getThresholdsMulipleLocations(xyz_all,...
            'threshold_sign',threshold_sign,'initialized_logger',in.sim_logger);

%Step 3: Put thresholds back into a per side basis
%--------------------------------------------------------------------------
I_end   = cumsum(n_elements_per_side);
I_start = [1 I_end(1:end-1)+1]; 

thresh_ca = cell(1,4);
for iSide = 1:4
   cur_start = I_start(iSide);
   cur_end   = I_end(iSide);
   thresh_ca{iSide} = squeeze(getThresholdReshaped(t_all(cur_start:cur_end),cell_xyz_all{iSide})); 
end

%Step 4: Edge detection
%--------------------------------------------------------------------------
min_abs_value_per_side = zeros(1,4);
for iSide = 1:4
   min_abs_value_per_side(iSide) = min(abs(thresh_ca{iSide}(:))); 
end
   
too_small = min_abs_value_per_side < abs(max_scale);


end

function xyz = getXYZmesh(cell_xyz)
    [X,Y,Z] = meshgrid(cell_xyz{1},cell_xyz{2},cell_xyz{3});
    xyz = [X(:) Y(:) Z(:)];
end

function thresholds = getThresholdReshaped(thresholds,cell_xyz)
    sz = cellfun('length',cell_xyz);
    %Silly meshgrid :/
    t = reshape(thresholds,[sz(2) sz(1) sz(3)]);
    thresholds = permute(t,[2 1 3]);
end