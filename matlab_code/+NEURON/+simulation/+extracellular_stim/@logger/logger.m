classdef logger < NEURON.logger.ID_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.logger
    
    properties (Constant)
       ID_LOGGER__PROPS = {'elec_objs' 'cell_obj' 'props' 'tissue_obj'};
    end
    
    methods
        function obj = logger(varargin)
           obj@NEURON.logger.ID_logger(varargin{:}); 
        end
    end
    
end

