function plot__AppliedStimulus(obj,stim_scale)
%
%   The goal is to show a summary of the stimulus being applied to a cell
%   
%   Plot approaches:
%   1) plot in 2d
%   2) plot in 3d with colors
%
%   TODO: Rename functions to delineate options
%   NOTE: This will be the 2d option
%   
%
%
%TODO: Add on more options like which time set to plot
%For now default to 1 - or
%
%    IMPROVEMENTS
%    ============================================
%    1) Allow plotting of multiple time points
%    as well as the locations of the electrodes relative to the
%    cell ...

if ~exist('stim_scale','var')
    stim_scale = 1;
end


%For each cell, we need the ability to get:
%1) A 2d projection with x locations
%2) indices that correspond to each x location
%3) Do we want to insert NaN breaks for discontinuous parts
%      or just return different sections in a cell array?
%
%   Something like:
%       x   = {1 x 2}
%       ind = {1 x 2}
%       labels???
%
%   What would we do then with each part???




%NOTE: This is currently only accurate for axons
%It does not handle splits ...

%NOTE: We will change this interface in a bit to reference
%an object that manages this information instead of calling
%this method and then retrieving properties ...
[tvec,vall,cell_xyz_all]    = obj.computeStimulus;

[tvec2,vall2,cell_xyz_all2] = obj.computeStimulus('nodes_only',true);

%xyz_cell = obj.cell_obj.xyz_all;

plot(cell_xyz_all(:,3)./1e3,stim_scale*vall(2,:)','or','MarkerSize',5,'MarkerFaceColor','r')
hold on
plot(cell_xyz_all2(:,3)./1e3,stim_scale*vall2(2,:)','ob','MarkerSize',10,'MarkerFaceColor','b')
hold off
xlabel('Distance Along Axon (mm)')
ylabel('Applied Potential (mV)')


% squared_diff       = (xyz_cell(2:end,:)-xyz_cell(1:end-1,:)).^2;
% length_btwn_points = sqrt(sum(squared_diff,2))';
% 
% dist_along_cell = [0 cumsum(length_btwn_points)];
% 
% %NOTE: There is lots of room for improvement here ...
% plot(dist_along_cell./1e3,stim_scale*obj.v_all(2,:)')


%dist_along_cell = [0 diff

%plot(v_all

end