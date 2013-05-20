function [filtered_abs_thresholds,x_out,y_out] = ...
        truncateThresholdSolutionSpace(obj,abs_thresholds,max_abs_value,x,y)
%
%The goal is to truncate the solution space (in x-y) so that we don't have
%such a large span of the data
%
%Example:
%Let's consider data in the form
%30 20 10 0 10 20 30 <= threhsold data
%If the max we wanted to encompass is 13, then we would only need to keep 
%the data between the 20 values
%
%i.e. filtered_abs_thresholds:
%   20 10 0 10 20
%
%   The x & y data would adjust accordingly
%
%   Not yet implemented ...


end