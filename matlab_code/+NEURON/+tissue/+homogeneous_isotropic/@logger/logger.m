classdef logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.tissue.homogeneous_isotropic.logger	
    
    properties(Constant)
        VERSION    = 1
        CLASS_NAME = 'NEURON.tissue.homogeneous_isotropic'
        TYPE       = 1
    end
    
    properties(Constant)
        IS_SINGULAR_OBJECT = true;
        PROCESSING_INFO = {...
            'resistivity'       'vectorFP'      ''}
        %made the retrieval method empty
        %see NEURON.logger.auto_logger.getNewValue
        %    (line: 93 and 100) perhaps?
        %
        %Defined this as a vectorFP
        %is there a significant reason/need to define this as a scalar and
        %not a 1x1 vector array?
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end 
    end
     methods(Static)
        function obj = getInstance(varargin)
            persistent p_logger
            c_handle = @NEURON.tissue.homogeneous_isotropic.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
end