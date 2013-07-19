classdef activation_volume_slice < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_slice
    %  
    %   See Also:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    
    properties
       thresholds
       xyz
       labels
       slice_dim
       slice_value
    end
    
    properties
       max_threshold
    end
    
    methods 
        function value = get.max_threshold(obj)
           value = max(obj.thresholds(:));
        end
    end
    
    methods
        function obj = activation_volume_slice(act_obj,max_stim_level,xyz_info,slice_dim,slice_value,varargin)
            
            in.replication_points = [];
            in = sl.in.processVarargin(in,varargin);
            
            obj.slice_dim   = slice_dim;
            obj.slice_value = slice_value;
            
            %NEURON.simulation.extracellular_stim.results.activation_volume.getSliceThresholds
            [slice_thresholds,slice_xyz] = ...
                act_obj.getSliceThresholds(max_stim_level,slice_dim,slice_value,...
                'replication_points',in.replication_points);
            %
            
            if xyz_info.i_dims(1) > xyz_info.i_dims(2)
                obj.thresholds = squeeze(slice_thresholds)';
            else
                obj.thresholds = squeeze(slice_thresholds);
            end
            obj.xyz              = slice_xyz(xyz_info.i_dims);
            
            obj.labels      = xyz_info.i_chars;
            obj.slice_dim   = slice_dim;
            obj.slice_value = slice_value;
        end
        function plot(obj)
           imagesc(obj.xyz{1},obj.xyz{2},obj.thresholds');
           axis equal
        end
    end
    
end

