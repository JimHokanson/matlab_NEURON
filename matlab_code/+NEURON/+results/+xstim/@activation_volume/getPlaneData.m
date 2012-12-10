function [thresh_data,extras] = getPlaneData(obj,plane,depth,varargin)
%getPlaneData
%
%   thresh_data = getPlaneData(obj,plane,depth)
%
%   INPUTS
%   ===================================================
%   plane : string of two letters, 'xy' 'yx' 'yz' etc
%   depth : depth out of plane to examine ...
%
%   OPTIONAL INPUTS
%   ==========================================================
%   resolution    : (default 1) step size for data retrieval
%   replicate     : (default true), if true symettry is analyzed
%                   on the basis of zero bounds, and the data is duplicated
%                   around symettric axes (for plotting purposes)
%   interp_method : (default cubic), interp3 interpolation method
%                   - 'nearest','linear','spline','cubic' 
%
%   OUTPUTS
%   ==========================================================
%   thresh_data   : interpolated threshold data
%   
%   IMPROVEMENTS
%   ===========================================================
%   None needed at this time ...

in.resolution    = 1;
in.replicate     = true; %Whether or not to flip around axis, note could make [1 x 3] as well
in.interp_method = 'cubic'; 
in = processVarargin(in,varargin);

%---------------------------------------------------
plane_str = 'xyz';
dim_indices     = zeros(1,3);
dim_indices(1)  = strfind(plane_str,plane(1));
dim_indices(2)  = strfind(plane_str,plane(2));
dim_indices(3)  = find(~ismember(1:3,dim_indices(1:2)));
non_plane_dimension = dim_indices(3);

all_bounds = obj.all_bounds; %3 x 2, dims x [min max]
%---------------------------------------------------
interp_values = cell(1,3);
for iDim = 1:3
    interp_values{iDim} = all_bounds(iDim,1):in.resolution:all_bounds(iDim,2);
end

%---------------------------------------------------
bounds_depth = all_bounds(non_plane_dimension,:);

%HANDLE DEPTH CHECKING
%might need to flip depth about axis ...
if depth > bounds_depth(2) || depth < bounds_depth(1)
    %Try flipping if symmetric ...
    if bounds_depth(1) == 0
       depth = -1*depth;
    else
        error('Requested depth is outside range')
    end
    
    if depth > bounds_depth(2) || depth < bounds_depth(1)
        error('Requested depth is outside range')
    end
end

interp_values{non_plane_dimension} = depth; %Single value here ...

%---------------------------------------------------

%Alternatively we do meshgrid here ...
%NOTE: Need to flip x & y to maintain order
[Xo,Yo,Zo] = meshgrid(obj.y_solution,obj.x_solution,obj.z_solution);
[Xi,Yi,Zi] = meshgrid(interp_values{[2 1 3]});
thresh_data = interp3(Xo,Yo,Zo,obj.thresh_matrix,Xi,Yi,Zi,['*' in.interp_method]);

x_plot = interp_values{dim_indices(1)};
y_plot = interp_values{dim_indices(2)};

if in.replicate 
   for iDim = 1:3    
       if all_bounds(iDim,1) == 0 && dim_indices(3) ~= iDim
          bounds_end   = size(thresh_data);
          if length(bounds_end) == 2
              bounds_end = [bounds_end 1];
          end
          bounds_start = ones(1,3);
          bounds_start(iDim) = 2;
          bounds = arrayfun(@(x,y) x:y,bounds_start,bounds_end,'un',0);
          %Really I need a function that goes from
          %3 4 5
          %to 1:3,1:4,1:5 as cells
          
% % %           for iDim2 = 1:3
% % %              if iDim2 == iDim
% % %                  bounds(iDim2) = 2:bounds(iDim2);
% % %              else
% % %                  bounds(iDim2) = 1:bounds(iDim2);
% % %              end
% % %           end
% % %           bounds = num2cell(bounds);
% % %           %what a mess, change this 
% % %           %all I am trying to do is remove the redundant 0 ...
          thresh_data = cat(iDim,flipdim(thresh_data,iDim),thresh_data(bounds{:}));
          
          if iDim == dim_indices(1)
              x_plot = [-1*x_plot(end:-1:1) x_plot(2:end)];
          end
          if iDim == dim_indices(2)
              y_plot = [-1*y_plot(end:-1:1) y_plot(2:end)];
          end
          
       end
   end
end

extras = struct;
extras.x_plot = x_plot;
extras.y_plot = y_plot;

%Reorder in plane dimensions plane(1) x plane(2)
thresh_data = permute(thresh_data,dim_indices); %Note 3rd dimension after

fHandle = @()(helper__plot_plane_data(x_plot,y_plot,thresh_data));

extras.fHandle = fHandle;


end

function helper__plot_plane_data(x_plot,y_plot,data)
%TODO: make the -1 optional
    imagesc(x_plot,y_plot,-1*data')
    set(gca,'YDir','Normal')
    
end
