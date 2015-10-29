classdef volume_counts < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.results.activation_volume.volume_counts
    %
    %
    %   This is a result of running the method:
    %   NEURON.simulation.extracellular_stim.results.activation_volume.getVolumeCounts
    %
    %   NOT YET USED
    
    properties
       counts
       stim_amplitudes
       xyz
       counts_per_bin
       z_saturation_threshold
    
       %TODO: Add the replication info 
       %perhaps just a class reference ...
    
    end
    
    methods
        function obj = volume_counts()
            
        end
    end
    
end

