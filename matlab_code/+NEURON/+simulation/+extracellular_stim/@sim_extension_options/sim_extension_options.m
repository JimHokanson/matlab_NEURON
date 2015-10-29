classdef sim_extension_options < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.simulaton.extracellular_stim.sim_extension_options   
    %
    %   This class holds options related to expanding the time for running 
    %   the simulation based on the membrane potential observed thus far.
    %   With slow conduction velocities the simulation may not have
    %   progressed far enough given the initial stopping time. The decision
    %   to expand the simulation is currently based upon whether or not the
    %   membrane potential is increasing.
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Documentation of props
    %   2) Specification of continuation metric, optional function hook
    %       for analysis of vm, currently we check if any of the points
    %       show a rising membrane potential, however we could add on
    %       a conditional for the magnitude of the difference of the
    %       membrane potential itself
    
    properties
       max_absolute_sim_growth = 10 %(ms)
       
       sim_growth_rate = 0.5        %(ms)
    end
    
    methods
    end
    
end

