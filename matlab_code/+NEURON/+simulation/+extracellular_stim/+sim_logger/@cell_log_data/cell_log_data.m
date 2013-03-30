classdef cell_log_data
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
    %
    
    properties
       cell_type
           %1 - MRG
           %2 - axon generic
       property_values_array
    end
    
    methods
        function obj = cell_log_data(cell_obj,property_values_array)
           
           obj.property_values_array = property_values_array;
           
           switch class(cell_obj)
               case 'NEURON.cell.axon.MRG'
                   obj.cell_type = 1;
               case 'NEURON.cell.axon.generic'
                   obj.cell_type = 2;
               case 'NEURON.cell.axon.generic_unmyelinated'
                   obj.cell_type = 3;
               otherwise
                   error('Case for cell type: %s, not yet handled',class(cell_obj))
           end
        end
    end
    
end

