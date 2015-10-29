classdef current_distance < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.results.current_distance
    %
    %
    %   See Also:
    %      NEURON.simulation.extracellular_stim.sim__getCurrentDistanceCurve 
    %

    properties
       base_xyz
       dim_varied        
       tested_distances  %(units um)
    end
    
    properties
       thresholds %(units uA)
    end
    
    methods
        function obj = current_distance(base_xyz,dim_varied,tested_distances)
           %current_distance
           %    
           %    obj = current_distance(base_xyz,dim_varied,tested_distances)
           
           
           obj.base_xyz   = base_xyz;
           obj.dim_varied = dim_varied;
           obj.tested_distances = tested_distances;
        end
        function plot(obj)
            
           FONT_SIZE = 18;
           
           plot(obj.tested_distances,obj.thresholds)
           set(gca,'FontSize',FONT_SIZE);
           
           switch obj.dim_varied
               case 1
                   str2 = sprintf('y = %0.0f, z = %0.0f, varying x',obj.base_xyz(2),obj.base_xyz(3));
               case 2
                   str2 = sprintf('x = %0.0f, z = %0.0f, varying y',obj.base_xyz(1),obj.base_xyz(3));
               case 3
                   str2 = sprintf('x = %0.0f, y = %0.0f, varying z',obj.base_xyz(1),obj.base_xyz(2));
           end
           
           xlabel(['Electrode Distance (um), ' str2])
           ylabel('Stimulus Amplitude (uA)')
           
        end
    end
    
end

