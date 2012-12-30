function plot__AppliedStimulus(obj,stim_scale)
%
%   The goal is to show a summary of the stimulus being applied to a cell
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

%NOTE: This is currently only accurate for axons
%It does not handle splits ...


obj.computeStimulus;

%How to plot spatial information?????
%Each cell should return different parts and segments
%indices of continuous parts
%names
%TODO: Improve this eventually ...

%ASSUMPTION: For now we'll assume one part ...

xyz_cell = obj.cell_obj.xyz_all;

squared_diff       = (xyz_cell(2:end,:)-xyz_cell(1:end-1,:)).^2;
length_btwn_points = sqrt(sum(squared_diff,2))';

dist_along_cell = [0 cumsum(length_btwn_points)];

%NOTE: There is lots of room for improvement here ...
plot(dist_along_cell./1e3,obj.v_all(2,:)')
xlabel('Distance Along Axon (mm)')

%dist_along_cell = [0 diff

%plot(v_all

end