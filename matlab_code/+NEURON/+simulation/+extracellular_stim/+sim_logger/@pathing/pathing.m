classdef pathing
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.pathing
    %
    %   File pathing
    %   --------------------------------------------------
    %   Version 1:
    %       single table file
    %       individual files for each simulation ...
    
    properties
       %TODO: Define each of these
       root_data_path
       main_table_path
    end
    
    methods
        function obj = pathing()
           
           user_options = NEURON.user_options.getInstance;
                      
           obj.root_data_path = user_options.sim_logger_root_path;
           
           if ~exist(obj.root_data_path,'dir')
              success = mkdir(obj.root_data_path);
              if ~success
                 %NOTE: I need to work on this a bit as the user_options 
                 %setup is not obvious and not manually entered between
                 %users
                 error('Unable to create root data path for logging simulations') 
              end
           end
           if ~exist(obj.root_data_path,'dir')
              success = mkdir(obj.root_data_path);
              if ~success
                 %NOTE: I need to work on this a bit as the user_options 
                 %setup is not obvious and not manually entered between
                 %users
                 error('Unable to create root data path for logging simulations') 
              end
           end

           obj.main_table_path = fullfile(obj.root_data_path,'sim_table.mat');
        end
        function data_path = getSavedSimulationDataPath(obj,simulation_number)
           data_path = fullfile(obj.root_data_path,sprintf('Sim_%03d.mat',simulation_number));
        end
    end
    
end

