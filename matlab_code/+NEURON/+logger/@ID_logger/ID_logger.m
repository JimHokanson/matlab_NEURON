classdef ID_logger < NEURON.logger
    %
    %
    %   Class:
    %   NEURON.logger.ID_logger
    %
    %   This is am implementation of a class that only has other classes to log.
    %
    %   See Also:
    %   NEURON.logger
    %   NEURON.auto_logger
    %   NEURON.logger.multi_id_manager
    
    properties (Abstract,Constant)
        PROPS_TO_LOG %Currently just a cell array of a list of properties
        %that are themselves classes (LOGGABLE classes)
    end
    
    properties
        multi_id_manager %Class: NEURON.logger.multi_id_manager
    end
    
    %CONSTRUCTOR   %=======================================================
    methods
        function obj = ID_logger(parent)
            obj@NEURON.logger(parent);
            
            save_base_path = obj.getClassPath;
            
            obj.multi_id_manager = ...
                NEURON.logger.multi_id_manager(save_base_path);
            
            obj.loadObject();
        end
    end
    
    %SAVE AND LOAD  %======================================================
    methods
        function saveObject(obj)
            obj.multi_id_manager.saveObject();
            obj.addPropsAndSave(struct);
        end
        
        function loadObject(obj)
            s = obj.getStructure; %#ok<NASGU>
            obj.multi_id_manager.loadObject();
        end
    end
    
    %PROCESSING   %========================================================
    methods
        function ID = find(obj,create_if_not_found, varargin)
            %
            %
            %    STATUS: Done, may need more testing
            %
            %   FULL PATH:
            %   NEURON.logger.ID_logger.find
            
            loggable_classes_cell_array = obj.getLoggableClasses(varargin{:});
            ignore = [];
            
            %Call method of ID manager
            [matching_row,is_new] = obj.multi_id_manager.find(...
                loggable_classes_cell_array,...
                create_if_not_found, ignore);
            
            found = ~isempty(matching_row);
                        
            if ~found()
                if (is_new && create_if_not_found)
                    ID = obj.updateIDandSave(@obj.saveObject);
                else
                    ID = obj.getID([]);
                end
            else
                ID = obj.getID(matching_row);
            end
            
        end
        function [obj_cell_array, varargout]  = getLoggableClasses(obj, varargin)
            %
            %    obj_cell_array = getLoggableClasses(obj)
            %
            %
            %    STATUS: Done, may need more testing
            
            ignore = [];         %indices of irrelevent loggable classes 
            if nargin == 2
                ignore = varargin{:};
            end
            
            p = obj.parent;
            
            props_local   = obj.PROPS_TO_LOG;
            n_props       = length(props_local);
            
            obj_cell_array = cell(1,n_props);
            for iProp = 1:n_props
                
                cur_prop = props_local{iProp};
                %NOTE: cur_prop is a loggable class
                if ismember(cur_prop, ignore)
                    ignore = [ignore, iProp];         %#ok
                end
                obj_cell_array{iProp} = p.(cur_prop);
                %We'll need to handle access properties at some point
                %in time, perhaps using try/catch ...
                
                %getProps(cur_prop); %is this ok?
                %We might want to later declare that all classes like xstim
                %have a getProps class... anyway these props are private :P
            end            
            varargout = ignore;
        end
    end
    
end

