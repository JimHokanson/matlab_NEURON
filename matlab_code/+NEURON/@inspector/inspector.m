classdef inspector < handle_light
    %
    %   Class:
    %   NEURON.inspector
    %
    %   The idea behind this class was to create a set of tools for
    %   inspecting definitions in NEURON
    %
    %   Known Functions:
    %   ---------------------------
    %   allobjects
    %
    %   [~,str] = c.run_command('allobjects()');
    %   Example Output:
    %   --------------------------------
    % SectionList[0] with 1 refs
    % SectionList[1] with 1 refs
    % StringFunctions[0] with 1 refs
    % List[0] with 1 refs
    % List[1] with 1 refs
    % List[2] with 1 refs
    % List[3] with 1 refs
    % List[4] with 1 refs
    % List[5] with 1 refs
    % List[6] with 1 refs
    % List[7] with 1 refs
    % Vector[0] with 1 refs
    % Vector[1] with 1 refs
    % CVode[0] with 2 refs
    % NumericalMethodPanel[0] with 2 refs
    % 0
    %   [~,str] = c.run_command('allobjects("SectionList")');
    %   SectionList[0] with 1 refs
    %   SectionList[1] with 1 refs
    %   0
    %
    %[~,str] = c.run_command('allobjectvars()');
    %obp hoc_obj_[0] -> NULL
    % obp hoc_obj_[1] -> NULL
    % obp hoc_sf_[0] -> StringFunctions[0] with 1 refs.
    % obp clipboard_file[0] -> NULL
    % obp clipboard_file[1] -> NULL
    % obp tempobj[0] -> NULL
    % obp cvode[0] -> CVode[0] with 2 refs.
    % obp movie_timer[0] -> NULL
    % obp movierunbox[0] -> NULL
    % obp tobj[0] -> NULL
    % obp tobj1[0] -> NULL
    % obp nrnmainmenu_[0] -> NULL
    % obp numericalmethodpanel[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp atoltool_[0] -> NULL
    %    obp b1[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp b[0] -> NULL
    %    obp this[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp cvode[0] -> CVode[0] with 2 refs.
    % obp graphList[0] -> List[0] with 1 refs.
    % obp graphList[1] -> List[1] with 1 refs.
    % obp graphList[2] -> List[2] with 1 refs.
    % obp graphList[3] -> List[3] with 1 refs.
    % obp graphItem[0] -> NULL
    % obp flush_list[0] -> List[4] with 1 refs.
    % obp fast_flush_list[0] -> List[5] with 1 refs.
    % obp tempobj2[0] -> NULL
    % obp xstim__all_sectionlist[0] -> SectionList[0] with 1 refs.
    % obp xstim__node_sectionlist[0] -> SectionList[1] with 1 refs.
    % obp xstim__stim_vector_list[0] -> List[7] with 1 refs.
    % obp xstim__v_ext_in[0] -> Vector[0] with 1 refs.
    % obp xstim__t_vec[0] -> Vector[1] with 1 refs.
    % obp xstim__node_vm_hist[0] -> List[8] with 1 refs.
    % 	0
    %
    %
    %   objref scobj
    %   scobj = new SymChooser()
    %   scobj.run()
    %
    
    %Other methods
    %- get value of scalar
    %- show scalar values - call to update, then request values
    %- explore - cast instance of variable to class
    
    properties (Hidden)
        cmd_obj %Class: NEURON.cmd
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
            
            obj.cmd_obj = cmd_obj;
            
            symbols(obj,true)
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
            %
            %
            %    FULL PATH:
            %        NEURON.inspector.symbols
            
            [~,str] = obj.cmd_obj.run_command('{symbols()}');
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

