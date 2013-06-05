classdef xstim_logger < logger

    properties (Constant)
        VERSION = 1;
    end
    
    properties
        xstim_obj; % NEURON.simulation.extracellular_stim
    end
    
    properties
    end
    
    methods
        function obj = xstim_logger(xstim)
            obj = obj@logger();
            obj.xstim_obj = xstim;
        end
        
        %these are all more or less psuedo code for now...
        function save(obj)
            save@logger(obj);
        end
        
        function load(obj)
            load@logger(obj);
            %then do xstim specific stuff
        end
        
        function compare(obj)
            compare@logger(obj); %this is all wrong
        end
        
    end

end