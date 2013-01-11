classdef Hokanson_2013
    %
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    
    properties
    end
    
    methods (Static)
        function create_log_data()
            
           options = {...
               'electrode_locations',[-200 0 0; 200 0 0]};
            
           xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
           
           xstim_obj.sim__create_logging_data;
           
           
        end
    end
    
end

