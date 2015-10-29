classdef inspector < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.inspector
    %
    %   The idea behind this class was to create a set of tools for
    %   inspecting definitions in NEURON
    %
    %   STATUS:
    %   Not yet finished ..., see notes_on_outputs
    %
    %   Neuron Commands to Inspect:
    %   ====================================================
    %   allobjects()
    %   allobjects(type)
    %   allobjectvars()
    
    
    %Other methods
    %- get value of scalar
    %- show scalar values - call to update, then request values
    %- explore - cast instance of variable to class
    %
    %   NEURON.list
    %   NEURON.secionlist
    
    properties (Hidden)
        cmd %Class: NEURON.cmd
    end
    
    properties (SetAccess = private)
        user_procedures  %(cellstr), list of user defined procedures
        user_scalars     %(cellstr), list of user defined scalars
    end
    
    properties (SetAccess = private)
        default_procedures = {}
        default_scalars    = {}
    end
    
    methods (Hidden)
        function obj = inspector(cmd_obj)
            %
            %
            %    obj = inspector(cmd_obj)
            
            obj.cmd = cmd_obj;
            
            obj.symbols(true);
        end
    end
    
    methods
        function update(obj)
            %update
            %
            %   update(obj)
            %
            %   This method should be called to update the properties of
            %   the class to match the current reality in NEURON
            
            symbols(obj,false)
        end
    end
    
    methods (Hidden)
        function symbols(obj,is_init)
            %symbols
            %
            %   symbols(obj,is_init)
            %
            %   Populates Properties
            %   ===========================================================
            %   default_procedures
            %   default_scalars
            %
            %    FULL PATH:
            %    NEURON.inspector.symbols
            
            [~,str] = obj.cmd.run_command('{symbols()}');
            str2 = regexp(str,'\n','split');
            
            I_P = find(strcmpi(str2,'Procedures'),1);
            I_S = find(strcmpi(str2,'Scalars'),1);
            
            if isempty(I_P) || isempty(I_S)
                fprintf(2,'Unable to find procedures or scalars in NEURON.inspector.symbobls\n');
                return
            end
            
            procedures = regexp(str2{I_P + 1},'\t','split')';
            scalars    = regexp(str2{I_S + 1},'\t','split')';
            
            procedures(cellfun('isempty',procedures)) = [];
            scalars(cellfun('isempty',scalars)) = [];
            
            if is_init
                obj.default_procedures = procedures;
                obj.default_scalars    = scalars;
            else
                obj.user_procedures    = setdiff(procedures,obj.default_procedures);
                obj.user_scalars       = setdiff(scalars,obj.default_scalars);
            end
        end
    end
    
end

