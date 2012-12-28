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
%

obj.computeStimulus;

%How to plot spatial information?????
%Each cell should return different parts and segments
%indices of continuous parts
%names
%TODO: Improve this eventually ...

%ASSUMPTION: For now we'll assume one part ...

xyz_cell = obj.cell_obj.xyz_all;

keyboard

%dist_along_cell = [0 diff


end