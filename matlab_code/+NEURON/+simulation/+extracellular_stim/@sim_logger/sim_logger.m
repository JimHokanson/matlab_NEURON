classdef sim_logger < handle_light
    %
    %   NEURON.simulation.extracellular_stim.sim_logger
    %
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Create backup system  - take structure and send to zip
    %   2) Create merging system - allow combining of data from multiple computers 
    
    %   LONG TERM
    %   ===================================================================
    %   We could eventually log other types of simualations as well. This
    %   class would need to move up the package hierarchery ...

    
    properties
       paths_obj    %Class: NEURON.simulation.extracellular_stim.sim_logger.pathing
       matcher_obj  %Class: NEURON.simulation.extracellular_stim.sim_logger.matcher
       %The main function of this object is to serve as a place to query
       %matches for simulations that match the current simulation setup. I
       %don't like the current implementation because it doesn't rely on
       %the classes themselves for version comparison, instead the
       %comparison is done here. Ideally I will eventually move the
       %comparison classes to be in the subpackages of the objects they
       %represent.
       
       simulation_data_obj  %Class: 
    end
    
    properties
       current_simulation_number  = 0 %This is the id of the simulation being run   
       %A value of 0 indicates that no extracellular_stim object has been
       %attached to this class.
       
       %.initializeLogging()
       current_xstim_obj %Class: NEURON.simulation.extracellular_stim.sim_logger.data
    end
    
    methods
        function obj = sim_logger()
            
           import NEURON.simulation.extracellular_stim.sim_logger.* 
            
           obj.paths_obj   = pathing();
           obj.matcher_obj = matcher(obj.paths_obj.main_table_path);
        end
        function initializeLogging(obj,xstim_obj)
           %initializeLogging
           %
           %    This method can be used to 
           %
           %    initializeLogging(obj,xstim_obj)
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
           %    This is an important method but is generally meant for
           %    testing. In general the method .initializeLogging() should
           %    be used instead. This method relies on the matcher class
           %    to compare the xstim_obj to previous versions.
           %    
           %    [simulation_index,is_new] = findMatch(obj,xstim_obj,add_if_not_found)
           %
           %    INPUTS
           %    ===========================================================
           %    xstim_obj : Class NEURON.simulation.extracellular_stim
           %    add_if_not_found : if true, a entry will be added 
           %
           %    See Also:
           %        NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
           %        NEURON.simulation.extracellular_stim.sim_logger.matcher
           %
           %    IMPROVEMENTS
           %    ===========================================================
           %    1) Allow an index which can be checked first for a map to
           %    reduce matching comparisons. On failure an exhaustive
           %    search will be performed.
           %    
           %    
           
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
                    xstim_obj,obj.paths_obj.getSavedSimulationDataPath(simulation_index));
           
        end
    end
    
    methods
        function thresholds = getThresholds(obj,cell_locations,threshold_sign)
           %
           %    INPUTS
           %    ===========================================================
           %    cell_locations : see .data.getThresholds
           %    threshold_sign
           %
           %
           %    See Also:
           %        NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
            
            
           if obj.current_simulation_number == 0
               error('Simulation must currently be first initiated via initializeLogging')
           end
            
           thresholds = obj.simulation_data_obj.getThresholds(cell_locations,threshold_sign);
            
        end
    end
    
end

