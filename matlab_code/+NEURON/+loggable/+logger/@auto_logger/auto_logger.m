classdef auto_logger < NEURON.loggable.logger
    %
    %
    %   Class:
    %   NEURON.loggable.logger.auto_logger
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
        IS_SINGULAR_OBJECT
        AUTO_INFO
        %========================================
        %types
        %- scalarInt - compareScalarExact
        %- scalarFP  - comapareScalarsFloatingPoint
        %- matrixFP  -
        %- cellFP    - Varying lengths of matrices
    end
    
    properties 
        %log_manager
        %loggable
        %type 
        n_trials = 0
    end
    
    properties
        log_events
        log_IDs
    end
    
    methods(Abstract)
        event = makeEvent(obj)
    end
    
    
    methods
        function obj = auto_logger(parent)
            obj.parent = parent;
            %define props
            prop_names = obj.getPropNames;
            for iProp = 1:length(prop_names)
                addprop(obj,prop_names{iProp});
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
        
        function typeNames = getTypeNames(obj)
            %Try to reduce the # of places where we randomly index into
            %a structure
            typeNames = obj.AUTO_INFO(:,2);
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
        function fHandle = getHandle(obj, type)
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
           var = obj.(varname);
        end
        
        function var = extendVar(obj, varname, row)
            obj.(varname) = [obj.(varname) row]; %yes? 
            var = obj.(varname);
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
        
        
        %finish this later
        function loadProps(obj)
            path = getLoggerPath(obj);
            p = load(path);
            if p.version == obj.VERSION
                addLogProps(obj);
                names = getPropNames(obj);
                len = length(names);
                for i = 1:len
                    var = names{i};
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
    
    %Property Processing Methods ==========================================
    methods 
        function new_value = getNewValue(obj,prop_name,retrieval_method)
           %
           %    retrieval method
           %    1) default ''
           %    2) string -> predefined method to run -> implemented in
           %                auto_logger
           %    3) 
           
           parent = obj.parent;
           is_singular = obj.IS_SINGULAR_OBJECT;
           
% % %            if isempty(retrieval_method)
% % %               new_value = parent.(prop_name); 
% % %            elseif ischar(retrieval_method)
% % %               fh = str2func(retrieval_method);
% % %               new_value = fh(obj,prop_name);
% % %            else
% % %               new_value = retrieval_method(p,prop_name); 
% % %            end
           
           
           if isempty(retrieval_method)
              new_value = parent.(prop_name); 
           elseif ischar(retrieval_method)
               switch retrieval_method
                   case 'numeric'
                       if ~is_singular
                          new_value = [parent.(prop_name)];
                       else
                          error('Implementation not yet defined')
                       end
                   case 'string'
                       if ~is_singular
                          new_value = {parent.(prop_name)};
                       else
                          error('Implementation not yet defined')
                       end 
                   otherwise
                       error('Case not yet handled')
               end
           else
               %function handle
               new_value = feval(retrieval_method,obj,p,prop_name);
           end
        end
        
        function output_indices = compare(obj, new, old, type, input_indices)
            %depending on the type find the appropriate comparison method
            %return indices of the same prop...
            
            switch type
                case 'simple_numeric'
                   temp_indices = find(new == old(input_indices));
                case 'cellFP'
                    %- each old element is an entry in a cell array
                    %- the entries themselves are arrays
                    %- the values inside should be considered floating point
                    %   so we need to do a floating point comparison
                    
                    %old = {[1 2 3] [1 2 3 4 5 6] [0 100 0] };
                    
                    truncated_values = old(input_indices);
                    
                    %Remove dimensions that are not the same length
                    %------------------------------------------------------
                    same_size   = cellfun('length',truncated_values) == length(new);
                    temp_matrix = vertcat(truncated_values{same_size});
                    
                    %Use matrix comparision function for final comparison
                    %------------------------------------------------------
                    I = obj.compare(new,temp_matrix,'matrixFP',1:size(temp_matrix,1));
                    
                    %Adjust indices to match input scale ...
                    %-----------------------------------------------------
                    same_size_indices = find(same_size);
                    temp_indices      = same_size_indices(I);
                    
                    keyboard
                case 'matrixFP'
                    a
                    
                otherwise
                    error('Type %s not recognized',type)
            end
            
            output_indices = input_indices(temp_indices);
            
            %method = getCompar
            %ind = find(~cellfun(method, new, old));
        end
        
    end
    
    
    %Implementation of Abstract Methods ===================================
    methods
        
        %move later with other similar methods, K?
        function output = getRetrievalMethods(obj)
            %returns functionHandles for retieving.
            output = obj.AUTO_INFO(:,3); 
        end
        
        
        function update()
        end
        

        
        function deleteIndices()
        end

        %function [ID,is_new] = find_addIfNotFound()
        
        
        function addEntry(obj)
           %
        end
        
        
%         function id = createID(obj,match_row)
%             
%             
%             if ~exist('match_row','var')
%                match_row = -1; 
%             end
%             
%            if ~exist('match_row','var')
%                %Make null call to constructor
%               id = NEURON.loggable.ID; 
%            else
%                %
%                id = NEURON.loggable.ID(match_row);
%            end
%             
%            id = NEURON.loggable.ID;
%            id.setType(obj.type);
%            id.setRow(match_row);
%         end
        function save()
        end
    
    end
    
end

