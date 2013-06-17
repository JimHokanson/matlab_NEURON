classdef auto_logger < NEURON.logger
    %
    %
    %   Class:
    %   NEURON.logger.auto_logger

    properties (Abstract,Constant)
        AUTO_LOGGER__IS_SINGULAR_OBJECT  %Specify whether or not this class is singular,
        %or whether or not it will ever have multiple instances.
        
        AUTO_LOGGER__INFO %Get's passed into processor
    end
    
%     properties  
%         AUTO_LOGGER__processor NYI
%     end
    
    %AUTO_INFO Processing Methods =========================================
    %NOTE: These might eventually get moved into their own class ...
    methods
        %These methods should be called instead of accessing the AUTO_INFO
        %cell array directly ...
        function propNames = getPropNames(obj)
            propNames = obj.AUTO_LOGGER__INFO(:,1);
        end
        function typeNames = getTypeNames(obj)
            typeNames = obj.AUTO_LOGGER__INFO(:,2);
        end
        function output = getRetrievalMethods(obj)
            %returns functionHandles for retieving.
            output = obj.AUTO_LOGGER__INFO(:,3); 
        end
    end
    
    %Constructor  =========================================================
    methods
        function obj = auto_logger(parent)
            %
            %
            %   obj = auto_logger(parent)    
            
            obj@NEURON.logger(parent);
            
            %Dynamically create props to reference previous values
            %-------------------------------------------------------------
            prop_names = obj.getPropNames;
            for iProp = 1:length(prop_names)
                addprop(obj,prop_names{iProp});
            end
            
            
            %This implementation is delayed for now ...
% %             %Create processor
% %             %--------------------------------------------------------------
% %             obj.AUTO_LOGGER__processor = ...
% %                     NEURON.logger.auto_logger.processor(...
% %                                 parent, ...
% %                                 obj.AUTO_LOGGER__IS_SINGULAR_OBJECT, ...
% %                                 obj.AUTO_LOGGER__INFO);
            
            %Reload objects
            %--------------------------------------------------------------
            obj.loadHelper();
        end
    end

    %Property Processing Methods ==========================================
    methods 
        %PROPERTY RETRIEVAL   =============================================
        function new_value = getNewValue(obj,prop_name,retrieval_method)
           %
           %    new_value = getNewValue(obj,prop_name,retrieval_method)
           %
           %    INPUTS
           %    ===========================================================
           %    prop_name : (char) name of the property to retrieve from 
           %            the parent
           %    retrieval_method : One of 3 types
           %            See definition of AUTO_INFO
           %
           %    FULL PATH
           %    ===================================================
           %    NEURON.logger.auto_logger.getNewValue
           
           parent      = obj.LOGGER__parent;
           is_singular = obj.AUTO_LOGGER__IS_SINGULAR_OBJECT;
                      
           if isempty(retrieval_method)
              %Retrieve directly ...
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
            %
            %
            %   output_indices = compare(obj, new, old, type, input_indices)
            %
            %depending on the type find the appropriate comparison method
            %return indices of the same prop...
            %
            %   FULL PATH:
            %   ===========================================================
            %   NEURON.logger.auto_logger
            
            %NOTE: This shouldn't be needed ...
            if isempty(input_indices)
                output_indices = [];
                return;
            end
            
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
                    I = obj.compare(new,temp_matrix,'vectorFP',1:size(temp_matrix,1));
                    
                    %Adjust indices to match input scale ...
                    %-----------------------------------------------------
                    same_size_indices = find(same_size);
                    temp_indices      = same_size_indices(I);
                case 'vectorFP'
                    %STATUS: DONE
                    temp         = old(input_indices,:);
                    difference   = bsxfun(@minus, new, temp);
                    
                    %NOTE: somewhat arbitrary comparison
                    %TODO: Add reasoning for this in design decision
                    %
                    %i.e. for now we want to compare equal to within
                    %computation error, not roughly equal where we might 
                    %decide 3.001 is close enough to 3 that we don't care
                    %
                    %The latter is very difficult to do, especially with
                    %a wide range of numbers ...
                    fp_is_different = abs(difference) > 10*eps;
                    
                    temp_indices = find(~any(fp_is_different,2));
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
       %find -> see separate file
    end
    
end

