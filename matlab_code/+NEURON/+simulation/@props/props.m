classdef props < NEURON.sl.obj.handle_light 
    %
    %   Class: 
    %       NEURON.simulation.props
    %
    %   IMPROVEMENTS:
    %   ==============================================================
    %   1) Build in support for different time solver methods
    %       - see cvode, use_daspk is alright for extracellular stim BUT
    %           it seems slow
   
    properties (Hidden)
       cmd_obj  %Class: NEURON.cmd 
       parent   %Class: NEURON.simulation
    end
    
    properties (SetAccess = private)
        %.changeProps()
        %Use .changeProps to change these properties
        celsius = 37
    end
    
    %Time Properties   ====================================================
    properties
        %METHODS
        %   getTimeVector
        %   getExpectedSimDuration
        %   getSimDuration
        
        tstop   = 1.2       %(units - ms) Stopping time for the simulation
    end
    
    %Fixed Time Step Properties  %=========================================
    properties (SetAccess = private)
        dt      = 0.005     %(units - ms) dt for fixed time solvers
        
        %NOT YET SUPPORTED
        %secondorder = 0; 
        %0 - fully implicit backward euler
        %1 - CN
        %2 - 
        %http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/nrnoc.html#secondorder
    end
     
    %Variable Time Step Properties  %======================================
    properties 
       %use_variable_time_step   %Not yet implemented
        
       %CVODE : http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/classes/cvode.html
    end
    
    %TIME RELATED METHODS  %===============================================
    methods
        function final_time = getExpectedSimDuration(obj)
           final_time = obj.tstop; 
        end
        function final_time = getSimDuration(obj)
           %
           %
           
           final_time_used = obj.cmd_obj.getScalar('t');
           if isnan(final_time_used)
               error('Why is this NaN?')
           elseif final_time_used == 0
               %TODO: Throw warning here ...
               final_time = obj.tstop;
           else
               final_time = final_time_used;
           end
        end
        %TODO: Make these both call the same method ...
        function value = getTimeVector(obj)
            %
            %   value = getTimeVector(obj)
            
           %Currently we assume fixed time
           value = 0:obj.dt:obj.getSimDuration;
        end
        function value = getExpectedTimeVector(obj)
           value = 0:obj.dt:obj.getExpectedSimDuration; 
        end
    end
    
    methods (Hidden)
        function autoChangeTStop(obj,new_value)
           %This method should be used to automatically 
           %change the stopping time when it is desirable
           %not to disengage the auto update
           %
           %    Manually setting it (via changeProps)
           %    
           %
           %    Written for NEURON.simulation.adjustSimTimeIfNeeded
           
           obj.tstop = new_value;
           obj.changeSimulationVariables();
        end
    end
    
    methods
        function obj = props(parent_obj,varargin)
            obj.parent  = parent_obj;
            obj.cmd_obj = parent_obj.cmd_obj;
            obj.changeProps(varargin);
        end
        function changeProps(obj,varargin)
           %changeProps
           %
           %    changeProps(obj,varargin)
            
           % process inputs
           in.celsius = obj.celsius;
           in.tstop   = []; %NULL VALUE
           in.dt      = obj.dt;
           in = NEURON.sl.in.processVarargin(in,varargin);
            
           if isempty(in.tstop)
               in.tstop = obj.tstop;
           else
               %Manual override of tstop
               %NEURON.simulation.options
               obj.parent.options.autochange_run_time = false;
           end
           
           % change properties
           obj.celsius = in.celsius;
           obj.tstop   = in.tstop;
           obj.dt = in.dt;
           
           % change in NEURON
           obj.changeSimulationVariables();
        end
        
        function changeSimulationVariables(obj)
            %changeSimulationVariables
            %
            %   changeSimulationVariables(obj)
            
            values = {obj.celsius   obj.tstop  obj.dt};
            props  = {'celsius'     'tstop'    'dt'};
            obj.cmd_obj.writeNumericProps(props,values);
        end   
    end
    
    %LOGGING FUNCTION  %===================================================
    methods
        function logger = getLogger(obj)
            logger = NEURON.simulation.props.logger.getInstance(obj);
        end
    end
  
end