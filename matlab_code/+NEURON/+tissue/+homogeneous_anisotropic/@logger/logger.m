classdef logger < NEURON.logger.auto_logger
    %
    %   Class:
    %   NEURON.tissue.homogeneous_anisotropic.logger
    %
    %   See Also
    %   --------
    %   NEURON.logger.auto_logger
    
    properties(Constant)
        VERSION = 1
        CLASS_NAME = 'NEURON.tissue.homogeneous_anisotropic'
        TYPE = 2 %Used to distinguish between different subclasses
    end
    
    properties (Constant)
        IS_SINGULAR_OBJECT = true; %i.e. we will never have multiples
        %of this class
        PROCESSING_INFO = {...
            'resistivity'       'vectorFP'      ''; ...
            'scale_type'          'simple_numeric'        ''}
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getInstance(varargin)
            persistent p_logger
            c_handle = @NEURON.tissue.homogeneous_anisotropic.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
end