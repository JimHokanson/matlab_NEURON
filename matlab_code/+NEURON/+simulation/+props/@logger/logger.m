classdef logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.simulation.props.logger
    %   NEURON.simulation.props
    %
    
    properties(Constant)
        VERSION = 1;
        CLASS_NAME = 'NEURON.simulation.props';
        TYPE  = 1; 
    end
    
    properties(Constant) 
        IS_SINGULAR_OBJECT = true;
        PROCESSING_INFO = {...
            'celsius'       'vectorFP'      ''
            'tstop'         'vectorFP'      ''
            'dt'            'vectorFP'      ''}
    end
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    
    methods(Static)
        function obj = getInstance(varargin)
            persistent p_logger
            c_handle = @NEURON.simulation.props.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
end