classdef props < handle_light 
    %
    %   Class: 
    %       NEURON.simulation.props
    %
    %   IMPROVEMENTS:
    %   ==============================================================
    %   1) Build in support for different time solver methods
    %       - see cvode, use_daspk is alright for extracellular stim BUT
    %           it seems slow
    %       - 
    
    properties (SetAccess = private)
        %.changeProps()
        %Use .changeProps to change these properties
        celsius = 37
        tstop   = 1.2       %(units - ms) Stopping time for the simulation
        dt      = 0.005     %(units - ms) dt for fixed time solvers
    end
    
    properties (Dependent)
       time_vector 
    end
    
    methods
        function value = get.time_vector(obj)
           %This could change based on the simulation type ...
           value = 0:obj.dt:obj.tstop;
        end
    end
    
    properties (Hidden)
       parent   %Class: NEURON.simulation
    end
    
    methods
        function obj = props(parent_obj,varargin)
            obj.parent = parent_obj;
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
           in = processVarargin(in,varargin);
            
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
            obj.parent.cmd_obj.writeNumericProps(props,values);
        end   
    end
  
end