classdef cell_props < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %   NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props
    %
    %
    
    properties
        %These hold multiple instances of the class properties
        %of the same class as current_data_instance
        cell_type          = [] 
        data_linearization = {}
    end
    
    properties
        current_data_instance %Class: NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    methods
        function obj = cell_props(cell_props_struct)
            if nargin == 0
                %This is essentially an initialization call
                return
            end
            obj.cell_type = cell_props_struct.cell_type;
            obj.data_linearization = cell_props_struct.data_linearization;
        end
        function I = getMatchingEntries(obj,xstim_obj,indices_to_test)
            
            current_data_local = xstim_obj.cell_obj.getXstimLogData();
            %current_data_local
            %Class: NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
            %   current_data_local.cell_type
            %   current_data_local.property_values_array
            
            
            if ~strcmp(class(current_data_local),'NEURON.simulation.extracellular_stim.sim_logger.cell_log_data') %#ok<STISA>
                error(['Returned object from getXstimLogData must be of the class:\n' ...
                    'NEURON.simulation.extracellular_stim.sim_logger.cell_log_data'])
            end
            
            obj.current_data_instance = current_data_local;
                        
            I1 = indices_to_test(current_data_local.cell_type == obj.cell_type(indices_to_test));
            
            if isempty(I1)
                I = [];
                return 
            end
            
            I = I1(cellfun(@(x) isequal(current_data_local.property_values_array,x),...
               obj.data_linearization(I1)));
                       
        end
        function addCurrentInstance(obj)
            temp_cell_type = obj.current_data_instance.cell_type;
            temp_pv_array  = obj.current_data_instance.property_values_array;
            
            obj.cell_type = [obj.cell_type temp_cell_type];
            obj.data_linearization = [obj.data_linearization temp_pv_array];
        end
        function deleteIndices(obj,indices)
           obj.cell_type(indices) = [];
           obj.data_linearization(indices) = [];
        end
        function data = getSavingStruct(obj)
            data = struct(...
                'data_linearization',{obj.data_linearization},...
                'version',obj.VERSION,...
                'cell_type',obj.cell_type);
        end
    end
    
end

