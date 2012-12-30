classdef cell_log_data
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
    %
    
    properties
       cell_type
       property_values_array
    end
    
    methods
        function obj = cell_log_data(cell_obj,property_values_array)
           
           obj.property_values_array = property_values_array;
           
           switch class(cell_obj)
               case 'NEURON.cell.axon.MRG'
                   obj.cell_type = 1;
               otherwise
                   error('Case for cell type: %s, not yet handled',class(cell_obj))
           end
        end
    end
    
end

