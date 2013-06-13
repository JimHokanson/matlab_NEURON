classdef loggable < sl.obj.handle_light
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        logger = getLogger(obj)
        
    end
    
end

