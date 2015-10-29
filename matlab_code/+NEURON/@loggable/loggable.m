classdef (Hidden) loggable < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.loggable
    %
    %   This simply indicates that the class has a getLogger method.
    %
    %   Oh, if only Matlab supported interfaces ... :/
    
    properties
    end
    
    methods (Abstract)
        logger = getLogger(obj)
        %
        %logger: Subclass of NEURON.logger
    end
    
end

