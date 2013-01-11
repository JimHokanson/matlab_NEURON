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
       simulation_logging_enabled = false
       current_number_data_points = 0 %We can update this as we add more simulations
       %to the run
       current_simulation_number  = 0 %This is the id of the simulation being run
       
       current_xstim_obj %Class: NEURON.simulation.extracellular_stim.sim_logger.data
    end
    
    methods
        
        %NOTE: Do I want to keep this is in the memory of xstim????
        %Currently it is not ...
        function obj = sim_logger()
            
           import NEURON.simulation.extracellular_stim.sim_logger.* 
            
           obj.paths_obj   = pathing();
           obj.matcher_obj = matcher(obj.paths_obj.main_table_path);
        end
        function initializeLogging(obj,xstim_obj)
           %
           %    initializeLogging(obj,xstim_obj)
           %
           %    INPUTS
           %    ===========================================================
           %    xstim_obj : Class: NEURON.simulation.extracellular_stim
           %
           
           obj.findMatch(xstim_obj,true); 
        end
        function [index,is_new] = findMatch(obj,xstim_obj,add_if_not_found)
           %
           %    This is an important method but is generally meant for
           %    testing. In general the method .initializeLogging() should
           %    be used instead.
           %    
           %
           %    [index,is_new] = findMatch(obj,xstim_obj,add_if_not_found)
           %
           %    See Also:
           %        NEURON.simulation.extracellular_stim.sim_logger.initializeLogging

           obj.current_xstim_obj = xstim_obj;
           
           %NEURON.simulation.extracellular_stim.sim_logger.matcher
           [index,is_new] = obj.matcher_obj.getMatchingSimulation(xstim_obj,add_if_not_found);
           
           obj.current_simulation_number = index;
           
           if isempty(index)
               return
           end
           
           obj.simulation_data_obj = ...
               NEURON.simulation.extracellular_stim.sim_logger.data(...
                    xstim_obj,index,obj.paths_obj.getSavedSimulationDataPath(index));
           
        end
        function getThresholds(obj,cell_locations,threshold_sign)
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
           
           applied_stimuli = [];
           
            
        end
    end
    
end

