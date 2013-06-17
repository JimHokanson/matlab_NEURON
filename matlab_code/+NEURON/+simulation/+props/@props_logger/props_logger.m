classdef props_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.simulation.props.props_logger
    
    properties
        AUTO_LOGGER__IS_SINGULAR_OBJECT = true;
        AUTO_LOGGER__INFO = {...
            'celsius'       'scalarFP'      'numeric'
            'tstop'         'scalarFP'      'numeric'
            'dt'            'scalarFP'      'numeric'}
    end
    methods(Access = private)
        function obj = props_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getLogger(varargin)
            persistent p_logger
            if isempty(p_logger)
                obj = NEURON.simulation.props.props_logger(varargin{:});
                p_logger = obj;
            else
                p_logger.editParent(varargin{:});
            end
            obj = p_logger;
        end
    end
end