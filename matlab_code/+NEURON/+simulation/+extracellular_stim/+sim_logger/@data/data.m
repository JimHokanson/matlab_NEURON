classdef data
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.data
    %
    
    %DATA FILE FORMAT
    %======================================================================
    %1) Applied Stimulus
    %
    %
    %   rows are observations, columns are data points on cell, data points
    %   from different times are concatenated after all points on the cell
    %   from a single time
    %   [point1_time1 point2_time1 point3_time1 point1_time2 point2_time2 etc]
    %
    %
    %
    %2) Relevant Stimulus Setup - This would let us know which type of stimuli
    %caused the applied stimulus observed, as differences in electrode setup
    %and magnitude are not something that differenties different groupings
    %of data, only stimulus durations and properties of the cell
    %3) Estimated critical transmembrane voltage? - i.e. at what voltage is
    %an action potential initiated. This could be useful in estimating 
    %new data
    %
    %4) # of points per cell - indicate
    %
    %5) Date of creating data
    
    
    properties
    end
    
    methods
    end
    
end

