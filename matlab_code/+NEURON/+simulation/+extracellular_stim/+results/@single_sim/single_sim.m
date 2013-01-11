classdef single_sim < handle_light
    %
    %   NOTE: Ideally we would only have this be a value class
    %
    %   Class: NEURON.simulation.extracellular_stim.results.single_sim;
    
    %TODO:
    %Add on the properties that led to these results
    %=> like the threshold crossing criteria
    
    properties
       vm_threshold             %Threshold that needed to be crossed to consider
                                %AP at local point
       ap_propogation_index     %index that needed to cross threshold
       %for considering propogation to have occurred
    end
    
    properties
       %see NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
       success                  %Result ran without error
       %NOTE: Currently if this is false it indicates that the tissue is
       %fried, as otherwise an error will be thrown ...
       
       tissue_fried             %Numerical overflow due to too strong a stimulus
       membrane_potential       %potential at nodes, time x space
       threshold_crossed        = false %Whether threshold was crossed at any point
       max_membrane_potential   = NaN %max(membrane_potential(:))
       ap_propogated            = false %Whether or not a particular node crossed threshold
       max_vm_per_node          %For each node this is the maximum potential recorded
    end
    
    methods
        function setFriedTissueValues(obj)
            
           %Not sure if I should put anything else in here ... 
           obj.max_membrane_potential = Inf;
        end
    end
    
end

