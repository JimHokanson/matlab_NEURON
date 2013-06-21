classdef xstim_logger < NEURON.logger.ID_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.xstim_logger
    
    properties(Constant)
        LOGGER__VERSION     = 1
        LOGGER__CLASS_NAME  = 'NEURON.simulation.extracellular_stim.xstim_logger'
        LOGGER__TYPE        = 1
    end
    
    
    properties (Constant)
        ID_LOGGER__PROPS = {'elec_objs' 'cell_obj' 'props' 'tissue_obj'};
        %ID_LOGGER__PROPS = {'elec_objs' 'props' 'tissue_obj'};
    end
    
    methods(Access = private)
        function obj = xstim_logger(varargin)
            obj@NEURON.logger.ID_logger(varargin{:});
        end
        
        %notes:
        % MIMs should prolly be a singeton, but this does not necesarily have
        % to be.. this is because it will simply be handling abunch of loggers
        % that are already singletons
        %
        % This also does not necessarily need to be able to find itself does
        % it? Or is MIMs just the struct that we will save... methods(Static)
    end
    methods(Static)
        function obj = getLogger(varargin)
            persistent x_logger
            if isempty(x_logger)
                obj = NEURON.simulation.extracellular_stim.xstim_logger(varargin{:});
                x_logger = obj;
            else
                x_logger.editParent(varargin{:});
            end
            obj = x_logger;
        end
    end
end

