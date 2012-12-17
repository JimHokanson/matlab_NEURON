classdef extracellular_stim < NEURON.simulation
    %
    %   HOW TO CALL
    %   ===================================================================
    %   see testing functions (needs updating)
    %
    %   FILES USED FOR DATA TRANSER
    %   ====================================================================
    %   file                     Matlab                     NEURON
    %   inputs/[hash]v_ext.bin : init__create_stim_info : xstim__load_data
    %   inputs/[hash]t_vec.bin : init__create_stim_info : xstim__load_data
    %
    %
    %   THESE SECTIONS BELOW NEED UPDATING  -------------------------------
    %
    %   METHODS IN NEURON
    %   ===================================================================
    %   xstim__define_global_variables() :
    %   xstim__load_data()               :
    %
    %
    %
    %   VARIABLES IN NEURON
    %   ===================================================================
    %   xstim__t_vec       :
    %   xstim__v_ext_in    :
    %
    %
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   openExplorerToMfileDirectory('NEURON.simulation.extracellular_stim')
    %       currently doesn't work due to bug in code ...
    %
    %       NEURON.simulation.extracellular_stim.init__create_stim_info
    %       NEURON.simulation.extracellular_stim.sim__single_stim
    %       NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
    %       NEURON.simulation.extracellular_stim.sim__determine_threshold
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow this class to run without being connected to NEURON
    %       (for e field modeling purposes)
    %   2) Fix threshold_obj to be more accurate ...
    %   3) Create option classes for passing things to the higher
    %   simulation class and the NEURON class, like using the java object 
    %
    %   TESTING
    %   ===================================================
    %   NEURON.simulation.extracellular_stim.defaultRun
    %
    %   RELATED CLASSES
    %   =================================================================
    %
    %   PROPERTIES FROM OTHERS
    %   =================================================================
    %   FROM NEURON.simulation
    %   -------------------------
    %   n_obj    : (Class NEURON)
    %   cmd_obj  : (Class NEURON.cmd)
    
    
    %OPTIONS =============================================================
    properties
        threshold_cmd_obj   %Class: NEURON.threshold_cmd
        ev_man_obj          %Class: NEURON.simulation.extracellular_stim.event_manager
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
        %.
        v_all    %stim_times x n_electrodes - populated by init__create_stim_info
        t_vec
    end
    
    %INITIALIZATION METHODS ==============================================
    methods
        function obj = extracellular_stim(varargin)
            %
            %
            %   obj = extracellular_stim(varargin)
            
            in.run_NEURON = true;
            in.debug      = false;
            in = processVarargin(in,varargin);
            
            obj@NEURON.simulation(in);
            
            obj.threshold_cmd_obj = NEURON.threshold_cmd;
            obj.ev_man_obj        = NEURON.simulation.extracellular_stim.event_manager(obj);
        end
        %NOTE: The event manager object is reponsible is responsible
        %for handling changes in NEURON from changes in Matlab. Given that
        %one may construct the objects before
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
    
    methods
        function cleanup_sim(obj)
            %
            %    ON CLEANUP:
            %    =============================================
            %    1) delete t_vec
            %    2) delete v_ext
            
            % % %            cell_input_dir = fullfile(obj.cell_obj.getModelRootDirectory,'inputs');
            % % %            v_file_name = sprintf('%s%s',obj.sim_hash,'v_ext.bin');
            % % %            t_file_name = sprintf('%s%s',obj.sim_hash,'t_vec.bin');
            % % %
            % % %            voltage_filepath = fullfile(cell_input_dir,v_file_name);
            % % %            time_filepath    = fullfile(cell_input_dir,t_file_name);
            % % %
            % % %            if exist(voltage_filepath,'file')
            % % %               delete(voltage_filepath)
            % % %            end
            % % %
            % % %            if exist(time_filepath,'file')
            % % %               delete(time_filepath)
            % % %            end
            
        end
        function init__verifyAssignedObjects(obj)
            %init__verifyAssignedObjects
            %
            %    Verifies that all objects which are necessary for this
            %    simulation are defined ...
            %
            %    init__verifyAssignedObjects(obj)
            %
            %    KNOWN CALLERS:
            %    =====================================
            
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
        function potentialTesting(varargin)
            %
            %    NEURON.simulation.extracellular_stim.potentialTesting
            %
            %
            %    OLD METHOD: Needs updating
            
            
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
                    [apFired,extras] = sim__single_stim(obj,stim_amp,'save_data',in.save_data);
                    extras.apFired = apFired;
                case 2
                    %fprintf('SIMULATION FINISHED: AP FIRED = %d\n',apFired);
                    extras = [];
                    thresh_value = sim__determine_threshold(obj,in.STARTING_STIM_AMP);
                    fprintf('SIMULATION FINISHED: THRESHOLD = %0g\n',thresh_value);
            end
            
        end
    end
    
    %--------------------------------------------------------------------------
    
end
