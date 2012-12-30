classdef sim_logger
    %
    %   NEURON.simulation.extracellular_stim.sim_logger
    %
    
    
    %matcher - has this sim been done before
    %data    - responsible for loading and saving data, as well as 
    %          handling interactions ...
    %
    %FOR LATER
    %----------------------------------------------------------------------
    %predictor - given current data, predict next threshold 
    %merger  - this class would allow merging of results from different
    %          computers
    
    properties
       paths_obj
       matcher_obj
    end
    
    properties
       simulation_logging_enabled = false
       current_number_data_points = 0 %We can update this as we add more simulations
       %to the run
       current_simulation_number  = 0 %This is the id of the simulation being run
       current_xstim_obj
    end
    
    methods
        
        %NOTE: Do I want to keep this is in the memory of xstim????
        function obj = sim_logger()
            
           import NEURON.simulation.extracellular_stim.sim_logger.* 
            
           obj.paths_obj   = pathing();
           obj.matcher_obj = matcher(obj.paths_obj.main_table_path);
        end
        function initializeLogging(obj,xstim_obj)
           obj.findMatch(xstim_obj); 
        end
        function findMatch(obj,xstim_obj)
           %NOTE: We could eventually switch this to other simulations
           %as well ...
           
           obj.current_xstim_obj = xstim_obj;
           
           index = obj.matcher_obj.getMatchingSimulation(xstim_obj);
           
           
        end
        function getThresholds(obj,stimulus_locations,threshold_sign)
           
            
            
           applied_stimuli = [];
           
            
        end
    end
    
end

