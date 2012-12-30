classdef pathing
    %
    %   
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
           
           user_options = NEURON.user_options;
                      
           obj.root_data_path = user_options.sim_logger_root_path;
           obj.main_table_path = fullfile(obj.root_data_path,'sim_table.mat');
           
        end
    end
    
end

