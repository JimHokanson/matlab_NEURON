function predicted_thresholds = predictThresholds(obj,new_indices)
%
%
%   CODE OUTLINE:
%   =======================================================================
%   1) Retrieve baseline data - we need to deduplicate the old data ...
%       - this might be a method of the predictor class
%   2) Pass results to some regression method
%
%   ?? - what if any data will be persistent???
%
%   OLD CODE:
%   NEURON.simulaton.extracellular_stim.threshold_predictor.predictThresholds
%
%
%
%
%   NOTE: This is not actually implemented properly yet ....

predicted_thresholds = obj.stim_sign*ones(1,length(new_indices));