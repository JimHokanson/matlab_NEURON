classdef ID_logger < NEURON.logger
    %
    %
    %   Class:
    %   NEURON.logger.ID_logger
    %
    %   This is am implementation of a class that only has IDs to log ...
    %
    %   TODO:
    %   =========================================
    %   1) Implement save & load in multi_id_manager
    %
    %   See Also:
    %   NEURON.logger
    %   NEURON.logger.multi_id_manager
    
    properties (Abstract,Constant)
        ID_LOGGER__PROPS %Currently just a cell array of a list of properties
        %that are themselves classes (LOGGABLE classes)
    end
    
    properties
        ID_LOGGER__multi_id_manager %Class: NEURON.logger.multi_id_manager
    end
    
    %CONSTRUCTOR   %=======================================================
    methods
        function obj = ID_logger(parent)
            obj@NEURON.logger(parent);
            
            save_base_path = obj.getClassPath;
            
            obj.ID_LOGGER__multi_id_manager = ...
                NEURON.logger.multi_id_manager(save_base_path);
        end
    end
    
    %SAVE AND LOAD  %======================================================
    methods
        function saveObject(obj)
            loggableClasses = obj.getLoggableClasses();
            n_props       = length(loggableClasses);
            for iObj = 1:n_props
                temp = loggableClasses{iObj};
                log = temp.getLogger();
                log.saveLog();
            end
            obj.ID_LOGGER__multi_id_manager.saveObject();
        end
        
        function loadObject(obj)
            loggableClasses = obj.getLoggableClasses();
            n_props       = length(loggableClasses);
            for iObj = 1:n_props
                temp = loggableClasses{iObj};
                log = temp.getLogger();
                log.loadLog();
            end
            obj.ID_LOGGER__multi_id_manager.loadObject();
        end
    end
    
    %PROCESSING   %========================================================
    methods
        function ID = find(obj,varargin)
            %
            %
            %    STATUS: Done, may need more testing
            
            in.create_if_not_found = true;
            in = sl.in.processVarargin(in,varargin);
            
            loggable_classes_cell_array = obj.getLoggableClasses;
            
            %Call method of ID manager
            [matching_row,is_new] = obj.ID_LOGGER__multi_id_manager.find(...
                loggable_classes_cell_array,...
                'create_if_not_found',in.create_if_not_found);
            
            found = ~isempty(matching_row);
                        
            if ~found()
                if (is_new && in.create_if_not_found)
                    ID = obj.updateIDandSave(@obj.saveObject);
                else
                    ID = obj.getID([]);
                end
            else
                ID = obj.getID(matching_row);
            end
            
        end
        function obj_cell_array = getLoggableClasses(obj)
            %
            %    obj_cell_array = getLoggableClasses(obj)
            %
            %
            %    STATUS: Done, may need more testing
            
            p = obj.LOGGER__parent;
            
            props_local   = obj.ID_LOGGER__PROPS;
            n_props       = length(props_local);
            
            obj_cell_array = cell(1,n_props);
            for iProp = 1:n_props
                
                cur_prop = props_local{iProp};
                %NOTE: cur_prop is a loggable class
                
                obj_cell_array{iProp} = p.getProps(cur_prop); %is this ok?
                %We might want to later declare that all classes like xstim
                %have a getProps class... anyway these props are private :P
            end
            
        end
    end
    
end

