classdef simulation < handle
    %
    %   CLASS: NEURON.simulation
    %
    %   SUBCLASS NOTES
    %   =========================================================
    %   1) Call this constructor
    %
    %   TODO: Better definition of model assignment. When does a particular
    %   model get attached to a simulation?
    %
    %   KNOWN IMPLEMENTORS
    %   =========================================================
    %   	NEURON.simulation.extracellular_stim
    %
    %   NEURON VARIABLES
    %   =========================================================
    %   celsius
    %   tstop
    %   dt
    %
    
    properties
        %TODO: Eventually expand into a class
        %Could incorporate solution method ... discrete integration, event based with dynamic steps ...
        celsius = 37      %
        tstop   = 1.2;    %(units - ms), stopping time for the simulation
        dt      = 0.005;  %(units - ms),
    end
    
    properties (Dependent)
       time_vector 
    end
    
    methods 
        function value = get.time_vector(obj)
           value = 0:obj.dt:obj.tstop;
        end
    end
    
    properties
        run_NEURON = true %Started but not yet suppported ... Goal was to allow calling
        %certain methods that didn't need the NEURON environment in order
        %to work, The thought was to really pass this to the NEURON class
        %and specifically to the write method
    end
    
    properties
        opt__TIME_AFTER_LAST_EVENT = 0.4 %Amount of time to wait after the last event
        %This is used for simulations to ensure that the simulation runs
        %long enough. See also the method adjustSimTimeIfNeeded()
    end
    
    properties
        sim_hash    %String for preventing save collisions between concurrent versions of Matlab
        %Created in the constructor.
        %NOTE: This is based upon the process id of Matlab, not
        %the communications process.
        %IMPORTANT: This is defined in init_neuron.hoc
        n_obj       %(class NEURON)    NOTE: If this is ever invalid we have problems
        %Might become invalid from stack dump
        cmd_obj     %(class NEURON.cmd)
    end
    
    properties (Hidden)
        cleanup_ref
    end
    
    %DEPENDENT PROPS & METHODS
    %===========================================================
    properties (Dependent)
        path_obj %(class NEURON_paths)
    end
    
    methods
        function value = get.path_obj(obj)
            value = obj.n_obj.path_obj;
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
            
            in.run_NEURON = true;
            in.debug      = false;
            in = processVarargin(in,varargin);
            
            obj.sim_hash    = ['p' num2str(feature('GetPid'),'%d') '_'];
                        
            obj.run_NEURON = in.run_NEURON;
            
            if obj.run_NEURON
                obj.n_obj       = NEURON;
                obj.n_obj.debug = in.debug;
                obj.cmd_obj     = NEURON.cmd(obj.n_obj);
                initNEURON(obj);
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
            
            t_diff = obj.tstop - (lastEventTime + obj.opt__TIME_AFTER_LAST_EVENT);
            
            if abs(t_diff) < DONT_CARE_TIME_DIFF
                return
            end
            
            old_tstop = obj.tstop;
            obj.tstop = lastEventTime + obj.opt__TIME_AFTER_LAST_EVENT;
            if t_diff < 0
                %Need more time ...
                formattedWarning('Changing simulation time from %0g to %0g, to account for event at %0g',...
                    old_tstop,obj.tstop,lastEventTime)
            else
                %Trying to save time ...
                formattedWarning('Changing simulation time from %0g to %0g, to save time, last event at %0g',...
                    old_tstop,obj.tstop,lastEventTime)
            end
            
            changeSimulationVariables(obj)
        end
    end
    
    %METHODS THAT INTERACT WITH NEURON ===================
    methods
        function changeSimulationVariables(obj)
            values = {obj.celsius   obj.tstop  obj.dt};
            props  = {'celsius'     'tstop'    'dt'};
            obj.cmd_obj.writeNumericProps(props,values);
        end
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
            changeSimulationVariables(obj)
            
            obj.cmd_obj.writeStringProps({'sim_hash'},{obj.sim_hash});
            
        end
    end
    
end
