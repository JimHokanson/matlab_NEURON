classdef dim_reduction_options < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.dim_reduction_options
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    %   NEURON.xstim.single_AP_sim.applied_stimulus_manager
    %   
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Have method for finalizing object when the low dimensional
    %   stimuli have already been computed ....
    
    
    %PCA properties =======================================================
    properties
       VARIANCE_KEEP_METHOD = 'normal'
       %    - 'normal'      - the typical normalization method
       %    - 'after_first' - after keeping the first dimension ...
        
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
        function set.VARIANCE_KEEP_METHOD(obj,value)
           switch lower(value)
               case 'normal'
                   obj.VARIANCE_KEEP_METHOD = 'normal';
               case 'after_first'
                   obj.VARIANCE_KEEP_METHOD = 'after_first';
               otherwise
                   error('Unrecognized method: %s',value)
           end
        end
    end
    
end

