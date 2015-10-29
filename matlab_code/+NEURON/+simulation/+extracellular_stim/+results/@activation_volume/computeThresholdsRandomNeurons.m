function estimated_thresholds = computeThresholdsRandomNeurons(obj,xyz_neurons,max_stim_level,varargin)
%
%
%   estimated_thresholds = computeThresholdsRandomNeurons(obj,xyz_neurons,max_stim_level,varargin)
%
%
%This function should compute the threshold for a randomly placed set
%of neurons.
%
%   NEURON.simulation.extracellular_stim.results.activation_volume.computeThresholdsRandomNeurons

in.replication_points = [];
in.replication_center = [0 0 0]; %JAH 2015_10 - I don't think this was ever implemented
in = NEURON.sl.in.processVarargin(in,varargin);

%getThresholdsAndBounds(obj,max_stim_level,replication_points,varargin)
%[abs_thresholds,x,y,z] = obj.getThresholdsAndBounds(max_stim_level,in.replication_points,in.replication_center);

[abs_thresholds,x,y,z] = obj.getThresholdsAndBounds(max_stim_level,in.replication_points);

estimated_thresholds = interpn(x,y,z,abs_thresholds,xyz_neurons(:,1),xyz_neurons(:,2),xyz_neurons(:,3),'linear',NaN);

end