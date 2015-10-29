classdef sim_logger < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.sim_logger
    %
    %   This class was written primarily to facilitate the logging of
    %   stimulus threshold data for different simulations.
    %
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Create backup system  - take structure and send to zip
    %   2) Create merging system - allow combining of data from multiple computers 
    %   3) Data subclass is not logging all components
    %   4) Matcher subclass is not logging all components
    %   5) Move comparisons for matcher to class.
    %
    %   LONG TERM
    %   ===================================================================
    %   We could eventually log other types of simualations as well. This
    %   class would need to move up the package hierarchery ...
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
    %       NEURON.simulation.extracellular_stim.sim_logger.data
    %       NEURON.simulation.extracellular_stim.sim_logger.matcher
    %       NEURON.simulation.extracellular_stim.sim_logger.pathing
    %       NEURON.simulation.extracellular_stim.sim_logger.stimulus_setup

    
    properties
       %.sim_logger()
       paths_obj    %Class: NEURON.simulation.extracellular_stim.sim_logger.pathing
       matcher_obj  %Class: NEURON.simulation.extracellular_stim.sim_logger.matcher
       %The main function of this object is to serve as a place to query
       %matches for simulations that match the current simulation setup.
       
       %.findMatch
       simulation_data_obj  %Class: NEURON.simulation.extracellular_stim.sim_logger.data
    end
    
    properties
       %.findMatch()
       current_simulation_number  = 0 %This is the id of the simulation
       %being run. A value of 0 indicates that no extracellular_stim object
       %has been attached to this class.
       current_xstim_obj %Class: NEURON.simulation.extracellular_stim.sim_logger.data
    end
    
    methods
        function obj = sim_logger(preferred_base_path)
           %sim_logger
           %
           %    obj = sim_logger(*preferred_base_path)
           %    
           %    OPTIONAL INPUTS
           %    ===========================================================
           %    preferred_base_path : (default ''), If empty the base path
           %        for saving logging data is extracted from the user
           %        options file.
           %
           %    FULL PATH:
           %    NEURON.simulation.extracellular_stim.sim_logger
           
           if ~exist('preferred_base_path','var')
               preferred_base_path = '';
           end

           import NEURON.simulation.extracellular_stim.sim_logger.* 
            
           obj.paths_obj   = pathing(preferred_base_path);
           obj.matcher_obj = matcher(obj.paths_obj);
        end
        function initializeLogging(obj,xstim_obj)
           %initializeLogging
           %
           %    initializeLogging(obj,xstim_obj)
           %
           %    This method can be used to initialize logging given a
           %    particular extracellular stimulation object.
           %
           %    INPUTS
           %    ===========================================================
           %    xstim_obj : Class: NEURON.simulation.extracellular_stim
           
           
           %Here we force creation of a new matcher index
           obj.findMatch(xstim_obj,true); 
        end
    end
    
    methods (Hidden)
        function [simulation_index,is_new] = findMatch(obj,xstim_obj,add_if_not_found)
           %findMatch
           %
           %    [simulation_index,is_new] = findMatch(obj,xstim_obj,add_if_not_found)
           %
           %    This is an important method but is generally meant for
           %    testing. In general the method .initializeLogging() should
           %    be used instead. This method relies on the matcher class
           %    to compare the xstim_obj to previous versions.
           %    
           %    INPUTS
           %    ===========================================================
           %    xstim_obj        : Class NEURON.simulation.extracellular_stim
           %    add_if_not_found : If true, a entry will be added in the
           %            case that the input xstim_obj fails to match any
           %            previous xstim simulations.
           %
           %    See Also:
           %        NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
           %        NEURON.simulation.extracellular_stim.sim_logger.matcher
           
           obj.current_xstim_obj = xstim_obj;
           
           %NEURON.simulation.extracellular_stim.sim_logger.matcher
           [simulation_index,is_new] = obj.matcher_obj.getMatchingSimulation(xstim_obj,add_if_not_found);
           
           obj.current_simulation_number = simulation_index;
           
           if isempty(simulation_index)
               return
           end
           
           %For a valid sim logger entry, we'll create an associated data
           %object (either from scratch or reload from file)
           obj.simulation_data_obj = ...
               NEURON.simulation.extracellular_stim.sim_logger.data(...
                    simulation_index,obj.paths_obj,xstim_obj);
           
        end
    end
    
    methods
        function thresholds = getThresholds(obj,cell_locations,threshold_sign)
           %getThresholds
           %
           %    thresholds = getThresholds(obj,cell_locations,threshold_sign)
           %
           %    This is the publicly exposed method of this set of classes
           %    for 
           %
           %    INPUTS
           %    ===========================================================
           %    cell_locations : see .data.getThresholds
           %    threshold_sign : Either -1 or +1. See threshold sign
           %            in the private documentation folder of ????
           %
           %    See Also:
           %        NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
            
            
           if obj.current_simulation_number == 0
               error('Simulation must currently be first initiated via .initializeLogging()')
           end
            
           thresholds = obj.simulation_data_obj.getThresholds(cell_locations,threshold_sign);
            
        end
    end
    
end

