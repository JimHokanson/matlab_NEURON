classdef (Hidden) loggable < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.loggable
    
    properties
    end
    
    methods (Abstract)
        logger = getLogger(obj)
    end
    
end

