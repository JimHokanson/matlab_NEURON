classdef iclamp < NEURON.simulation.intracellular_stim.electrode
    %
    %   Class:
    %       NEURON.simulation.intracellular_stim.electrode.iclamp
    
    %HOC Conversion Code
    %-----------------------------------------------------
    %     areafac = PI*L*diam/100		/* mamps/cm^2 to namps (units of 1e-6 cm^2) */
    %     objref stim
    %     stim = new IClamp(.5)
    %     stim.dur=.12
    %     stim.amp = 1*areafac
    
    %Design Questions:
    %----------------------------------------------------------------------
    %1) Do I want to merge this with the extracellular stim electrodes
    %to have better support for timing?
    %2) How do I determine where the electrode will be placed???
    %
    %   General thought - have xyz, specify xyz,
    %   Alternatively - just supply an access statement
    %3) Current density or absolute value????
    %   - either, have option, but switch behind the scenes
    %
    %Consider shared class with NEURON.simulation.extracellular_stim.electrode.setStimPattern
    %
    %
    %   How to pass stimulus information?????
    
    %   loc - singular
    %   - pairs of 3
    %   amp
    %   del
    %   dur
    
    properties
        stimulus_transition_times  = [0 0.1 0.3 0.7]  %(ms) Time of stimulus transitions.
        
        base_amplitudes = [0 -1 0.5 0]  %(Current, uA)
        %For more information on this variable see
        %"notes_on_stimulus_amplitude" in the private folder of this class 
    end
    
    methods
    end
    
end

