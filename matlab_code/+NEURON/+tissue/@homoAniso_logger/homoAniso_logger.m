classdef homoAniso_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.tissue.homogeneous_anisotropic.homoAniso_logger
    
    properties(Constant)
        LOGGER__VERSION    = 1
        LOGGER__CLASS_NAME = 'NEURON.tissue.homogeneous_anisotropic.homoAniso_logger'
        LOGGER__TYPE       = 2
    end
    
    properties
        AUTO_LOGGER__IS_SINGULAR_OBJECT = true;
        AUTO_LOGGER__INFO = {...
            'resistivity'       'vectorFP'      'numeric'}
    end
    
    methods(Access = private)
        function obj = homoAniso_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getLogger(varargin)
            persistent ha_logger
            if isempty(ha_logger)
                obj = NEURON.tissue.homogeneous_anisotropic.homoAniso_logger(varargin);
                ha_logger = obj;
            else
                ha_logger.editParent(varargin{:});
            end
            obj = ha_logger;
        end
    end
end