classdef NEURON < handle_light
    %NEURON
    %
    %   REQUIRES
    %   ===================================================================
    %   1) Path initialization    - call NEURON.init_system (only needed once)
    %   2) RNEL library functions - I am working on moving these to a
    %   separate package which are optionally installed on startup if not
    %   detected in the path already, see initialize.m function in root
    %   code directory
    %
    %   NOTE: In my startup function I call NEURON.init_system
    %
    %   USAGE NOTES
    %   ===================================================================
    %   This class is meant to be run by a NEURON simulation class, however
    %   it can be called instantiated directly, as in the example below.
    %
    %   N = NEURON;
    %   N.opt__interactive_mode = true;
    %   N.write('a = 5')
    %   N.write('a')
    %
    %   KNOWN SIMULATION CLASSES
    %   ===================================================================
    %   NEURON.simualtion.extracellular_stim
    %
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   - NEURON.compile
    %   - NEURON.init_dotnet_code
    %   - NEURON.setResultAndTerminateWait
    %   - NEURON.waitForFinish
    
    
    %OBJECT REFERENCES    =================================================
    properties
        cmd_obj     %Class: NEURON.cmd
        
        path_obj    %Class: NEURON.paths
        
        command_log_obj     %Class: NEURON.command_log
        
        inspector_obj       %Class: NEURON.inspector
        %This class requires initialization during startup. If it is not
        %enabled at startup, it is not available. 
    end
     
    %OPTIONS   %===========================================================
    properties
        opt__throw_error         = true;
        opt__interactive_mode    = false; 
        opt__log_commands        = false; %If true commands will be logged
        %to the log_obj.
    end

    %"PUBLIC METHODS"   %==================================================
    methods
        function obj = NEURON(neuron_options)
            %NEURON
            %
            %   obj = NEURON(neuron_options)
            %
            %   NEURON related events:
            %   This constructor changes the current directory to the HOC
            %   code root and loads the general NEURON libraries
            %   "noload.hoc"
            %
            
            if ~exist('neuron_options','var')
                neuron_options = NEURON.options;
            end
            
            %Object Initialization
            %--------------------------------------------------------------
            obj.command_log_obj = NEURON.command_log;
            obj.path_obj = NEURON.paths.getInstance;
            obj.cmd_obj  = NEURON.cmd(obj.path_obj,obj.command_log_obj,neuron_options.cmd_options);
            
            %Change directory and load library files
            %--------------------------------------------------------------
            c = obj.cmd_obj;
            c.cd_set(obj.path_obj.hoc_code_root);            
            c.run_command('{xopen("$(NEURONHOME)/lib/hoc/noload.hoc")}');
            
            if neuron_options.run_inspector
               obj.inspector_obj = NEURON.inspector(c); 
            end

            
        end
    end
    
    %STATIC METHODS   %====================================================
    methods (Static)
        function init_system
            %init_system
            %
            %   Should be called on startup to initialize system, at least for
            %   Windows ...
            %
            %   FULL PATH:
            %   NEURON.init_system
            
            NEURON.comm_obj.java_comm_obj.init_system_setup;
            
            if ispc
                user32.init();
                NET.addAssembly('System');
                NEURON.comm_obj.windows_comm_obj.init_system_setup;
            end
        end
        function file_path = createNeuronPath(file_path)
            %NEURON_createNeuronPath
            %
            %   file_path = NEURON_createNeuronPath(file_path)
            %
            %   NOTE: This function should provide a path that is safe for
            %   passing into Neuron. This basically involves creating a
            %   cygwin path for windows.
            
            if ispc
                file_path = getCygwinPath(file_path);
            end
        end
    end
    %STATOC METHODS - in other files   %===================================
    methods (Static)
        compile(mod_path)  %Method will compile mod files into dll
        populate_helper_function_package
    end
end
