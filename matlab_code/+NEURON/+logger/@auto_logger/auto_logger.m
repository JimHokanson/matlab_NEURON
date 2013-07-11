classdef auto_logger < NEURON.logger
    %
    %   Class:
    %   NEURON.logger.auto_logger
    %
    %   ABSTRACT CLASS
    %
    %   The goal of this class to provide logging via a simple set of 
    %   processing instructions that specify:
    %   1) What properties to log
    %   2) How to log them
    %   3) How to compare them to previous values
    %
    %   Known implementations:
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.electrode.logger
    %   NEURON.simulation.props.logger
    %   NEURON.tissue.homogeneous_anisotropic.logger
    %   NEURON.tissue.homogeneous_isotropic.logger
    %   NEURON.cell.axon.MRG.logger
    %
    %   See Also:
    %   NEURON.logger
    %
    %   MAIN METHODS
    %   ===================================================================
    %   NEURON.logger.auto_logger.getNewValue
    
    properties (Abstract,Constant)
        IS_SINGULAR_OBJECT  %Specify whether or not this class is singular,
        %or whether or not it will ever have multiple instances.
        
        PROCESSING_INFO %Idea is to eventually pass this into the processor ...
        %See the processor for format instructions ...
        %
        %   The get methods also provide sufficient detail ...
    end
    
    properties
        old_values %(structure) contains previous class values. The names
        %match the properties of the loggable class, but their values
        %are the results of concatenating previous values.
    end
    
    %AUTO_INFO Processing Methods =========================================
    %NOTE: These might eventually get moved into their own class ...
    methods
        %These methods should be called instead of accessing the PROCESSING_INFO
        %cell array directly ...
        function propNames = getPropNames(obj)
            propNames = obj.PROCESSING_INFO(:,1);
        end
        function typeNames = getTypeNames(obj)
            typeNames = obj.PROCESSING_INFO(:,2);
        end
        function output = getRetrievalMethods(obj)
            %returns functionHandles for retieving.
            output = obj.PROCESSING_INFO(:,3);
        end
    end
    
    %Constructor  =========================================================
    methods
        function obj = auto_logger(parent)
            %
            %   obj = auto_logger(parent)
            
            obj@NEURON.logger(parent);
            
            %Reload objects ----------------
            obj.loadLog();
        end
    end
    
    %Property Processing Methods ==========================================
    methods
        %PROPERTY RETRIEVAL   =============================================
        function new_value = getNewValue(obj,prop_name,retrieval_method)
            %
            %    new_value = getNewValue(obj,prop_name,retrieval_method)
            %
            %    Retrieves the current property value of an object and
            %    convert it to a form suitable for logging.
            %
            %    INPUTS
            %    ===========================================================
            %    prop_name : (char) name of the property to retrieve from
            %            the parent
            %    retrieval_method : One of 3 types
            %            See definition of PROCESSING_INFO
            %
            %    See Also:
            %    
            %
            %    IMPROVEMENTS:
            %    ==========================================================
            %    1) On loading the processing info we could resolve all
            %    of the instructions to function handles
            %
            %    FULL PATH
            %    ==========================================================
            %    NEURON.logger.auto_logger.getNewValue
            
            parent      = obj.parent;
            is_singular = obj.IS_SINGULAR_OBJECT;
            
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
                    case 'varying'
                        %In this case the 
                        if ~is_singular
                            n_objs = length(parent);
                            
                            temp_data = {parent.(prop_name)};
                            sizes     = cellfun('length',temp_data);                            
                            new_value = [n_objs sizes temp_data{:}];

%                             new_value   = n_objs;
%                             temp_val    = [];
%                             sizes       = [];
%                             for i_obj = 1:n_objs
%                                 temp = parent(i_obj).(prop_name);
%                                 sizes = [sizes, length(temp)];      %#ok
%                                 temp_val = [temp_val, temp];        %#ok
%                             end
%                             new_value = [new_value, sizes, temp_val];
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
                new_value = feval(retrieval_method,obj,parent,prop_name);
                %new_value = obj.retrieval_method(parent, prop_name);
            end
        end
    end
    
    %Implementation of Abstract Methods ===================================
    methods
        %find -> see separate file
    end
    
    %Save and Load Functionality===========================================
    methods
        function saveLog(obj)
            s = struct;
            s.old_values = obj.old_values;
            obj.addPropsAndSave(s);
        end
        function loadLog(obj)
            s = obj.getStructure();
            if isempty(s)
               %Initialization of old values
               propNames = obj.getPropNames();
               obj.old_values = cell2struct(repmat({[]},[length(propNames) 1]),propNames);
            else
               obj.old_values = s.old_values;
            end
        end
    end
end

