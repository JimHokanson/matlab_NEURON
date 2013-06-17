classdef elec_logger < NEURON.loggable.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.electrode.elec_logger
    
    properties
        %loggable
        type = 1
        %next = 1
    end
    
    properties(Constant)
        VERSION = 1
        CLASS_NAME = 'elec_logger'
    end
    
    properties (Constant)
        IS_SINGULAR_OBJECT = false;
        AUTO_INFO = {'xyz'                       'cellFP'    'numeric'
                     'base_amplitudes'           'cellFP'    'numeric'
                     'stimulus_transition_times' 'cellFP'    'numeric'}   
                 %i need to better specify these types and be consistent
    end
    
    methods
        function obj = elec_logger(varargin)
            obj@NEURON.loggable.logger.auto_logger(varargin{:});
        end
        
        function event = makeEvent(obj, xyz, stim, time)
            %propagate this appropriately...???
            %momentarily assuming this functions exist... they don't
            event{1} = xyz();
            event{2} = stim();
            event{3} = time();
            obj.loggable = obj;
        end

    end
    
end

