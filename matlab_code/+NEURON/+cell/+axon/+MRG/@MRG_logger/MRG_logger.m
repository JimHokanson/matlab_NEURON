classdef MRG_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.cell.axon.MRG.MRG_logger
    
    properties(Constant)
        LOGGER__VERSION = 1;
        LOGGER__CLASS_NAME = 'NEURON.cell.axon.MRG.MRG_logger';
        LOGGER__TYPE  = 1;
    end
    
    properties(Constant) 
        AUTO_LOGGER__IS_SINGULAR_OBJECT = true;
        AUTO_LOGGER__INFO = {...
            'FIBER_DEPENDENT_PROPERTIES'        'structFP'     'cell'
            'NON_FIBER_DEPENDENT_PROPERTIES'    'structFP'     'cell'
            'props_obj'                         'class'        'class'
            'xyz_all'                           'cellFP'       'numeric'
            'xyz_center'                        'vectorFP'     'numeric'}
    end
    
    methods(Access = private)
        function obj = MRG_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getLogger(varargin)
            persistent m_logger
            if isempty(m_logger)
                obj = NEURON.cell.axon.MRG.MRG_logger(varargin{:});
                m_logger = obj;
            else
                m_logger.editParent(varargin{:});
            end
            obj = m_logger;
        end
    end
end