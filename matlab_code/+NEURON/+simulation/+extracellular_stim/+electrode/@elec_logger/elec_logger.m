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
    
    methods
        function obj = elec_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end 
%         function event = makeEvent(obj, xyz, stim, time)
%             %propagate this appropriately...???
%             %momentarily assuming this functions exist... they don't
%             event{1} = xyz();
%             event{2} = stim();
%             event{3} = time();
%             obj.loggable = obj;
%         end
    end
    
end

