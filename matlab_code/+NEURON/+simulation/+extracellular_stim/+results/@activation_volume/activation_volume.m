classdef activation_volume < handle
    %
    %   Class: NEURON.results.xstim.activation_volume
    
    %OPTIONS  =============================================================
    properties
        start_width   = 400
        spacing_model = 1 %Currently only one value is valid
        %Use this to ensure a proper range of values
        %1 - indicates axon type model
    end
    
    properties
       bounds = [] %Not yet implemented, meant to handle extremes of testing
       %in x,y,z spacing ...
    end
    
    methods
        function obj = activation_volume(xstim_obj)
 
            keyboard
            
            elec_objs = xstim_obj.elec_objs;
            
            all_elec_locations = vertcat(elec_objs.xyz);
            
%             
%            obj.x_bounds       = x_bounds;
%            obj.y_bounds       = y_bounds;
%            obj.z_bounds       = z_bounds;
%            obj.xstim_obj      = xstim_obj;
%            obj.file_save_path = file_save_path;
%            
%            xstim_obj.ev_man_obj.initSystem();
%            
%            determineStepSize(obj)
%            init_thresh_matrix(obj)
%            solveVolume(obj)
        end      
    end

    
    
end

