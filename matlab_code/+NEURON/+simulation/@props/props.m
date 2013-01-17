classdef props < handle_light % JW note: I'm not actually sure what handle_light does, but I'm basing this on other props classes
    
    % Class: NEURON.simulation.props
    
    properties (SetAccess = private)
        celsius = 37
        tstop   = 1.2 %(units - ms), stopping time for the simulation
        dt      = 0.005 %(units - ms
    end
    
    properties (Hidden)
       parent % Class: NEURON.simulation
    end
    
    methods
        function obj = props(parent_obj,varargin)
            obj.parent = parent_obj;
            obj.changeProps(varargin);
        end
        
        function changeProps(obj,varargin)
           % process inputs
           in.celsius = obj.celsius;
           in.tstop   = obj.tstop;
           in.dt      = obj.dt;
           in = processVarargin(in,varargin);
            
           % change properties
           obj.celsius = in.celsius;
           obj.tstop = in.tstop;
           obj.dt = in.dt;
           
           % change in NEURON
           obj.changeSimulationVariables();
        end
        
        function changeSimulationVariables(obj)
            values = {obj.celsius   obj.tstop  obj.dt};
            props  = {'celsius'     'tstop'    'dt'};
            obj.parent.cmd_obj.writeNumericProps(props,values);
        end   
    end
  
end