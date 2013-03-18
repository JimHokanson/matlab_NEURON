classdef threshold_info
    %
    %   Class: 
    %       NEURON.cell.threshold_info
    %
    %   This class is meant to hold information that is useful in
    %   determining extracellular stimulation threshold for a particular
    %   cell. It should
    %
    %   This class is currently used by:
    %   NEURON.simulation.extracellular_stim.threshold_analysis
    %
    %   It should be accessible for any cell which supports extracellular
    %   stimulation. In:
    %       NEURON.cell.extracellular_stim_capable
    %   the method:
    %       threshold_info_obj = getThresholdInfo(obj)
    %   This is requested from the cell object just before running any
    %   simulations.
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis
    %
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Provide methods for determining what these parameters should be
    %   given an xstim obj with representative cell.
    
    properties
        ap_determination_method = 'threshold crossing'  %Other methods are
        %not currently implemented.
        
        v_ap_threshold = 0 %Membrane potential to test for when 
        %determining if an action potential is present
        v_ap_propagation_index = 1 %For a simulation, the membrane potential
        %at various points in space is returned
        
        %Index into membrane potentials t
    end
    
    methods
       %TODO: Create validation object which ensures object is properly
       %created ...
       %Perhaps resort to calling a constructor object instead????
    end
    
    
    
end

