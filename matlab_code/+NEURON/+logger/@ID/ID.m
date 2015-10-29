classdef ID < NEURON.sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.logger.ID
    %
    %   See Also:
    %   NEURON.logger
    %   NEURON.logger.getID
    
    properties (SetAccess = {?NEURON.sl.struct.toObject})
        class_type    %(char) string to uniquely identify class
        type          %(numeric), used for comparing subclass types
        %Unfortunately right now it is up to the user to manage
        %different subtypes of a class
        trial_row     %(numeric)
        creation_date %(numeric), added to ensure uniqueness of id
    end
    
    properties (Constant)
        VERSION = 1
    end
    
    methods
        function obj = ID(class_type, type, trial_row, creation_date)
            %
            %   obj = ID(class_type, type, trial_row, creation_date)
            %
            %   INPUTS: See properties
            %   trial_row : For null ids pass in an empty value here
            %   
            %
            %   NOTE: An empty trial_row will be used to indicate
            %   a NULL ID
            
            if nargin == 0
                return
            end
            
            if isempty(trial_row)
                trial_row     = NaN;
                creation_date = NaN;
            end
            
            obj.type          = type;
            obj.class_type    = class_type;
            obj.trial_row     = trial_row;
            obj.creation_date = creation_date;
        end
        function s = getStruct(obj)
           s = NEURON.sl.obj.toStruct(obj); 
        end
        function flag = isValid(obj)
            flag = ~isnan(obj.trial_row);         
        end  
        function file_name = getSaveString(obj,varargin)
            %
            %
            %   file_name = getSaveString(obj)
            %
            %   This function was written to allow saving files based
            %   on the id returned by a logger object.
            
            %NYI
%            in.include_class = false;
%            in.include_date  = false;
%            in.ext           = '.mat';
%            in = NEURON.sl.in.processVarargin(in,varargin);
           
            file_name = sprintf('ID_%d_%d.mat',obj.type,obj.trial_row);
        end
%         function validateID(obj)
%            %TODO: Check dates and provide specific error
%               message if everything else is the same ...
%         end
        function flag = eq(obj,other_obj)
           flag = obj.type == other_obj.type && ...
                obj.trial_row == other_obj.trial_row && ...
                obj.creation_date == other_obj.creation_date && ...
                strcmp(obj.class_type,other_obj.class_type);
        end
        function flag = ne(obj,ID)
           %Not sure if I need this ...
           flag = ~eq(obj,ID);
        end
    end
    
    methods (Static)
        function obj = fromStruct(s)
           %NOTE: We could do version updating here ...
           obj = NEURON.logger.ID;
           NEURON.sl.struct.toObject(obj,s);
        end
    end
end