classdef processor < sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.logger.auto_logger.processor
    
    
    %==================================================================
    %3 Column cell array
    %
    %   COLUMN 1: property name to log
    %
    %   NOTE: The property name in the parent will also match the name
    %   of the property in the logger class. By ensuring no name
    %   collision of properties in the parent we can guaranteee no name
    %   collision of properties in the logger class. For example, the
    %   property 'xyz' in the parent will indicate the current value of
    %   that object instance. In the logger, we dynamically create a
    %   property 'xyz' which will hold all PREVIOUS xyz values that
    %   have been "logged"
    %
    %   COLUMN 2: comparison type
    %
    %   This column provides instructions on how to compare and treat
    %   the old data. This is needed when 1) comparing new to old data
    %   and 2) when adding the new data to the old data.
    %
    %       VALID OPTIONS ARE:
    %           - scalarInt - use this for scalars that are specified
    %                   as integers, usually for enumerated values ...
    %           - scalarFP  - for scalars that can take on floating
    %                   point values
    %           - vectorFP  - for variables which are vectors of a
    %               fixed length. It is an error to have this for a
    %               non-singular object. TODO: We could handle this in
    %               the class
    %                 IMPORTANT ASSUMPTIONS:
    %                 1) All vectors are row vectors
    %                 2) Matrices are not supported
    %           - cellFP    - Varying lengths of matrices
    %
    %   COLUMN 3: Method of data retrieval from the parent
    %
    %       1 - '', specifies direct retrieval by property name
    %
    %       2 - (char), predefined strings
    %           : 'numeric' - specifies horizontal concatenation of
    %           numbers
    %           : ????
    %       3 - (function handle), a function handle can be passed in
    %       to allow any processing of variable. PROTOTYPE:
    %
    %       example: @myLocalFunction
    %
    %       new_value = myLocalFunction(obj,p,prop_name)
    %
    %       INPUTS
    %       -----------------------------------------------------------
    %       obj       : Class: subclass of logger
    %       p         : reference to parent (loggable class) (might delete this)
    %       prop_name : (char) Name of the property to retrieve
    %
    
    %See documentation on these props above ...
    properties
        prop_names
        type_names
        retrieval_methods
        parent
        is_singular
    end
    
    methods
        function obj = processor(parent,is_singular,AUTO_INFO)
            
        end
    end
    
end

