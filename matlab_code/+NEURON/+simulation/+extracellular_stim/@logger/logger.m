classdef (Hidden) logger < NEURON.logger.ID_logger
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.logger
    %
    %   We inherit from the ID_logger because we only worry about logging
    %   properties (that are objects themselves) of this class.
    %
    %   See Also
    %   --------
    
    properties(Constant)
        VERSION     = 1
        CLASS_NAME  = 'NEURON.xstim'
        TYPE        = 1
    end
    
    properties (Constant)
        PROPS_TO_LOG = {'elec_objs' 'cell_obj' 'props' 'tissue_obj'};
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            %
            %   This is called by:
            %   
            %
            %Call the super's constructor
            obj@NEURON.logger.ID_logger(varargin{:});
            
            %this < ID_logger < NEURON.logger
        end
    end
    methods(Static)
        function obj = getInstance(varargin)
            %
            %   For logging we need singletons to not corrupt the
            %   "database"
            
            persistent p_logger
            
            %c_handle : class constructor handle
            c_handle = @NEURON.simulation.extracellular_stim.logger;
            
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
        end
    end
end

