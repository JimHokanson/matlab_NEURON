classdef applied_stimuli < sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %
    
    properties
       sim %Reference to simulation object to compute applied stimulus ...  
    end
    
    %TODO: Make both of these use lazy loading ...
    properties
       cell_locations 
       stimulus
       low_d_stimulus
    end
    
    methods
    end
    
end

