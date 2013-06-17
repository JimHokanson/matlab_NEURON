classdef ID < handle_light
    %
    %
    %   Class:
    %   NEURON.logger.ID
    
    properties (SetAccess = private)
        class_type  %(char) string to uniquely identify class
        type        %(numeric), used for comparing subclass types
        trial_row   %(numeric)
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    methods
        function obj = ID(class_type, type, trial_row)
            %
            %   obj = ID(class_type, type, trial_row)
            %
            %   INPUTS: See properties
            %
            %   NOTE: An empty trial_row will be used to indicate
            %   a NULL ID
            
            if isempty(trial_row)
                trial_row = NaN;
            end
            
            obj.type       = type;
            obj.class_type = class_type;
            obj.trial_row  = trial_row;
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
        
        function flag = isValid(obj)
            flag = ~isnan(obj.trial_row);         
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