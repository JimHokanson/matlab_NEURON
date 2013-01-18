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
            in = processVarargin(in,varargin);
            
            obj@NEURON.simulation(in);
            
            obj.threshold_options_obj  = threshold_options;
            obj.ev_man_obj             = event_manager(obj);
            obj.data_transfer_obj      = data_transfer(obj,obj.sim_hash);
            obj.threshold_analysis_obj = threshold_analysis(obj,obj.cmd_obj);
            
        end
    end
    
    methods (Static)
       obj = create_standard_sim(varargin)  
    end
    
    %EVENT HANDLING  ======================================================
    methods
        %NOTE: The event manager object is reponsible is responsible
        %for handling changes in NEURON from changes in Matlab. Given that
        %one may construct the objects before associating them with this
        %object, these methods are needed ...
        function set_Tissue(obj,tissue_obj)
            obj.tissue_obj = tissue_obj;
            tissueChanged(obj.ev_man_obj);
        end
        function set_Electrodes(obj,elec_objs)
            obj.elec_objs = elec_objs;
        end
        function set_CellModel(obj,cell_obj)
            obj.cell_obj = cell_obj;
            
            %NOTE: We might need to clear everything
            %if a new cell object is defined ...
            
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
        
        %This is some code that needs to be updated. Its goal is to
        %determine stimulus threshold in a volume.
        %NOTE: This will be replaced with the sim_logger code
        %and the threshold_analysis object
        function init__simulation(obj)
           obj.init__verifyAssignedObjects();
           
           obj.init__setupThresholdInfo(); 
           
           obj.cell_obj.createExtracellularStimCell();
           
           obj.init__create_stim_info();
           
        end
        function sim_logger = sim__getLogInfo(obj)
            sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
            
            %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
            sim_logger.initializeLogging(obj); 
        end
        function sim__create_logging_data(obj,varargin)
            %
            %
            %   sim__create_logging_data(obj,varargin)
            %
            %   OPTIONAL INPUTS
            %   ===========================================================
            
            
            
            
            %wtf = NEURON.simulation.extracellular_stim.create_standard_sim;
            %wtf.sim__create_logging_data()
            
            in.cell_locations = {-500:20:500 -500:20:500 -500:20:500};
            in = processVarargin(in,varargin);
            
            sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
            
            %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
            sim_logger.initializeLogging(obj);
            
            %NEURON.simulation.extracellular_stim.sim_logger.getThresholds
            sim_logger.getThresholds(in.cell_locations,1);
            
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
            %    simulation are defined ...
            %
            %    init__verifyAssignedObjects(obj)
            %
            %    KNOWN CALLERS:
            %    ==========================================================
            %    NEURON.simulation.extracellular_stim.event_manager
            
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
            %NOTE: This method might be more appropriate in
            %moving towards the event manager
            %
            %Alternatively, the event manager call in the sim cases
            %might move here instead ...
            %
            %    initSystem(obj.ev_man_obj)
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
    
    %TESTING =========================================================
    methods(Static)
        function potentialTesting(varargin)
            %
            %    NEURON.simulation.extracellular_stim.potentialTesting
            %
            %
            %    OLD METHOD: Needs updating
            
            
            
            %??? - how to update or process pieces of varargin
            %- like adding on not to run NEURON process
            %and then passing to create_standard_sim
            error('Needs updating ...')
            
            
            in.TISSUE_RESISTIVITY   = 500;
            in.STIM_START_TIME      = 0.3;
            in.STIM_SCALE_1         = [1 -0.5];
            in.STIM_SCALE_2         = [-1 0.5];
            in.STIM_DURATION_1      = [0.2 0.4];
            in.STIM_DURATION_2      = [0.2 0.4];
            in.ELECTRODE_LOCATIONS  = [-200 0 0; 200 0 0];
            in.plot_option          = 2;
            obj = NEURON.simulation.extracellular_stim;
            
            %tissue ------------------------------------------------
            set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.TISSUE_RESISTIVITY));
            
            %stimulation electrode ---------------------------------
            e_objs = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATIONS);
            
            setStimPattern(e_objs(1),in.STIM_START_TIME,in.STIM_DURATION_1,in.STIM_SCALE_1);
            setStimPattern(e_objs(2),in.STIM_START_TIME,in.STIM_DURATION_2,in.STIM_SCALE_2);
            
            set_Electrodes(obj,e_objs);
            
            %cell ---------------------------------------------------
            %set_CellModel(obj,NEURON.cell.axon.MRG(in.CELL_CENTER))
            
            %NEURON.simulation.extracellular_stim.showPotentialPlane
            %NEURON.simulation.extracellular_stim.showPotentialTwoElectrodes
            
            switch in.plot_option
                case 1
                    showPotentialPlane(obj)
                case 2
                    showPotentialTwoElectrodes(obj)
            end
            
        end
        function default_run_single_stim(varargin)
            %TODO: Rely upon create_standard_sim
        end
        function default_run_determine_threshold(varargin)
            %TODO: Rely upon create_standard_sim
        end
        function extras = defaultRun(debug,stim_amp,varargin)
            %NEURON.simulation.extracellular_stim.defaultRun
            %
            %   Calling form (Static Method)
            %   NEURON.simulation.extracellular_stim.defaultRun(debug,stim_amp,varargin)
            %
            %   OPTIONAL INPUTS
            %   ==========================================================
            %
            %   TODO: Expand this to allow a basic demo of all methods
            %
            %   i.e. allow selection of the method to run ...
            %
            %   NOTE: stim threshold with defaults should be -2.40 ish
            
            in.TISSUE_RESISTIVITY = 500;
            in.ELECTRODE_LOCATION = [0 0 0];
            in.CELL_CENTER        = [0 50 0];
            in.STIMULUS_AMP       = -1;
            in.STIM_START_TIME    = 0.2;
            in.STIM_DURATIONS     = [0.2 0.4];
            in.STIM_SCALES        = [1 -0.5];
            in.STARTING_STIM_AMP  = stim_amp;
            in.save_data          = true;
            in.run_option         = 2;
            in = processVarargin(in,varargin);
            
            obj = NEURON.simulation.extracellular_stim('debug',debug);
            
            %tissue ------------------------------------------------
            set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.TISSUE_RESISTIVITY));
            
            %stimulation electrode ---------------------------------
            e_obj = NEURON.extracellular_stim_electrode.create(in.ELECTRODE_LOCATION);
            setStimPattern(e_obj,in.STIM_START_TIME,in.STIM_DURATIONS,in.STIM_SCALES);
            set_Electrodes(obj,e_obj);
            
            %cell ---------------------------------------------------
            set_CellModel(obj,NEURON.cell.axon.MRG(in.CELL_CENTER))
            
            %This is the part I should put on a switch statement ...
            %==============================================================
            %apFired = single_stim(obj,stim_amp);
            
            switch in.run_option
                case 1
                    sim__single_stim(obj,stim_amp);
                case 2
                    %NEURON.simulation.extracellular_stim.sim__determine_threshold
                    extras = sim__determine_threshold(obj,in.STARTING_STIM_AMP);
                    disp(extras.getSummaryString);
            end
        end
    end
end
