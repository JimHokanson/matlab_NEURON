classdef dim_reduction_options < sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.dim_reduction_options
    %
    %   See Also:
    %   
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow for dimension normalization
    %   2) Allow for variance explained after the first dimension
    
    
    %PCA properties =======================================================
    properties
       %Could allow for dimension normalization ...
       %
        
       VARIANCE_TO_KEEP  = 0.99
       MIN_PCA_DIMS_KEEP = 2 %This is the # of dimensions to keep
       %irrespective of the explained variance. The actual number kept may
       %be less if the PCA function returns less.
       %
       %    Example: If we want to keep a minimum of 3 dimensions, and 5 
       %    valid dimensions exist, and our threshold is 99% which occurs
       %    at 1 dimension, then we will keep the 3 dimensions.
       %
       %    Alternatively, if we only get back 2 valid dimensions, then we
       %    will only be able to keep 2, we don't (currently) artificially
       %    inflate the dimensions back up to 3 by adding zeros.
    end
    
    methods
    end
    
end

