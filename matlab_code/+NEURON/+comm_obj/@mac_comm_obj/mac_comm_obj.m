classdef mac_comm_obj < NEURON.comm_obj
    %
    
    properties
        paths       %Class: NEURON.paths
    end
    
    methods
        function obj = mac_comm_obj(paths_obj)
           obj.paths = paths_obj;
           %TODO: Launch process, setup callbacks if necessary ...
            
        end
        function [success,results] = write(obj,command_str,option_structure)
                
        end
    end
    
    methods (Static)
        function init_system_setup
           %Insert code here that should run once on system start
           %to ensure that the code will work ...
           
        end
    end
    
end

