classdef xstim_logger < NEURON.logger.ID_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.xstim_logger
    
    properties (Constant)
       ID_LOGGER__PROPS = {'elec_objs' 'cell_obj' 'props' 'tissue_obj'};
    end
    
    methods
        function obj = xstim_logger(varargin)
           obj@NEURON.logger.ID_logger(varargin{:}); 
        end
    end
    %notes:
    % MIMs should prolly be a singeton, but this does not necesarily have
    % to be.. this is because it will simply be handling abunch of loggers
    % that are already singletons
    %
    % This also does not necessarily need to be able to find itself does
    % it? Or is MIMs just the struct that we will save...
end

