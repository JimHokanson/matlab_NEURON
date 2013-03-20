classdef current_distance < handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.results.current_distance
    
    properties
       base_xyz
       tested_distances
       thresholds
    end
    
    methods
        function plot(obj)
           plot(obj.tested_distances,obj.thresholds) 
        end
    end
    
end

