classdef activation_volume_slice < NEURON.sl.obj.handle_light
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
            in = NEURON.sl.in.processVarargin(in,varargin);
            
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
        function plot(obj,varargin)
            
           in.lim_dim1 = [];
           in = NEURON.sl.in.processVarargin(in,varargin);
            
           
           dim1 = obj.xyz{1};
           if ~isempty(in.lim_dim1)
              
              I1 = find(dim1 >= in.lim_dim1(1),1);
              I2 = find(dim1 <= in.lim_dim1(2),1,'last');
              dim1 = dim1(I1:I2);
           else
              I1 = 1;
              I2 = length(dim1);
           end
           
           
           imagesc(dim1,obj.xyz{2},obj.thresholds(I1:I2,:)');

           
           axis equal
        end
        function [c,h] = contour(obj,stim_amps)
           
           if length(stim_amps) == 1 
              [c,h] = contour(obj.xyz{1},obj.xyz{2},obj.thresholds',[stim_amps stim_amps]); 
           else
              [c,h] = contour(obj.xyz{1},obj.xyz{2},obj.thresholds',stim_amps);  
           end
           axis equal
        end
    end
    
end

