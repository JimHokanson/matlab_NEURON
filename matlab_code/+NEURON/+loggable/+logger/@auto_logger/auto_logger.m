classdef auto_logger < logger
    %
    
    %This makes comparison of a set of scalars not as appealing since
    %we now need to do more comparisons
    %
    %   i.e. we might have had:
    %
    %   [prop1 prop2 prop3 prop4 prop5]
    %
    %   AND
    %
    %   [n x 5] - all previous entries of 1:5
    %
    %
    %   oh well, we might be able to speed this up later
    %
    
    
    
    properties (Abstract,Constant)
        VERSION
        CLASS_NAME
        %Column 1 - prop_name
        %Column 2 - compare_type - string or function handle
        %Column 3 - custom retrieval method
        AUTO_INFO
        %========================================
        %types
        %- scalarInt - compareScalarExact
        %- scalarFP  - comapareScalarsFloatingPoint
        %- matrixFP  -
        %- cellFP    - Varying lengths of matrices
    end
    
    properties (Abstract)
        log_manager
        loggable
        type
    end
    
    properties
        log_events
        log_IDs
        next = 1
    end
    
    methods(Abstract)
        event = makeEvent(obj)
    end
    
    
    methods
        function obj = auto_logger(obj)
            
            %define props
            prop_names = obj.getPropNames;
            for iProp = 1:length(prop_names)
                addprop(obj,prop_names{iProp})
            end
            
            %Reload objects
            
            obj.loadHelper();
        end
        
        function id = makeID(obj)
            id = ID(obj.next, obj.type, obj.className);
            obj.next = obj.next + 1 ;
        end
        
        
        function addEvent(obj, log_event)
            %this function should only be called by the find method
            %that way it is only added if nothing is found.
            props = obj.getPropNames();
            len = length(props);
            for i = 1:len
                extendVar(props{i}, log_event{i});
            end
        end
        
        %length of ID vector must match that of the event log vector
        function addID(obj, log_ID)
            obj.log_IDs = [obj.log_IDs; log_ID];
        end
        
        %this might not be the functionality i want...
        function [id, flag] = getID(log_event)
            flag = 0; %if the id was just created cuz it wasnt found
            r = findEvent(obj, log_event);
            if r == 0
                flag = 1;
                newEvent(obj, log_event);
                return
            end
            id = obj.log_IDs{r};
        end
        
        function id = newEvent(obj, log_event)
            %Only called when an event is not found
            id = makeID(obj);
        end
        
        
        function ind = findInd(obj, propname, fHandle, value, indices)
            %look through the values given by the prop specified bu
            %propname and find the indices (using the specified function)
            %that match the given value.
            %somehow specify that indices need not be specified.
            
            % using indices generate another var that of only those values
            % maintain the indice mapping because the original values are
            % what you will want to return.
            
            var = getVar(propname);
            temp =  arrayfun(fHandle, var, value);
            ind = find(temp > 0);
        end
        
        
        %An event is a particular combination of variables. We maintain
        %each unique event and map it to an ID. The ID is what is held in
        %the MIMs
        function [id flag] = findEvent(obj)
            event = obj.makeEvent();
            props = obj.getPropNames();
            methods = obj.getCopmarisonMethods();
            len = length(event);
            indices = 1:length(props); %assume length of props and methods
            %stuf like that are all the same.
            for i = 1:len
                indices = findInd(obj, prop{i}, methods{i}, event{i});
            end
            
            if len(indices == 0)
                %event was not found, make this a new one
                flag = 1;
                id = logEvent(obj, event);
                return
            end
            if len(indices == 1)
                %we found it!
                flag = 0;
                id = getID(obj, indices);
                return
            end
            %-----It should not get here----
            %throw an error if it does
            %each event should only be logged once
            
        end
        
        
        function propNames = getPropNames(obj)
            %Try to reduce the # of places where we randomly index into
            %a structure
            propNames = obj.AUTO_INFO(:,1);
        end
        
        function methods = getComparisonMethods(obj)
            methNames = obj.AUTO_INFO(:,3);
            len = length(methNames);
            %if comparison method is not defined use default
            methods = cell(len,1); %column vector
            for i = 1:len
                methods{i} = getHandle(methNames, 'comparison');
            end
        end
        
        %This needs to be finished... will the
        function fHandle = getHandle(obj, fName, type)
            %Returns the appropriate handle to the function needed
            %depending on the kind of functionyour running.. if not
            %specified it returns the default for that type of function
            % Currently only 'comparison' type is available
            switch type
                case 'comparison'
                    if strcmp(fName, '')
                        fHandle = 42; %Fix me please!
                        return;
                    end
                    fHandle = str2func(fName);
                case 'set'
                    %define specfic getters and setters for specific
                    %variables defer to the appropriate class to handle
                    %this maybe. same with getters IE
                    %to getVar of elec_logger, u pass in varname and get
                    %then this will defer to the appropraite vraibal form
                    %there.. maybe
                case 'get'
            end
        end
    end
    
    
    methods
        
        function var = getVar(varname)
            str = strcat('obj.',varname);
            var = eval(str);
        end
        
        function var = extendVar(varname, row)
            var = getVar(varname);
            var = [var;row];
            str = strcat('obj.',varname,' = var');
            eval(str);
        end
        
        function addLogProps(obj)
            cur_props = properties(obj);
            other_props = getPropNames(obj);
            len = length(other_props);
            for i = 1:len
                prop = other_props{i};
                if sum(strcmp(prop, cur_props)) == 0
                    obj.addprop(prop);
                end
            end
        end
        
        %function compare(obj, varname)
        %end
        
        function loadProps(obj)
            path = getLoggerPath(obj);
            p = load(path);
            if p.version == obj.VERSION
                %IS THE EVAL FUNCTION BAD? I'm not using it in a way that
                %breaks down our OOP and encapscilation.
                addLogProps(obj);
                objTemp = 'obj.';
                filTemp = ' = p.';
                names = getPropNames(obj);
                len = length(names);
                for i = 1:len
                    var = names{i};
                    commandStr = strcat(objTemp,var,filTemp,var);
                    eval(commandStr);
                end
            end
        end    
        
        
        function updateObj(obj)
            %NOTE: subclasses should implement this if they need to
            %i.e. if their version changes ...
            error('Object needs to be updated but update method is not implemented')
        end
    end
    
    methods (Static)
        %?? Are empty old values tolerated??????
        function mask = compareScalarsExact(old,new)
            mask = old == new;
        end
        function mask = comapareScalarsFloatingPoint(old,new)
            %???? -> how to know comparison level ....?
            %
            %   For now do absolute, potentially later add option
            %   for specifying percent difference ...
            %   percent difference is hard ...
            %
            %   could also later add on option for absolute difference ...
            
            
            mask = abs(old - new) < 10*eps;
        end
        function mask = compareVectorExact(old,new)
            %NOTE: Might need to do empty ...
        end
    end
    
end

