classdef data_transfer < handle_light
    %
    %
    %   NEURON.simulation.extracellular_stim.data_transfer
    %
    %   This class will be involved with data transfer between Matlab and
    %   NEURON with variabls specifically related to extracellular
    %   stimulation.
    %
    %   TODO:
    %   ===================================================================
    %   1) Move stimulus potential and time writing into this class
    %   2) Finish delete function
    %   3) Rename file io NEURON functions to have consistent header ...
    
    properties
        parent    %
        sim_hash  %String,
        cmd_obj   %Reference to command object ...
    end
    
    properties (Dependent)
       cell_obj
       root_data_directory
    end
    
    methods 
        function value = get.cell_obj(obj)
           value = obj.parent.cell_obj; 
        end
        function value = get.root_data_directory(obj)
           value = fullfile(obj.cell_obj.getModelRootDirectory,'data');  
        end
    end
    
    methods
        function obj = data_transfer(parent_obj,sim_hash)
            obj.parent   = parent_obj;
            obj.sim_hash = sim_hash; 
            obj.cmd_obj  = obj.parent.cmd_obj;
        end
        function membrane_potential = getMembranePotential(obj)
           %
           %
           %    OUTPUTS
           %    ===========================================================
           %    membrane_potential : time x space
           %
           %    NOTE: The space does not need to be contiguous and can
           %    represent many different locations in 3d, some of which may
           %    not be connected.
           %
           membrane_potential = obj.cmd_obj.loadMatrix(obj.getFilePath('xstim__vm.bin'));
        end
    end
    
    methods (Hidden)
        function file_path = getFilePath(obj,file_name)
           file_path = fullfile(obj.root_data_directory,[obj.sim_hash file_name]); 
        end
    end
    
    methods 
        function delete(obj) 
            %    ON CLEANUP:
            %    =============================================
            %    1) delete t_vec
            %    2) delete v_ext
            
            %TODO: Not sure why I commented this out ...
            
            % % %            cell_input_dir = fullfile(obj.cell_obj.getModelRootDirectory,'inputs');
            % % %            v_file_name = sprintf('%s%s',obj.sim_hash,'v_ext.bin');
            % % %            t_file_name = sprintf('%s%s',obj.sim_hash,'t_vec.bin');
            % % %
            % % %            voltage_filepath = fullfile(cell_input_dir,v_file_name);
            % % %            time_filepath    = fullfile(cell_input_dir,t_file_name);
            % % %
            % % %            if exist(voltage_filepath,'file')
            % % %               delete(voltage_filepath)
            % % %            end
            % % %
            % % %            if exist(time_filepath,'file')
            % % %               delete(time_filepath)
            % % %            end 
        end
    end
end

