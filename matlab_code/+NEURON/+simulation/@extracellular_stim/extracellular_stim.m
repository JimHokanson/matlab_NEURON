classdef extracellular_stim < NEURON.simulation
    %
    %   
    %   Class: 
    %       NEURON.simulation.extracellular_stim
    %
    %   HOW TO CALL
    %   ===================================================================
    %   1) NEURON.simulation.extracellular_stim.create_standard_sim
    %
    %   Simulation Methods
    %   ===================================================================
    %
    %   NEURON.simulation.extracellular_stim.sim__single_stim
    %   NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
    %   NEURON.simulation.extracellular_stim.sim__determine_threshold
    %   NEURON.simulation.extracellular_stim.sim__getActivationVolume
    %
    %   Package Classes
    %   ===================================================================
    %   data_transfer
    %   event_manager
    %   threshold_analysis
    %   threshold_options
    %

    
    %   PROPERTIES FROM OTHERS
    %   =================================================================
    %   FROM NEURON.simulation - NOTE: Unfortunately there are many more ...
    %   -------------------------
    %   n_obj    : (Class NEURON)
    %   cmd_obj  : (Class NEURON.cmd)
    %   sim_hash : String
    
    %OPTIONS =============================================================
    properties
        threshold_options_obj   %Class: NEURON.simulation.extracellular_stim.threshold_options
        ev_man_obj              %Class: NEURON.simulation.extracellular_stim.event_manager
        data_transfer_obj       %Class: NEURON.simulation.extracellular_stim.data_transfer
        threshold_analysis_obj  %Class: NEURON.simulation.extracellular_stim.threshold_analysis
    end
    
    properties (SetAccess = private)
        %Populate by using the set methods
        tissue_obj   %(Subclass of NEURON.tissue)
        %                   NEURON.tissue.homogeneous_anisotropic
        %                   NEURON.tissue.homogeneous_isotropic
        elec_objs    %(Class NEURON.extracellular_stim_electrode)
        cell_obj     %(Class neural_cell), singular
    end
    
    properties
        %.init__create_stim_info()
        %.computeStimulus()
        %-------------------------------------------------------
        v_all    %stim_times x stim sites on cell
        t_vec    %1 x stim times
        %NOTE: Stim times is any time in which any stimulus changes (i.e.
        %from any electrode), as this will change the electric field that
        %the cell is in. It will also include a time at zero (NOTE: This
        %night change) to indicate that at time zero there is generally no
        %stimulus.
    end
    
    %Latest configurations
    properties
       tissue_configuration    = []
       electrode_configuration = []
       cell_configuration      = []
    end
    
    %INITIALIZATION METHODS ==============================================
    methods
        function obj = extracellular_stim(varargin)
            %
            %
            %   obj = extracellular_stim(varargin)
            
            import NEURON.simulation.extracellular_stim.*
            
            in.launch_NEURON_process = true;
            in.debug                 = false;
            in.log_commands          = false;
            in = processVarargin(in,varargin);
            
            obj@NEURON.simulation(in);
            
            obj.threshold_options_obj  = threshold_options;
            obj.ev_man_obj             = event_manager(obj);
            obj.data_transfer_obj      = data_transfer(obj,obj.sim_hash);
            obj.threshold_analysis_obj = threshold_analysis(obj,obj.cmd_obj);
            
        end
        function init__simulation(obj)
           %init__simulation Initializes simulation before being run
           %
           %    init__simulation(obj)
           %
           %    NOTE: Most simulation methods should call this class before
           %    running. A known current exception is the simulation
           %    logging calls which call methods which call this function
           %    ...
           %
           %    For more information on event order see the Event Order
           %    documentation file in the private folder of this class.
           %
           %    FULL PATH:
           %        NEURON.simulation.extracellular_stim.init__simulation
           
           obj.init__verifyAssignedObjects();
           
           obj.init__setupThresholdInfo(); 
           
           obj.cell_obj.createExtracellularStimCell();
           
           obj.init__create_stim_info();
           
        end
        
    end
    
    methods (Static)
       obj = create_standard_sim(varargin)  
    end
    
    %EVENT HANDLING  ======================================================
    methods
        function set_Tissue(obj,tissue_obj)
            obj.tissue_obj = tissue_obj;
        end
        function set_Electrodes(obj,elec_objs)
            obj.elec_objs = elec_objs;
        end
        function set_CellModel(obj,cell_obj)
            obj.cell_obj = cell_obj;
            
            %NOTE: We might need to clear everything
            %if a new cell object is defined ...
            %In other words, if the cell_obj is not empty
            %we might need to change things ...
            
            obj.cell_obj.setSimObjects(obj.cmd_obj,obj);
            
            %NOTE: This must follow population of this object
            %in the cell class
            obj.data_transfer_obj.initializeDataSavingPaths();
        end
    end
    
    %SIMULATION METHODS ===================================================
    methods
        %sim__determine_threshold
        %sim__getCurrentDistanceCurve
        %sim__single_stim
        

        function sim_logger = sim__getLogInfo(obj)
            sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
            
            %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
            sim_logger.initializeLogging(obj); 
        end
        function thresholds = sim__getThresholdsMulipleLocations(obj,cell_locations,varargin)
            %
            %
            %   sim__create_logging_data(obj,varargin)
            %
            %   OPTIONAL INPUTS
            %   ===========================================================
            in.threshold_sign = 1;
            in = processVarargin(in,varargin);
            
            sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
            
            %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
            sim_logger.initializeLogging(obj);
            
            %NEURON.simulation.extracellular_stim.sim_logger.getThresholds
            thresholds = sim_logger.getThresholds(cell_locations,in.threshold_sign);
            
        end
        
        function act_obj = sim__get_activation_volume(obj,file_save_path,x_bounds,y_bounds,z_bounds)
            %TODO: Fix me ...
            act_obj = NEURON.results.xstim.activation_volume.get(obj,file_save_path,x_bounds,y_bounds,z_bounds);
        end
    end
    
    methods
        function n = getNumberNonZeroStimTimes(obj)
            %getNumberNonZeroStimTimes
            %
            %    Why was this method written?????
            %
            %   I'd like to delete it
            n = length(find(any(obj.v_all,2)));
        end
    end
    
    %INITIALIZATION  =====================================================
    methods (Access = private)
        function init__verifyAssignedObjects(obj)
            %init__verifyAssignedObjects
            %
            %    Verifies that all objects which are necessary for this
            %    simulation are defined. These incldue:
            %       1) Electrode Object
            %       2) Tissue Object
            %       3) Cell Object
            %
            %    init__verifyAssignedObjects(obj)
            %
            %    See Also:
            %       NEURON.simulation.extracellular_stim.init__simulation
            
            if ~isobject(obj.tissue_obj)
                error('Tissue object must be specified before initializing system')
            end

            if ~isobject(obj.elec_objs)
                error('Electrodes must be specified before running simulations')
            end
            
            if ~isobject(obj.cell_obj)
                error('Neural cell must be specified before running simulation')
            end
        end
        function init__setupThresholdInfo(obj)
            %
            %   init__setupThresholdInfo
            %
            %    See Also:
            %        NEURON.simulation.extracellular_stim.sim__single_stim
            %        NEURON.simulation.extracellular_stim.sim__determine_threshold

            obj.threshold_analysis_obj.threshold_info = obj.cell_obj.getThresholdInfo();
        end
    end
    
    %PLOTTING  ============================================================
    methods
        %NEURON.simulation.extracellular_stim.plot__AppliedStimulus
    end
end
