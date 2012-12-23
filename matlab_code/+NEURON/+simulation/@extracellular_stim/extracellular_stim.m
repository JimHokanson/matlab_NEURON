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
        %--------------------------------------------------------
        v_all    %stim_times x n_electrodes
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
            
            %TODO: Make options a class for more explicit passing to 
            
            import NEURON.simulation.extracellular_stim.*
            
            in.run_NEURON = true;
            in.debug      = false;
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
            setEventManagerObject(obj.elec_objs,obj.ev_man_obj)
        end
        function set_CellModel(obj,cell_obj)
            obj.cell_obj = cell_obj;
            setSimObjects(obj.cell_obj,obj.cmd_obj,obj)
            setEventManagerObject(obj.cell_obj,obj.ev_man_obj)
            cellLocationChanged(obj.ev_man_obj);
        end
    end
    
    methods
        %This is some code that needs to be updated. Its goal is to
        %determine stimulus threshold in a volume.
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
           
            in.tissue_resistivity    = 500; 
            in.cell_center           = [0 100 0];
            
            in.launch_neuron_process = false; %NOT YET IMPLEMENTED
            
            in.electrode_locations   = [0 0 0]; %array, rows are entries ...
            in.stim_scales           = {[-1 0.5]}; %Could be cell array
            
            error('Code in progress')
            
            
            %obj = NEURON.simulation.extracellular_stim();
            
            %electrodes
            %locations
            %stim profiles
            
            in.ELECTRODE_LOCATION = [0 0 0];
            in.CELL_CENTER        = [0 50 0];
            in.STIMULUS_AMP       = -1;
            in.STIM_START_TIME    = 0.2;
            in.STIM_DURATIONS     = [0.2 0.4];
            in.STIM_SCALES        = [1 -0.5];
            in.STARTING_STIM_AMP  = stim_amp;
           
           
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
            
            switch in.plot_option
                case 1
                    showPotentialPlane(obj)
                case 2
                    showPotentialTwoElectrodes(obj)
            end
            
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
                    %fprintf('SIMULATION FINISHED: AP FIRED = %d\n',apFired);
                    extras = [];
                    %NEURON.simulation.extracellular_stim.sim__determine_threshold
                    [thresh_value,n_loops] = sim__determine_threshold(obj,in.STARTING_STIM_AMP);
                    fprintf('SIMULATION FINISHED: THRESHOLD = %0g, n_loops = %d\n',thresh_value,n_loops);
            end
        end
    end 
end
