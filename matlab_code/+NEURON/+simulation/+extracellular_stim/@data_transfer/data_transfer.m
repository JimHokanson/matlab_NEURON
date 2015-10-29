classdef data_transfer < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.data_transfer
    %
    %   This class will be involved with data transfer between Matlab and
    %   NEURON with variabls specifically related to extracellular
    %   stimulation.
    %
    %   IMPROVEMENTS
    %   ====================================================================
    %   1) Allow ignoring of loading the time vector (if it doesn't change)
    %   2) Stimulus should ignore 0 stim at 0 - handle in NEURON
    %       i.e. if we don't stimulate at time zero, NEURON, not Matlab,
    %       should add on that at time 0, there is no stimulus
    %       I would actually be surprised if this isn't in the hoc code ...
    %       - would need to see vector.play code 
    %   3) Finish delete function
    
    properties
       cmd_obj   %Class: NEURON.cmd
    end
    
    properties
        sim_hash  %String,
        binary_data_transfer_path
    end

    %These are dependent in case the cell changes ...
    properties (Dependent)
       cell_obj
       root_read_directory
       root_write_directory
    end
    
    methods 
        function value = get.cell_obj(obj)
           value = obj.parent.cell_obj; 
        end
        function value = get.root_read_directory(obj)
           value = fullfile(obj.cell_obj.getModelRootDirectory,'data');
        end
        function value = get.root_write_directory(obj)
           value = fullfile(obj.cell_obj.getModelRootDirectory,'inputs');
        end
    end
    
    %CONSTRUCTOR  =========================================================
    methods
        function obj = data_transfer(sim_hash,data_path,cmd_obj)
            obj.sim_hash = sim_hash; 
            obj.binary_data_transfer_path = data_path;
            obj.cmd_obj  = cmd_obj;
        end
    end
    
    %DATA EXTRACTION FROM NEURON  =========================================
    methods
        function membrane_potential = getMembranePotential(obj)
           %getMembranePotential
           %
           %    Retrieves the membrane potential at various segments of the
           %    neural cell over time, primarily for use in threshold
           %    analysis.
           %
           %    OUTPUTS
           %    ===========================================================
           %    membrane_potential : time x space (Units mV)
           %
           %    NOTE: The space does not need to be contiguous and can
           %    represent many different locations in 3d, some of which may
           %    not be connected.
           %
           %    NOTE: The contents of the membrane_potential are generally
           %    the membrane voltage at Nodes of Ranvier. It is however 
           %    allowable by the cell class to create other recordings.

           membrane_potential = obj.cmd_obj.loadMatrix(obj.getReadFilePath('xstim__vm.bin'));
        end
    end
    
    %WRITING DATA FUNCTIONS  ==============================================
    methods
        function writeStimInfo(obj,applied_voltage,stimulus_times)
        %writeStimInfo
        %
        %
        %   TODO: Finish Documentation
        
        c = obj.cmd_obj;
        
        %Write to disk
        %------------------------------------------------------------------
        c.writeVector(obj.getWriteFilePath('v_ext.bin'),applied_voltage(:));
        
        %NOTE: Often this doesn't change. Could only write this on change.
        c.writeVector(obj.getWriteFilePath('t_vec.bin'),stimulus_times);
        
        %Load into NEURON
        %------------------------------------------------------------------
        %xstim__load_data           - loads data from file
        %xstim__setup_stim_playback - creates vectors for playing stimulation
        
        %NOTE: By executing these separately I can debug which, if either, is
        %causing a problem ...
        c.run_command('{xstim__load_data()}');
        c.run_command('{xstim__setup_stim_playback()}');
        end
    end
    
    
    %SIMPLE HELPERS =======================================================
    methods (Hidden)
        function file_path = getReadFilePath(obj,file_name)
           file_path = fullfile(obj.binary_data_transfer_path,[obj.sim_hash file_name]); 
        end
        function file_path = getWriteFilePath(obj,file_name)
           file_path = fullfile(obj.binary_data_transfer_path,[obj.sim_hash file_name]); 
        end
    end
    
    methods 
        function delete(obj) 
            %    ON CLEANUP:
            %    =============================================
            %    1) delete t_vec
            %    2) delete v_ext
            
            %TODO: Not sure why I commented this out ...
            
            %This is really low priority
            
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

