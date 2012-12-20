classdef single_sim < handle_light
    %
    %   NOTE: Ideally we would only have this be a value class
    %
    %   Class: NEURON.simulation.extracellular_stim.results.single_sim;
    
    %TODO:
    %Add on properties that determined results
    
    properties
       %see NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
       success                  %Result ran without error
       %NOTE: Currently if this is false it indicates that the tissue is
       %fried, as otherwise an error will be thrown ...
       
       tissue_fried             %Numerical overflow due to too strong a stimulus
       membrane_potential       %potential at nodes, time x space
       threshold_crossed        %Whether threshold was crossed at any point
       max_membrane_potential   %max(membrane_potential(:))
       ap_propogated            %Whether or not a particular node crossed threshold
       max_vm_per_node          %For each node this is the maximum potential recorded
    end
    
    methods
    end
    
end

