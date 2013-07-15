%This code should update the stimulus solution format from
%the old approach to the new one

r = sim__getThresholdsMulipleLocations2(obj,cell_locations,varargin);
%[solution,predictor_info] = r.getSolution();

thresholds = sim__getThresholdsMulipleLocations(obj,cell_locations,varargin);