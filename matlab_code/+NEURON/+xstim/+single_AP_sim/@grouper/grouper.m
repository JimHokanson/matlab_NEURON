classdef grouper < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.grouper
    
    properties
       p %Reference to predictor object
       %
       %   Needs access to:
       %   1) new solution data
       %   2) old stimuli
       %   3) new stimuli 
    end
    
    properties (Hidden)
       initialized = false
    end
    
    methods
        function obj = grouper(p_obj)
           obj.p = p_obj;  
        end
        function indices = getNextGroup(obj)
           %Return an empty set of indices to finish ...
           %NOTE: We might just move the initialization to here ...
           if ~obj.initialized
              obj.initialize(); 
              %error('The object has not been initialized')
           end
           
           error('NOT YET FINISHED')
           
        end
    end
    
end

