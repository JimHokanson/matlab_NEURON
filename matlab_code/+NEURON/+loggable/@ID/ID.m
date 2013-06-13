classdef ID < handle_light
    %
    %
    %   Class:
    %   NEURON.loggable.ID

    properties(SetAccess = private)
        class_type
        type
        row
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    %So will the xstim_logger maintain a cell of these IDs?
    methods
        function obj = ID()
        end
        
        function setType(obj, type)
            obj.type = type;
        end
        
        function setRow(obj, row)
            obj.row = row;
        end
        
        function r = getRow(obj)
            r = obj.row;
        end
        
        function t = getType(obj)
            t = obj.type;
        end
        
        %takes in two IDs.. this mught be superfluous but...
        function b = compareType(obj, ID)
            b = 0; %b for boolean
            if(obj.type == ID.type)
                b = 1;
            end
        end
        
    end
end