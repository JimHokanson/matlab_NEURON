classdef cmd
    %
    %
    %   CLASS: NEURON.cmd
    %
    %   NOTE: This is not a handle class ...
    %
    %   Class to house NEURON commands with better wrappers.
    %   Ideally most commands would go through here ...
    
    properties (Hidden)
        comm_obj    %Class: NEURON
    end
    
    properties (Constant)
        %VAR_REGEXP_GEN  = '#var#.*?#.*?#'
        VAR_REGEXP_SPEC = '#var#%s#(.*?)#'
    end
    
    methods (Hidden)
        function obj = cmd(comm_obj)
            obj.comm_obj = comm_obj;
        end
    end
    
    %Generic ==============================================================
    methods
       function [flag,results] = run_command(obj,str,varargin)
           %run_command Runs commands in NEURON and returns the result
           %
           %    [flag,results] = run_command(obj,str,varargin)
           %
           %    Generic method to run command
           %
           %    INPUTS
           %    =================================================
           %    str : command to run
           %
           %    OPTIONAL INPUTS
           %    ===========================================================
           %    See: NEURON.write
           
           [flag,results] = obj.comm_obj.write(str,varargin{:});
       end
       function success = writeNumericProps(obj,props,values)
           %
           %    success = writeNumericProps(obj,props,values)
           %
           
           value_strings = cellfun(@(x) sprintf('%0g',x),values,'un',0); 
            
           str = ['{' strtools.propsValuesToStr(props,value_strings) '}'];
            
           success = obj.comm_obj.write(str);  
       end
       function [success,results] = writeStringProps(obj,props,values)
           %
           %    [success,results] = writeStringProps(obj,props,values)
           %
           %    NOTE: strings must have been previously defined using strdef in
           %    NEURON - TODO: Implement strdef method 
           %    strdef a,b,c,d - defines strings a - d
           
           %Add on quotes to strings
           value_strings = cellfun(@(x) sprintf('"%s"',x),values,'un',0); 
            
           str = ['{' strtools.propsValuesToStr(props,value_strings) '}'];
            
           [success,results] = obj.comm_obj.write(str);
       end
    end
    
    %Path/File Related =============================================
    methods
        function [success,results] = load_file(obj,file_path)
            %NEW VERSION: load_file(sim_obj,file_path)
            %
            %   load_file
            %
            %   NEURON COMMAND - load_file
            %   ===========================================================
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/ocfunc.html#load_file
            
            load_cmd = sprintf('{load_file("%s")}',file_path);
            
            [flag,results] = obj.comm_obj.write(load_cmd);
            %[flag,~] = write(interface_obj,load_cmd);
            
            %JAH NOTE: results are quite messy
            %Nothing to interpret
            success = flag;
        end
        function success = load_dll(obj,dll_path)
           %
           %
           %    success = load_dll(obj,dll_path)
           %
           %    NEURON COMMAND - nrn_load_dll
           %    =============================================================
           %    http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/system.html#nrn_load_dll

            
           load_cmd = sprintf('{nrn_load_dll("%s")}',dll_path); 
           [flag,~] = obj.comm_obj.write(load_cmd);
           
           %As of right now, it doesn't seem like the results are
           %meaningful ..., unlike cd_set
           
           success = flag;
        end
        function success = cd_set(obj,new_dir,throw_error)
            %cd_set  Wrapper for NEURON function that accomplishes cd() set functionality
            %
            %   NOTE: Normally in Matlab, cd peforms both set and get
            %   functionality. I wanted to make things a bit clearer so
            %   this function changes the current directory. A 
            %   
            %   success = cd_set(obj,new_dir,*throw_error) Change to a new directory
            %
            %   INPUTS
            %   ===========================================================
            %   new_dir : path, absolute or relative should be fine ...
            %
            %   NEURON COMMAND - chdir
            %   ===========================================================
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/0fun.html#chdir
            %
            %   See Also:
            
            if ~exist('throw_error','var')
                throw_error = true;
            end
            
            start_dir_cmd  = sprintf('chdir("%s")',NEURON.createNeuronPath(new_dir));
            [flag,results] = obj.comm_obj.write(start_dir_cmd);
            
            %chdir => -1, failed
            %NOTE: For 0, it prints [tab 0 space] => ' 0 ' 
            %I'm not sure why it does this but str2double works
            
            numeric_result = str2double(results);
            
            success = flag && numeric_result == 0;
            if ~success && throw_error
                if numeric_result == -1
                    error('Failed to change directory to "%s"',new_dir)
                else
                    error('System error, write/read cycle failed')
                end
            end
            
        end
        function [cur_dir,success] = cd_get(obj)
            %cd_set Wrapper for NEURON function that accomplishes cd() get functionality
            %
            %   [cur_dir,success] = cd_get(obj)
            %
            %   NEURON COMMAND
            %   ====================================
            %   getcwd
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/0fun.html#getcwd

            
           [success,cur_dir] = obj.comm_obj.write('getcwd()'); 
        end
% % %         function success = init_and_set_str(obj,name,value)
% % %            %
% % %            %    
% % %            %
% % %         end
    end

    %Extract Data From Neuron =============================================
    methods 
        function output = extractSingleParam(obj,str,param)
           pat  = sprintf(obj.VAR_REGEXP_SPEC,param);
           temp = regexp(str,pat,'tokens','once');
           
           %NOTE: might need to handle empty ...
           output = temp{1};
        end
%         function extractParams(obj,str,single_match)
%             if ~exist('single_match','var')
%                 single_match = false;
%             end
%             
%             if single_match
%                 temp =  
%         end
    end
    
    %Extract Data From Neuron =============================================
    methods (Static)
        data = loadMatrix(filePath)
    end
    
end

