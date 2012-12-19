classdef threshold_analysis < handle_light
    %
    %
    %
    %   CLASS GOALS
    %   =========================================================
    %   1) Complex action potential analysis:
    %       - Allow simple threshold analysis
    %       - Detect activation but no propogation
    %   2) Code to determine threshold
    %       - use membrane analysis to guess next threshold
    %       - 
    %
    %   NOTE: I would also like to handle the "frying the NEURON case"
    %   - NEURON throws an error: exp(#) out of range, returning exp(700)
    %
    %   Class: NEURON.simulation.extracellular_stim.threshold_analysis
    
    
    %FROM PRIOR
    %======================================================================
    %   New place for code related to threshold handling
    %
    %   METHODS TO IMPLEMENT
    %   ==========================================================
    %   1) determine single side threshold
    %   2) determine single sided activation & inactivation
    %
    %   CORE COMPONENTS
    %   =================================================================
    %   1) Code that takes some form of membrane threshold and determines
    %   whether or not an AP fired, along with instructions on how to
    %   change the stimulus level to get an action potential, OR NOT,
    %   depending upon the goal of the input
    %   2) General stimulus stuffs
    %   
    %   Additional things to handle
    %   ---------------------------------------------------------------
    %   1) threshold voltage, this varies as a function of the cell
    %
    %   NOTE: This should work in coordination with NEURON.threshold_cmd
    
    properties
    end
    
    methods
    end
    
end

