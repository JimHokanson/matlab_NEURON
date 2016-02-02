classdef simulation < NEURON.sl.obj.handle_light
    %
    %   CLASS: 
    %       NEURON.simulation
    %
    %   This class (or subclasses) are the main class for running code in NEURON.
    %
    %   SUBCLASS IMPLEMENTATION NOTES
    %   =========================================================
    %   1) Call this constructor
    %
    %   KNOWN IMPLEMENTORS
    %   =========================================================
    %   	NEURON.simulation.extracellular_stim
    %       NEURON.simulation.intracellular_stim
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Allow disabling of time adjustment warning
    %   2) Provide functionality for using conduction result to set time to
    %   wait apropriately.

    properties
        props       %Class: NEURON.simulation.props
        options     %Class: NEURON.simulation.options
    end
    
    properties
        %NOTE: These classes may not exist if NEURON is not loaded on startup.
        cmd_obj  %Class: NEURON.cmd 
        path_obj %Class: NEURON.paths
        
    end
    
    %TODO: It would be nice to expose these objects through a GUI
    %as they are primarily debug objects ...
    properties (Hidden)
        command_log_obj     %Class: NEURON.command_log
        inspector_obj       %Class: NEURON.inspector
        %This class requires initialization during startup. If it is not
        %enabled at startup, it is not available. 
    end
    
    properties (Hidden)
        %.simulation()
        sim_hash    %String for preventing file save collisions 
        %between concurrent versions of Matlab. This is based upon the 
        %process id of Matlab, not the communications process.
        %
        %IMPORTANT: This variable is declared in NEURON in init_neuron.hoc
        binary_data_transfer_path
    end
    
    %INITIALIZATION    %===================================================
    methods
        function obj = simulation(sim_options)
            %NEURON.simulation Initializes the NEURON simulation
            %
            %   obj = NEURON.simulation(*sim_options)
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim
            %       NEURON.simulation.initNEURON
            
            if ~exist('sim_options','var')
               sim_options = NEURON.simulation.options; 
            end
            
            obj.sim_hash = ['p' num2str(feature('GetPid'),'%d') '_'];
            
            obj.options  = sim_options;
            
            
            %Binary Data Transfer Path Handling
            %--------------------------------------------------------------
            user_options = NEURON.user_options.getInstance;
            base_path    = user_options.temp_data_base_path;
            
            %NOTE: This is the fully resolved name of simulation,
            %NEURON.simulation, or a subclass
            class_name = class(obj);
            
            I = strfind(class_name,'.');
            
            save_dir_name = class_name(I(end)+1:end);
            
            obj.binary_data_transfer_path = fullfile(base_path,save_dir_name);
            
            if ~exist(obj.binary_data_transfer_path,'dir')
               mkdir(obj.binary_data_transfer_path) 
            end
            
            %Launching NEURON process if desired
            %--------------------------------------------------------------
            if sim_options.launch_NEURON_process_during_initialization
                
                %MOVE NEURON CODE TO HERE ...
                obj.path_obj = NEURON.paths.getInstance;
                obj.cmd_obj  = NEURON.cmd(sim_options.cmd_options);
                                                    
                initNEURON(obj);
                
                %NOTE: This class currently populates simulation variables
                %into Matlab
                obj.props = NEURON.simulation.props(obj);
            end
        end
    end
    
    methods (Hidden)
        function initNEURON(obj)
            %initNEURON Initializes the NEURON environment
            %
            %   This function:
            %   ===============================================
            %   1) Loads init_neuron.hoc
            %   2) Populates sim hash.
            
            %NEURON.cmd
            c = obj.cmd_obj;
            
            c.cd_set(obj.path_obj.hoc_code_root);            
            c.run_command('{xopen("$(NEURONHOME)/lib/hoc/noload.hoc")}');
            
            
            c.load_file('general_sim_definitions.hoc');
            
            %Consider moving to constructor of classes
            %--------------------------------------------------------------
            switch class(obj)
                case 'NEURON.simulation.extracellular_stim'
                    c.load_file('init_xstim.hoc');
                case 'NEURON.simulation.intracellular_stim'
                    c.load_file('init_istim.hoc');
                otherwise
                    error('Unhandled simulation class:%s',class(obj))
            end
            
            %This line must follow loading the initialization file
            c.writeStringProps({'sim_hash' 'binary_data_root_path'},...
                {obj.sim_hash NEURON.s.createNeuronPath(obj.binary_data_transfer_path)});
            
            if obj.options.run_inspector
                obj.inspector_obj = NEURON.inspector(c);
            end
        end
    end
    
    %INFO RETRIEVAL
    %======================================================================
    %Design note: These methods are meant to hide the properties class.
    methods
        function sim_duration = getSimDuration(obj)
           %getSimDuration
           %
           %    sim_duration = getSimDuration(obj)
           %
           %    Returns duration of the simulation
           %
           %    See Also:
           %        NEURON.simulation.props
           
           sim_duration = obj.props.getSimDuration;
        end
        function sim_time_vector = getSimTimeVector(obj)
           %getSimTimeVector
           %
           %    sim_time_vector = getSimTimeVector(obj
           %
           %    See Also:
           %        NEURON.simulation.props
           
           sim_time_vector = obj.props.getTimeVector;
        end
    end
    
    %OTHER METHODS
    %====================================================
    methods
        function adjustSimTimeIfNeeded(obj,lastEventTime)
            %adjustSimTimeIfNeeded
            %
            %    The goal of this function is to adjust how long the
            %    simulation will run (shorter or longer) depending upon when
            %    the last event of interest occurs and how long we want to
            %    wait for the event.
            %
            %    adjustSimTimeIfNeeded(obj,lastEventTime)
            %
            %	 RELEVANT OPTIONS - see options class
            %    ==========================================================
            %    autochange_run_time
            %    display_time_change_warnings
            %    time_after_last_event
            
            opt = obj.options;
            
            if ~opt.autochange_run_time
                return
            end
            
            DONT_CARE_TIME_DIFF = 0.001; %ms
            
            expected_sim_time = obj.props.getExpectedSimDuration;
            
            t_diff = expected_sim_time - (lastEventTime + opt.time_after_last_event);
            
            if abs(t_diff) < DONT_CARE_TIME_DIFF
                return
            end
            
            old_tstop = expected_sim_time;
            new_tstop = lastEventTime + opt.time_after_last_event;
            if opt.display_time_change_warnings
                if t_diff < 0
                    %Need more time ...
                    NEURON.sl.warning.formatted('Changing simulation time from %0g to %0g, to account for event at %0g',...
                        old_tstop,new_tstop,lastEventTime)
                else
                    %Trying to save time ...
                    NEURON.sl.warning.formatted('Changing simulation time from %0g to %0g, to save time, last event at %0g',...
                        old_tstop,new_tstop,lastEventTime)
                end
            end
            
            obj.props.autoChangeTStop(new_tstop)
            
            %changeProps(obj.props,'tstop',new_tstop)
        end
    end
    
    %METHODS THAT INTERACT WITH NEURON ===================
    methods 
        
        
    end
    
end
