classdef simulation < handle_light
    %
    %   CLASS: NEURON.simulation
    %
    %   This class (or subclass) are the main class for running NEURON.
    %
    %   SUBCLASS NOTES
    %   =========================================================
    %   1) Call this constructor
    %
    %   KNOWN IMPLEMENTORS
    %   =========================================================
    %   	NEURON.simulation.extracellular_stim
    %
    %   IMPROVEMENTS
    %   =========================================================
    %   1) Remove reference to n_obj
    %   2) Improve options handling for launching NEURON process
    %   3) 
    %
    
    properties
        props_obj   %Class: NEURON.simulation.props
    end

    properties (SetAccess = private)
        opt__launch_NEURON_process_during_initialization = true %This variable 
        %is handled in the
    end
    
    properties
        %TODO: 
        opt__TIME_AFTER_LAST_EVENT = 0.4 %Amount of time to wait after the last event
        %This is used for simulations to ensure that the simulation runs
        %long enough. See also the method adjustSimTimeIfNeeded()
    end
    
    properties
        %.simulation()
        sim_hash    %String for preventing file save collisions 
        %between concurrent versions of Matlab. This is based upon the 
        %process id of Matlab, not
        %the communications process.
        %IMPORTANT: This variable is declared in NEURON in init_neuron.hoc
        
        %Might become invalid from stack dump
        cmd_obj     %(Class NEURON.cmd) This class may not exist if
    end
    
    properties (Access = private)
       n_obj        %(Class: NEURON)
    end
    
    properties (Hidden)
        cleanup_ref
    end
    
    %DEPENDENT PROPS & METHODS
    %===========================================================
    properties (Dependent)
        path_obj    %(Class: NEURON.paths)
    end
    
    methods
        function value = get.path_obj(obj)
            if isobject(obj.n_obj)
                value = obj.n_obj.path_obj;
            else
                value = [];
            end
        end
    end
    
    %INITIALIZATION
    %====================================================
    methods
        function obj = simulation(varargin)
            %NEURON.simulation Initializes the NEURON simulation
            %
            %   obj = NEURON.simulation(*run_NEURON)
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim
            %       NEURON.simulation.initNEURON
            
            in.launch_NEURON_process = obj.opt__launch_NEURON_process_during_initialization;
            in.debug                 = false;
            in.log_commands          = false;
            in = processVarargin(in,varargin);
            
            obj.sim_hash    = ['p' num2str(feature('GetPid'),'%d') '_'];
                                    
            %TODO: Make this a method
            if in.launch_NEURON_process
                obj.n_obj       = NEURON('debug',in.debug,'log_commands',in.log_commands);
                obj.cmd_obj     = NEURON.cmd(obj.n_obj);
                
                initNEURON(obj);
                
                %TODO: Build in non-sim running support
                obj.props_obj = NEURON.simulation.props(obj);
            end
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
            %	PROPERTIES
            %    ================================================
            %    .opt__TIME_AFTER_LAST_EVENT : see definition in class
            
            DONT_CARE_TIME_DIFF = 0.001; %ms
            
            t_diff = obj.props_obj.tstop - (lastEventTime + obj.opt__TIME_AFTER_LAST_EVENT);
            
            if abs(t_diff) < DONT_CARE_TIME_DIFF
                return
            end
            
            old_tstop = obj.props_obj.tstop;
            new_tstop = lastEventTime + obj.opt__TIME_AFTER_LAST_EVENT;
            if t_diff < 0
                %Need more time ...
                formattedWarning('Changing simulation time from %0g to %0g, to account for event at %0g',...
                    old_tstop,new_tstop,lastEventTime)
            else
                %Trying to save time ...
                formattedWarning('Changing simulation time from %0g to %0g, to save time, last event at %0g',...
                    old_tstop,new_tstop,lastEventTime)
            end
            
            changeProps(obj.props_obj,'tstop',new_tstop)
        end
    end
    
    %METHODS THAT INTERACT WITH NEURON ===================
    methods 
        
        function initNEURON(obj)
            %initNEURON Initializes the NEURON environment
            %
            %   This function:
            %   ===============================================
            %   1) Changes to the NEURON directory
            %   2) Loads init_neuron.hoc
            %   3) Populates simulation variables ...
            
            cmd = obj.cmd_obj;
            cmd.cd_set(obj.path_obj.hoc_code_root);
            cmd.load_file('init_neuron.hoc');
            %changeSimulationVariables(obj)
            % do the simulation variables need to be sent to NEURON before
            % the next line? If so, I may be breaking this right now.
            
            obj.cmd_obj.writeStringProps({'sim_hash'},{obj.sim_hash});
            
        end
    end
    
end
