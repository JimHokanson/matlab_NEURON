classdef extracellular_stim < NEURON.simulation
    %
    %   HOW TO CALL
    %   ===================================================================
    %   see testing functions (needs updating)
    %
    %   
    %   Simulation Methods
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.sim__single_stim
    %   NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
    %   NEURON.simulation.extracellular_stim.sim__determine_threshold
    %
    %   Package Classes
    %   ===================================================================
    %   data_transfer
    %   event_manager
    %   threshold_analysis
    %   threshold_options
    %
    %
    
    
    
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow this class to run without being connected to NEURON
    %       (for e field modeling purposes)
    %   2) Create option classes for passing things to the higher
    %   simulation class and the NEURON class, like using the java object 

    
    %   PROPERTIES FROM OTHERS
    %   =================================================================
    %   FROM NEURON.simulation - NOTE: Unfortunately there are many more ...
    %   -------------------------
    %   n_obj    : (Class NEURON)
    %   cmd_obj  : (Class NEURON.cmd)
    %   sim_hash : String
    
    %OPTIONS =============================================================
    properties
        threshold_options_obj   %Class: NEURON.simulation.extracellular_stim.threhsold_options
        ev_man_obj              %Class: NEURON.simulation.extracellular_stim.event_manager
        data_transfer_obj       %Class: NEURON.simulation.extracellular_stim.data_transfer
        threshold_analysis_obj  %Class: NEURON.simulation.extracellular_stim.threshold_analysis
    end
    
    properties (SetAccess = private)
        %Populate by using the set methods
        tissue_obj   %(Subclass of NEURON.tissue)
        %  NEURON.tissue.homogeneous_anisotropic
        %  NEURON.tissue.homogeneous_isotropic
        elec_objs    %(Class NEURON.extracellular_stim_electrode)
        cell_obj     %(Class neural_cell), singular
    end
    
    properties
        %.init__create_stim_info()
        %.computeStimulus()
        %--------------------------------------------------------
        v_all    %stim_times x stim sites on cell
        t_vec    %1 x stim times
        %NOTE: Stim times is any time in which any stimulus changes, as
        %this will change the electric field that the cell is in. It will
        %also include a time at zero (NOTE: Might change) to indicate that
        %at time zero there is generally no stimulus.
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
            stimElectrodesChanged(obj.ev_man_obj);
            n_electrodes = length(elec_objs);
            for iElectrode = 1:n_electrodes
                setEventManagerObject(obj.elec_objs(iElectrode),obj.ev_man_obj)
            end
        end
        function set_CellModel(obj,cell_obj)
            obj.cell_obj = cell_obj;
            setSimObjects(obj.cell_obj,obj.cmd_obj,obj)
            setEventManagerObject(obj.cell_obj,obj.ev_man_obj)
            cellLocationChanged(obj.ev_man_obj);
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
        
        function sim__create_logging_data(obj)
           %wtf = NEURON.simulation.extracellular_stim.create_standard_sim;
           %wtf.sim__create_logging_data()
           sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
           sim_logger.initializeLogging(obj);
           
           sim_logger.getThresholds({-100:20:100 -100:20:100 -500:20:500},1);
           
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
    methods
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
        function setupThresholdInfo(obj)
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
        function obj = create_standard_sim(varargin)
           %
           %
           %    obj = create_standard_sim(varargin)
           %    
           %    OPTIONAL INPUTS
           %    ===========================================================
           %    tissue_resistivity : (default 500 Ohm-cm, Units: Ohm-cm),
           %        either a 1 or 3 element vector ...
           %
           %
           %    FULL PATH:
           %    NEURON.simulation.extracellular_stim.create_standard_sim
           %
           %    TODO: Finish documenting optional inputs that are below
           %
           
            %Simulation properties:
            %----------------------------------------------
            in.launch_neuron_process = true; %NOT YET IMPLEMENTED
            in.debug                 = false;
            
            %Tissue properties:
            %--------------------------------------------------------
            in.tissue_resistivity    = 500; 
            
            %Cell properties:
            %--------------------------------------------------------
            in.cell_center           = [0 0 0];
            %in.cell_type             = 'MRG';
            
            %Electrode properties:
            %--------------------------------------------------------
            in.electrode_locations   = [0 100 0];    %Array, rows are entries ...
            in.stim_scales           = {[-1 0.5]}; %Cell array of arrays
            in.stim_durations        = {[0.2 0.4]};%" "  "  "
            in.stim_start_times      = 0.1;      %Array
            in = processVarargin(in,varargin);
            
            
            %TODO: add on checks for passed in electrode options ...
            
            %--------------------------------------------------------------
            obj = NEURON.simulation.extracellular_stim(...
                'launch_NEURON_process',in.launch_neuron_process,'debug',in.debug);

            set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.tissue_resistivity));
            
            %stimulation electrode ---------------------------------
            e_objs = NEURON.extracellular_stim_electrode.create(in.electrode_locations);
            n_electrodes = length(e_objs);
            for iElectrode = 1:n_electrodes
               setStimPattern(e_objs(iElectrode),...
                   in.stim_start_times(iElectrode),...
                   in.stim_durations{iElectrode},...
                   in.stim_scales{iElectrode}); 
            end
            set_Electrodes(obj,e_objs);
            
            %cell ---------------------------------------------------
            %TODO: Could expand to other cell types ...
            set_CellModel(obj,NEURON.cell.axon.MRG(in.cell_center))

        end
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
            e_obj = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
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
