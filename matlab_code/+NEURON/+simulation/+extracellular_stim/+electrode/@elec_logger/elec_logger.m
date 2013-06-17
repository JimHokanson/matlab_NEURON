classdef elec_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.electrode.elec_logger
    
    properties(Constant)
        LOGGER__VERSION    = 1
        LOGGER__CLASS_NAME = 'NEURON.simulation.extracellular_stim.electrode.elec_logger'
        LOGGER__TYPE       = 1
    end
    
    properties (Constant)
        AUTO_LOGGER__IS_SINGULAR_OBJECT = false;
        AUTO_LOGGER__INFO = {...
            'xyz'                       'cellFP'    'numeric'
            'stimulus_transition_times' 'cellFP'    'numeric'
            'base_amplitudes'           'cellFP'    'numeric'}   
    end
    
    methods(Access = private)
        function obj = elec_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end 
    end
    
    methods(Static)
        function obj = getLogger(varargin)
            persistent e_logger
            if isempty(e_logger)
                obj = NEURON.simulation.extracellular_stim.electrode.elec_logger(varargin{:});
                e_logger = obj;
            else
                e_logger.editParent(varargin{:});
            end
            obj = e_logger;
        end
    end
    
end

