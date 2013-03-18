classdef simulation < handle_light
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
        props_obj   %Class: NEURON.simulation.props
        options     %Class: NEURON.simulation.options
    end
    
    properties (Hidden)
        %.simulation()
        sim_hash    %String for preventing file save collisions 
        %between concurrent versions of Matlab. This is based upon the 
        %process id of Matlab, not the communications process.
        %IMPORTANT: This variable is declared in NEURON in init_neuron.hoc
    end
    
    properties
        %NOTE: These classes may not exist if NEURON is not loaded on
        %startup.
        cmd_obj  %Class: NEURON.cmd 
        n_obj    %Class: NEURON
        path_obj %Class: NEURON.paths
    end
    
    %INITIALIZATION    %===================================================
    methods
        function obj = simulation(sim_options)
            %NEURON.simulation Initializes the NEURON simulation
            %
            %   obj = NEURON.simulation(*run_NEURON)
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim
            %       NEURON.simulation.initNEURON
            
            if ~exist('sim_options','var')
               sim_options = NEURON.simulation.options; 
            end
            
            obj.sim_hash = ['p' num2str(feature('GetPid'),'%d') '_'];
            
            obj.options  = sim_options;
            
            %Launching NEURON process if desired
            %--------------------------------------------------------------
            if sim_options.launch_NEURON_process_during_initialization
                obj.n_obj       = NEURON(sim_options.nrn_options);
                obj.cmd_obj     = obj.n_obj.cmd_obj;
                obj.path_obj    = obj.n_obj.path_obj;
                
                initNEURON(obj);
                
                %NOTE: This class currently populates simulation variables
                %into Matlab
                obj.props_obj = NEURON.simulation.props(obj);
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
            
            c = obj.cmd_obj;
            
            c.load_file('init_neuron.hoc');

            %This line must follow loading the initialization file
            c.writeStringProps({'sim_hash'},{obj.sim_hash});
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
            %    ================================================
            %    autochange_run_time
            %    display_time_change_warnings
            %    time_after_last_event
            
            opt = obj.options;
            
            if ~opt.autochange_run_time
                return
            end
            
            DONT_CARE_TIME_DIFF = 0.001; %ms
            
            t_diff = obj.props_obj.tstop - (lastEventTime + opt.time_after_last_event);
            
            if abs(t_diff) < DONT_CARE_TIME_DIFF
                return
            end
            
            old_tstop = obj.props_obj.tstop;
            new_tstop = lastEventTime + opt.time_after_last_event;
            if opt.display_time_change_warnings
                if t_diff < 0
                    %Need more time ...
                    formattedWarning('Changing simulation time from %0g to %0g, to account for event at %0g',...
                        old_tstop,new_tstop,lastEventTime)
                else
                    %Trying to save time ...
                    formattedWarning('Changing simulation time from %0g to %0g, to save time, last event at %0g',...
                        old_tstop,new_tstop,lastEventTime)
                end
            end
            
            changeProps(obj.props_obj,'tstop',new_tstop)
        end
    end
    
    %METHODS THAT INTERACT WITH NEURON ===================
    methods 
        
        
    end
    
end
