classdef extracellular_stim < NEURON.simulation & NEURON.loggable
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
    
    properties (Hidden)
        logger %of the logger type
    end
    %INITIALIZATION METHODS ==============================================
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
            obj.data_transfer_obj      = data_transfer(obj,obj.sim_hash);
            obj.threshold_analysis_obj = threshold_analysis(obj,obj.cmd_obj);
            
            obj.logger = obj.xstim_logger(); %Is this ok?
        end
    end
    
    
    %There are actually two superclasses here:
    %1) is a logging class which has methods save, compare, etc
    %
    %   i.e. xstim_logger < logger
    %        mrg_logger  < logger
    %        anisotropic_tissue_logger < logger
    %
    %   has abstract methods, save, compare, update, etc, logNewInstance
    %   
    %
    %2) a loggable class -> loggable_class? which has an abstract property
    %called logger which should be instantiated in that class with an
    %object of type 1 above
    %
    %       extracellular_stim < loggable_class
    %       mrg < loggable_class
    %
    %   has an abstract property which should point to a specific logger
    %   for that class
    %       i.e. obj.logger = xstim_logger(obj) %pass in reference to parent
    %       for later property access ...
    %
    
    
    %properties (Hidden,Abstract) - in logger super class
    %   logger
    %end
%     %This definition below would go in the subclass
%       It is a definition of the abtract property
%     
%    properties (Hidden)
%         logger 
%           In the constructor populate this property as such
%           for example in xstim
%                   obj.logger = NEURON.xstim.logger
%     end
%
%   NOW What?
%   In the superclass, I define these methods:
% function log__save(obj)
% obj.logger.save(); 
% end
% function log__comapare(obj)
% obj.logger.compare();
% en
 

    methods (Hidden)

        %Alternatively to this approach below
        %
        %   logger_property
        %
function log__save(obj)
obj.logger.save(); 
end
function log__comapare(obj)
obj.logger.compare();
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
            
            %NOTE: This must follow population of this object
            %in the cell class
            obj.data_transfer_obj.initializeDataSavingPaths();
        end
    end
    
    %SIMULATION METHODS ===================================================
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
        function thresholds = sim__getThresholdsMulipleLocations(obj,cell_locations,varargin)
            %sim__getThresholdsMulipleLocations
            %
            %   sim__getThresholdsMulipleLocations(obj,cell_locations,varargin)
            %
            %   This method determines stimulus thresholds for the current
            %   xstim obj where the cell location varies with respect to
            %   the electrodes (as specified by the cell_locations input). 
            %
            %   Importantly, this method uses a prediction class (and
            %   logging class) to determine thresholds as quickly as
            %   possible. The logging class tries to catch repeated calls
            %   and to serve the cached results instead of rerunning the
            %   simulation.
            %
            %   INPUTS
            %   ===========================================================
            %   cell_locations : (cell array => {x y z} or [points by x,y,z]
            %
            %   OPTIONAL INPUTS
            %   ===========================================================
            %   threshold_sign     : (default 1)
            %   reshape_output     : (default true)
            %   initialized_logger : (default []), if passed in this
            %        can save a decent amount of time between sequential
            %        calls as it keeps data in memory instead of loading
            %        from disk
            %
            %   IMPROVEMENTS
            %   ===========================================================
            %   1) Run a validation step that the passed in sim_logger
            %   matches the settings currently applied to this simulation
            %   object.
            %
            %   FULL PATH:
            %    NEURON.simulation.extracellular_stim.sim__getThresholdsMulipleLocations
            
            in.threshold_sign     = 1;
            in.reshape_output     = true;
            in.initialized_logger = [];
            in = processVarargin(in,varargin);
            
            if isempty(in.initialized_logger)
                sim_logger = NEURON.simulation.extracellular_stim.sim_logger;

                %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
                sim_logger.initializeLogging(obj);
            else
                sim_logger = in.initialized_logger; 
            end
            
            %NEURON.simulation.extracellular_stim.sim_logger.getThresholds
            thresholds = sim_logger.getThresholds(cell_locations,in.threshold_sign);
            
            if in.reshape_output && iscell(cell_locations)
               sz = cellfun('length',cell_locations);
               %Silly meshgrid :/
               t = reshape(thresholds,[sz(2) sz(1) sz(3)]);
               thresholds = permute(t,[2 1 3]);
            end
        end
    end
    
    %INITIALIZATION  =====================================================
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
    
    %PLOTTING  ============================================================
    methods
        %NEURON.simulation.extracellular_stim.plot__AppliedStimulus
    end
end
