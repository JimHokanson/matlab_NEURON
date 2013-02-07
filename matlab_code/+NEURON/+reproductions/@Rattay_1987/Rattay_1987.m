classdef Rattay_1987 < handle_light
    
    %
    % F. Rattay, "Ways to approximate current-distance relations for
    % electrically stimulated fibers.," Journal of Theoretical Biology,
    % vol. 125, no. 3, pp. 339-49, 1987.
    %
       
    properties
        % tissue/cell/simulation properties
        tissue_resistivity = 300
        props_paper = 'Rattay_1987'
        temp_celsius = 27
        
        % Results
        fig5_myelinated_result % NEURON.reproductions.Rattay_1987.reproduceRattay()
        myelinated_stim_ratios % NEURON.reproductions.Rattay_1987.stimRatios()
        
        fig5_result % NEURON.reproductions.Rattay_1987.figure5()
        unmyelinated_stim_ratios % NEURON.reproductions.Rattay_1987.unmyelinatedStimRatios()
        fig6_thresholds % NEURON.reproductions.Rattay_1987.figure6()
    end
    
    methods
        % known methods:
        % reproduceRattay
        % stimRatios
        % figure5
        % unmyelinatedStimRatios
        % figure 6
    end
    
end