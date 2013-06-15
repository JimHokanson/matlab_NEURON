function estimated_thresholds = computeThresholdsRandomNeurons(obj,xyz_neurons,max_stim_level,varargin)
%
%
%   estimated_thresholds = computeThresholdsRandomNeurons(obj,xyz_neurons,max_stim_level,varargin)
%
%
%This function should compute the threshold for a randomly placed set
%of neurons.

in.replication_points = [];
in.replication_center = [0 0 0];
in = processVarargin(in,varargin);

[abs_thresholds,x,y,z] = obj.getThresholdsAndBounds(max_stim_level,in.replication_points,in.replication_center);

estimated_thresholds = interpn(x,y,z,abs_thresholds,xyz_neurons(:,1),xyz_neurons(:,2),xyz_neurons(:,3),'linear',NaN);

end