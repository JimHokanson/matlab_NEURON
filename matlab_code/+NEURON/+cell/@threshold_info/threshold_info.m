classdef threshold_info
    %
    %   Class: NEURON.cell.threshold_info
    %
    %   This class is meant to hold information that is useful in determining
    %   extracellular stimulation threshold for a particular cell.
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis
    %
    
    properties
        v_rest      %resting membrane potential
        v_rough_threshold %Membrane potential above which an action potential will be initiated.
        %NOTE: This value is approximate as it depends on the
        %membrane dynamics of the cell.
        v_ap_threshold %Membrane potential to test for when determining if 
        %an action potential is present
        v_ap_propogation_index = 1 %Index into membrane 
    end
    
    methods
       %TODO: Create validation object which ensures object is properly
       %created ...
       %Perhaps resort to calling a constructor object instead????
    end
    
    
    
end

