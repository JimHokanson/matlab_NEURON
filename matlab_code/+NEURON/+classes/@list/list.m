classdef list < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.classes.list
    %
    %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/classes/list.html#List
    
    %Unimplemented methods
    %append
    %prepend
    %insrt
    %remove
    %remove_all
    %index
    %o
    
    
    properties (Hidden)
       cmd_obj
    end
    
    methods
        function obj = list(cmd_obj)
           obj.cmd_obj = cmd_obj;
        end
        function count(obj)
            
        end
    end
    
end

