classdef axon_applied_potential < handle
    %
    %   See Also:
    %       extracellular_stim
    
    properties
       applied_potential
       t_vec
       stim_all
       xyz_axon
       xyz_electrodes
       z_lim = [-1000 1000];
    end
    
    methods
        
        function obj = axon_applied_potential(applied_potential,t_vec,xyz_axon,xyz_electrodes,stim_all)
            
           obj.applied_potential = applied_potential;
           obj.t_vec = t_vec;
           obj.xyz_axon = xyz_axon;
           obj.xyz_electrodes = xyz_electrodes;
           obj.stim_all = stim_all;
            
        end
        

    end
    
end

