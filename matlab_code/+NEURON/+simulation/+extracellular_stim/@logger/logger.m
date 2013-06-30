classdef (Hidden) logger < NEURON.logger.ID_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.logger
    
    properties(Constant)
        VERSION     = 1
        CLASS_NAME  = 'NEURON.xstim'
        TYPE        = 1
    end
    
    properties (Constant)
        PROPS_TO_LOG = {'elec_objs' 'cell_obj' 'props' 'tissue_obj'};
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.ID_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getInstance(varargin)
            persistent p_logger
            c_handle = @NEURON.simulation.extracellular_stim.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
end

