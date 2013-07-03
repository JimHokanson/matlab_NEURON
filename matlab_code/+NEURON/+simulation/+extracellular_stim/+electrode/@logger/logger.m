classdef logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.electrode.logger
    
    properties(Constant)
        VERSION    = 1
        CLASS_NAME = 'NEURON.simulation.extracellular_stim.electrode'
        TYPE       = 1
    end
    
    properties (Constant)
        IS_SINGULAR_OBJECT = false;
        PROCESSING_INFO = {...
            'xyz'                       'cellFP'    'numeric'
            'stimulus_transition_times' 'cellFP'    'varying'
            'base_amplitudes'           'cellFP'    'varying'}   
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end 
    end
    
    methods(Static)
        function obj = getInstance(varargin)
            persistent p_logger
            c_handle = @NEURON.simulation.extracellular_stim.electrode.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
    
end

