classdef homoIso_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.tissue.homogeneous_isotropic.homoIso_logger	
    
    properties(Constant)
        LOGGER__VERSION    = 1
        LOGGER__CLASS_NAME = 'NEURON.tissue.homogeneous_isotropic.homoIso_logger'
        LOGGER__TYPE       = 1
    end
    
    properties(Constant)
        AUTO_LOGGER__IS_SINGULAR_OBJECT = true;
        AUTO_LOGGER__INFO = {...
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
        function obj = homoIso_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end 
    end
     methods(Static)
        function obj = getLogger(varargin)
            persistent hi_logger
            if isempty(hi_logger)
                obj = NEURON.tissue.homogeneous_isotropic.homoIso_logger(varargin{:});
                hi_logger = obj;
            else
                hi_logger.editParent(varargin{:});
            end
            obj = hi_logger;
        end
    end
end