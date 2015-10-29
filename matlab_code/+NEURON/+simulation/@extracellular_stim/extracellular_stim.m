classdef extracellular_stim < NEURON.simulation
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim
    %
    %   This class is meant to implement extracellular stimulation of a
    %   cell.
    %
    %   HOW TO CALL
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.create_standard_sim
    %
    %   Simulation Methods
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.sim__single_stim
    %   NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve
    %   NEURON.simulation.extracellular_stim.sim__determine_threshold
    %   NEURON.simulation.extracellular_stim.sim__getActivationVolume
    %
    %   DOCUMENTATION
    %   ===================================================================
    %   Additional documentation can be found in the documentation folder
    %   of this class.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Write display method
    %   2) Refactor stimulus data to allow better superposition and
    %   computing of stimuli in NEURON
    
    %OPTIONS =============================================================
    properties
        threshold_options_obj   %Class: NEURON.simulation.extracellular_stim.threshold_options
        sim_ext_options_obj     %Class: NEURON.simulaton.extracellular_stim.sim_extension_options
    end
    
    properties (Hidden)
        data_transfer_obj       %Class: NEURON.simulation.extracellular_stim.data_transfer
        %This object is meant to facilitate data transfer to and from the
        %NEURON environment.
        
        threshold_analysis_obj  %Class: NEURON.simulation.extracellular_stim.threshold_analysis
        %This object performs the actual stimulation and analyzes the
        %result.
    end
    
    properties (SetAccess = private)
        %Populate by using the set methods
        tissue_obj   %(Subclass of NEURON.tissue)
        %                   NEURON.tissue.homogeneous_anisotropic
        %                   NEURON.tissue.homogeneous_isotropic
        elec_objs    %(Class NEURON.simulation.extracellular_stim.electrode)
        cell_obj     %(Class neural_cell), singular
    end
    
    properties (Hidden)
        %.init__create_stim_info()
        %.computeStimulus()
        %-------------------------------------------------------
        v_all    %stim_times x stim sites on cell
        t_vec    %1 x stim times
        %NOTE: Stim times is any time in which any stimulus changes (i.e.
        %from any electrode), as this will change the electric field that
        %the cell is in. It will also include a time at zero (NOTE: This
        %might change) to indicate that at time zero there is generally no
        %stimulus.
    end
    
    %Latest configurations ================================================
    properties (Hidden)
        %These properties can be used by methods of this class to hold onto
        %the most recent configuration
        tissue_configuration    = []
        electrode_configuration = []
        cell_configuration      = []
    end
    
    %INITIALIZATION METHODS %=============================================
    methods (Access = private)
        function obj = extracellular_stim(xstim_options)
            %
            %   obj = extracellular_stim(varargin)
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim.create_standard_sim
            
            if ~exist('xstim_options','var')
                xstim_options = NEURON.simulation.extracellular_stim.options;
            end
            
            import NEURON.simulation.extracellular_stim.*
            
            obj@NEURON.simulation(xstim_options.sim_options);
            
            obj.threshold_options_obj  = threshold_options;
            obj.sim_ext_options_obj    = sim_extension_options;
            obj.data_transfer_obj      = data_transfer(obj.sim_hash,...
                obj.binary_data_transfer_path,obj.cmd_obj);
            obj.threshold_analysis_obj = threshold_analysis(obj,obj.cmd_obj);
            
        end
    end
    methods
        function init__simulation(obj)
            %init__simulation Initializes simulation before being run
            %
            %    init__simulation(obj)
            %
            %    Simulation methods of this class, indicated by sim__ should
            %    call this method before running their code.
            %
            %    For more information on event order see the Event Order
            %    documentation file in the private folder of this class.
            %
            %    FULL PATH:
            %        NEURON.simulation.extracellular_stim.init__simulation
            
            %Retrieval of the threshold info object from the cell for use in
            %analyzing action potentials.
            %NEURON.simulation.extracellular_stim.init__setupThresholdInfo
            obj.init__setupThresholdInfo();
            
            %Base definition:
            %NEURON.cell.extracellular_stim_capable.createExtracellularStimCell
            obj.cell_obj.createExtracellularStimCell(obj.cmd_obj,...
                obj.options.display_NEURON_steps);
            
            obj.init__create_stim_info();
            
        end
    end
    
    methods (Static)
        obj = create_standard_sim(varargin)
    end
    
    %EVENT HANDLING  %=====================================================
    methods
        %IMPROVEMENTS:
        %==============================================
        %1) Check input type (low priority)
        %2) Provide support for changing the object. Currently these
        %methods are only called once and it is not clear that they would
        %work properly if a new object were assigned to these properties.
        %Most likely the configuration settings would need to be reset but
        %other code might need to be executed in NEURON as well.
        
        function set_Tissue(obj,tissue_obj)
            obj.tissue_obj = tissue_obj;
        end
        function set_Electrodes(obj,elec_objs)
            obj.elec_objs = elec_objs;
        end
        function set_CellModel(obj,cell_obj)
            obj.cell_obj = cell_obj;
        end
    end
    
    %SIMULATION METHODS %==================================================
    methods
        function sim_logger = sim__getLogInfo(obj)
            %sim__getLogInfo
            %
            %   sim_logger = sim__getLogInfo(obj)
            %
            %   This method gets the sim_logger class after initialization
            %   so that the data object it contains is valid given the
            %   current extracellular stimulation being used.
            %
            %   OUTPUTS
            %   ===========================================================
            %   sim_logger : Class: NEURON.simulation.extracellular_stim.sim_logger
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim.sim_logger
            
            sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
            
            %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
            sim_logger.initializeLogging(obj);
        end
        function r = sim__getSingleAPSolver(obj,varargin)
            %
            %
            %   r = sim__getSingleAPSolver(obj,varargin)
            %
            %   OUTPUTS
            %   ===========================================================
            %   r : NEURON.xstim.single_AP_sim.request_handler
            %
            %   IMPROVEMENTS
            %   ===========================================================
            %   1) I'd like to get rid of the inputs and either pass in
            %   an options class or introduce a second step of initializing
            %   the request handler.
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.request_handler
            %
            %   FULL PATH:
            %   NEURON.simulation.extracellular_stim.sim__getSingleAPSolver
            
            
            in.threshold_sign     = 1;
            %             in.reshape_output     = true;
            in.solver             = 'default'; %from_old_solver
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            r = NEURON.xstim.single_AP_sim.request_handler(obj,in.threshold_sign,'solver',in.solver);
        end

    end
    
    %INITIALIZATION  %====================================================
    methods (Access = private)
        function init__setupThresholdInfo(obj)
            %init__setupThresholdInfo
            %
            %   init__setupThresholdInfo(obj)
            %
            %    See Also:
            %        NEURON.simulation.extracellular_stim.sim__single_stim
            %        NEURON.simulation.extracellular_stim.sim__determine_threshold
            %
            %   FULL PATH:
            %   NEURON.simulation.extracellular_stim.init__setupThresholdInfo
            
            
            %This method is required by:
            %NEURON.cell.extracellular_stim_capable
            obj.threshold_analysis_obj.setThresholdInfo(obj.cell_obj.getThresholdInfo());
        end
    end
    
    %Info Retrieval   %====================================================
    methods
        function nobj = getNEURONobjects(obj)
            nobj = NEURON.simulation.extracellular_stim.NEURON_objects(obj.cmd_obj);
        end
    end
    
    %PLOTTING  %===========================================================
    methods
        %NEURON.simulation.extracellular_stim.plot__AppliedStimulus
    end
    
    %LOGGING  %============================================================
    methods
        function logger = getLogger(obj)
            %Note: There isn't exactly a reason for the xstim logger to be
            %a singleton.. only mims. which is why this call is different
            %from the rest
            logger = NEURON.simulation.extracellular_stim.logger.getInstance(obj);
        end
    end
end
