classdef ID < handle_light
    %
    %
    %   Class:
    %   NEURON.loggable.ID
    
    properties(SetAccess = private)
        class_type
        type
        trial_row
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    methods
        function obj = ID(class, type, row)
            obj.type = type;
            obj.class_type = class;
            obj.trial_row = row;
        end
        
        function setType(obj, type)
            obj.type = type;
        end
        
        function setClassType(obj, class)
            obj.class_type = class;
        end
        
        function setRow(obj, row)
            obj.trial_row = row;
        end
        
        function flag = validID(obj)
            if isnan(obj.trial_row)
                flag = 0;
                return
            end
            flag = 1;            
        end
                
        %takes in two IDs.. this mught be superfluous but...
        function flag = compareID(obj, ID)
            flag = 0; %b for boolean
            if (isnan([obj.trial_row ID.trial_row])) || (obj.row ~= ID.row)
                return
            end
            if obj.class_type ~= ID.class_type
                return
            end
            if obj.type ~= ID.type
                return;
            end
            flag = 1;
        end
        
    end
end