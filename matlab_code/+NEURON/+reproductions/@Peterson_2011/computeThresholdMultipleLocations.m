function thresholds = computeThresholdMultipleLocations(obj,xstim,cell_locs,method)
%
% thresholds = computeThresholdMultipleLocations(obj,xstim,cell_locs,method)
%
% Tests threshold at multiple electrodes using either MDF1 or MDF2 method
% This function simply moves the cell and tests one location at a time
% using computeThreshold
%
% Inputs:
% xstim: extracellular_stim obj (containing cell and electrode properties)
% cell_locs: cell or matrix of cell locations to test
% method: 1 for mdf1 or 2 for mdf2

% assume stationary electrode(s), moves cell

if iscell(cell_locs)
    [X,Y,Z] = meshgrid(cell_locs{:});
    cell_locs = [X(:) Y(:) Z(:)];
end
N_locs = size(cell_locs,1);

thresholds = zeros(N_locs,1);
for i_loc = 1:N_locs
    xstim.cell_obj.moveCenter(cell_locs(i_loc,:));
    thresholds(i_loc) = obj.computeThreshold(xstim,method);  
end

end