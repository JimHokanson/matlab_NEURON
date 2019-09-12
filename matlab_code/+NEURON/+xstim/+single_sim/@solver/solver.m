classdef solver < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    %See for reference
    %   NEURON.xstim.single_AP_sim.solver
    
    properties
        old_data
        new_data
    end
    
    methods
        function obj = solver(old_data,new_data)
            obj.old_data = old_data;
            obj.new_data = new_data;
            
            new__is_unique = is_unique_sorted;
                new__source_I = source_I_sorted;
                is_old_source = false(1,n_new);
        end
        function getSolutions()
            
        end
    end
end

