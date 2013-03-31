classdef cmd < handle_light
    %
    %   CLASS: NEURON.cmd
    %
    %   Class to house NEURON commands with better wrappers.
    %   Most commands should go through here.
    
    properties (Hidden)
        comm_obj        %Class: Implementation of NEURON.comm_obj
        cmd_log_obj     %Class: NEURON.command_log
    end
    
    properties
        options     %Class: NEURON.cmd.options
    end
    
    properties
        last_command_str %Set during write in case there is an error,
        %the user can see what the last error was.
    end
    
    %Constructor  ----------------------------------------------
    methods (Hidden)
        function obj = cmd(paths_obj,cmd_log_obj,cmd_options)
            %cmd
            %
            %  obj = cmd(paths_obj,cmd_log_obj,cmd_options)
            %
            %  This method should be called by the NEURON constructor.
            
            obj.options     = cmd_options;
            obj.cmd_log_obj = cmd_log_obj;
            
            %Load communication object based on system type
            %--------------------------------------------------------------
            if ispc
                if cmd_options.win_use_java
                    obj.comm_obj = NEURON.comm_obj.java_comm_obj(paths_obj);
                else
                    obj.comm_obj = NEURON.comm_obj.windows_comm_obj(paths_obj);
                end
            else
                obj.comm_obj = NEURON.comm_obj.java_comm_obj(obj.path_obj);
            end
        end
    end
    
    %Generic ==============================================================
    methods (Hidden)
        function varargout = write(obj,command_str,varargin)
            %write  Writes a command to the NEURON process
            %
            %   [success,results] = write(obj,command_str,varargin)
            %
            %   This method is THE gateway method for communicating with
            %   NEURON. This method calls the communication object to send
            %   a message to NEURON and to get the response.
            %
            %   Further documentation of inputs and outputs is given in the
            %   public facing method:
            %       NEURON.cmd.run_command
            
            opt = obj.options;
            in.throw_error = opt.throw_error;
            in.debug       = opt.debug;
            in.max_wait    = opt.max_wait;
            in = processVarargin(in,varargin);
            
            obj.last_command_str = command_str;
            
            if in.debug
                fprintf('COMMAND: %s\n',command_str);
            end
            
            %NEURON.comm_obj.java_comm_obj.write
            %NEURON.comm_obj.windows_comm_obj.write
            [success,result_str] = write(obj.comm_obj,command_str,in);
            
            if opt.log_commands
                obj.command_log_obj.addCommand(command_str,result_str,success);
            end
            
            %Error Handling and Interactive Display Handling
            %--------------------------------------------------------------
            if ~success && in.throw_error
                %Let user know what caused the error
                fprintf(2,'LAST COMMAND:\n%s\n',command_str);
                if opt.interactive_mode
                    %If we're in interactive mode don't bring
                    %the error into here, just display it in the command
                    %window
                    fprintf(2,'%s\n',result_str);
                else
                    %This could be throw as caller but that is pretty
                    %much a useless Matlab function anyway
                    %http://blogs.mathworks.com/loren/2007/04/30/a-little-bit-on-message-handling/
                    %See comments 9 & 10
                    %MException/throwAsCaller
                    error('ERROR FROM NEURON:\n%s',result_str)
                end
            elseif opt.interactive_mode && ~isempty(result_str)
                %When in interactive mode and no error is present
                fprintf('%s\n',result_str);
            end
            
            %This cleans things up a bit during interactive mode
            %where the command line color will indicate success or failure.
            %We don't also need the success flag to show up
            if nargout
                varargout{1} = success;
                varargout{2} = result_str;
            end
        end
    end
    
    methods
        function varargout = run_command(obj,str,varargin)
            %run_command Runs commands in NEURON and returns the result
            %
            %    [flag,results] = run_command(obj,str,varargin)
            %
            %    Generic method to run command in NEURON.
            %
            %    INPUTS
            %    ===========================================================
            %    str : command to run
            %
            %    OUPUTS
            %    ===========================================================
            %    flag    : Indicates success (true) or not (false). Success
            %        is based upon whether or not NEURON throws an error.
            %        Some commands will fail, as indicated by their
            %        response, but will not throw an error.
            %    results : String of response from NEURON program.
            %
            %    OPTIONAL INPUTS
            %    ===========================================================
            %    Documentation for these properties can be found in:
            %    NEURON.cmd.options
            %    - debug
            %    - max_wait
            %    - throw_error
            %
            %    See Also:
            %        NEURON.cmd.write
            
            %This doesn't work ...
            %varargout = obj.write(str,varargin{:});
            if nargout
                [varargout{1},varargout{2}] = obj.write(str,varargin{:});
            else
                obj.write(str,varargin{:});
            end
        end
        function success = writeNumericProps(obj,props,values)
            %
            %    success = writeNumericProps(obj,props,values)
            %
            %    INPUTS
            %    ===========================================================
            %    props  : (cellstr)
            %    values : cell array of numeric values
            
            value_strings = cellfun(@(x) sprintf('%0g',x),values,'un',0);
            
            str = ['{' strtools.propsValuesToStr(props,value_strings) '}'];
            
            success = obj.write(str);
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
            
            [success,results] = obj.write(str);
        end
    end
    
    %Path/File Related =============================================
    methods
        function [success,results] = load_file(obj,file_path,reload_file)
            %load_file
            %
            %   [success,results] = load_file(obj,file_path,*reload_file)
            %
            %   INPUTS
            %   ===========================================================
            %   file_path : Relative paths are fine and are referenced to
            %   the current directory first, followed by different
            %   environment variables. When not in the current directory it
            %   is recommended to use full paths. For windows cygwin paths
            %   types are needed.
            %
            %   OPTIONAL INPUTS
            %   ===========================================================
            %   reload_file : (default true), if true the file is reloaded.
            %   This is useful when changing variables in a script. In
            %   general false should never be used as it implies not
            %   knowing whether or not we've already called the function,
            %   which we should know. When false, if the file has
            %   previously been loaded, it won't be loaded again.
            %
            %   NEURON COMMAND - load_file
            %   ===========================================================
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/ocfunc.html#load_file
            %
            
            if ~exist('reload_file','var')
                reload_file = true;
            end
            
            if reload_file
                load_cmd = sprintf('{load_file(1,"%s")}',file_path);
            else
                load_cmd = sprintf('{load_file("%s")}',file_path);
            end
            
            [flag,results] = obj.write(load_cmd);
            
            %Results are quite messy, nothing to intepret.
            success = flag;
        end
        function success = load_dll(obj,dll_path)
            %load_dll
            %
            %    success = load_dll(obj,dll_path)
            %
            %    NEURON COMMAND - nrn_load_dll
            %    =============================================================
            %    http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/system.html#nrn_load_dll
            
            
            load_cmd = sprintf('{nrn_load_dll("%s")}',dll_path);
            [flag,~] = obj.write(load_cmd);
            
            success = flag;
        end
        function success = load_standard_dll(obj)
            %success
            %
            %    success = load_standard_dll(obj)
            %
            %   This method can be used to load the standard dll or
            %   library. It provides system dependent pathing to this file.
            %   Windows: nrnmech.dll
            %   Mac    : libnrnmech.so
            %
            %   See Also:
            %       NEURON.cmd.load_dll
            
            %NOTE: This might eventually need some modifications for the mac
            %build. I'm a bit surprised the shared object is nested so deep.
            %It might be possible to simplify this with changes to the
            %compile command.
            
            if ispc
                success = obj.load_dll('mod_files/nrnmech.dll');
            elseif ismac
                success = obj.load_dll('mod_files/i386/.libs/libnrnmech.so');
            else
                error('Non-Mac Unix systems are not yet supported.')
            end
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
            %   OPTIONAL INPUTS
            %   ===========================================================
            %
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
            [flag,results] = obj.write(start_dir_cmd);
            
            %chdir => -1, failed
            %NOTE: For 0, it prints [tab 0 space] => ' 0 '
            %I'm not sure why it does this but str2double() works
            
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
            
            
            [success,cur_dir] = obj.write('getcwd()');
        end
        % % %         function success = init_and_set_str(obj,name,value)
        % % %            %
        % % %            %  This function would declarat a string
        % % %            %  and set it ...
        % % %         end
    end
    
    %Extract Data From Neuron =============================================
    methods
        function numeric_value = getScalar(obj,scalar_name)
            [~,results]   = obj.write(scalar_name);
            numeric_value = str2double(results);
        end
    end
    
    methods (Static)
        
        data = loadMatrix(filePath)
    end
    
end

