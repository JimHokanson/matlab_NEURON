classdef user_options
    %
    %   This class is meant to handle parsing of user defined variables.
    %
    %   Class:
    %   NEURON.user_options
    %
    %   TODO: Create singleton pattern
    
    properties
       sim_logger_root_path
    end
    
    methods
        function obj = user_options()
           options_dir  = fileparts(fileparts(fileparts(getMyPath)));
           options_file = fullfile(options_dir,'LocalOptions.txt');
           
           raw_data = getPropFileAsStruct(options_file,':');
           
           %TODO: Copy over property copier function
           obj.sim_logger_root_path = raw_data.sim_logger_root_path;
           
        end
    end
    
end

