classdef cmd < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %   NEURON.cmd
    %
    %   Class to house NEURON commands with better wrappers.
    %   Most commands should go through here.
    %
    %   This class holds onto a communication object which is able to 
    %   communicate with the NEURON process.
    
    properties (Hidden)
        comm_obj %Class: Implementation of NEURON.comm_obj
        %
        %   At one point I had tried a .NET implementation but
        %   I then settled on a Java implementation.
        %
        %       NEURON.comm_obj.java_comm_obj
        
        log      %Class: NEURON.command_log
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
        function obj = cmd(cmd_options)
            %cmd
            %
            %   obj = cmd(cmd_options)
            %
            %   Inputs
            %   ------
            %   cmd_options : NEURON.cmd.options
            %
            %  This method should be called by:
            %  NEURON.simulation
            
            obj.options     = cmd_options;
            obj.log = NEURON.cmd.log;
            
            %Load communication object
            obj.comm_obj = NEURON.comm_obj.java_comm_obj();
            
            %This is a hack around the following error:
            if ispc
                obj.cd_set('C:\',false);
            else
                %obj.cd_set('/Users',false)
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
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            obj.last_command_str = command_str;
            
            if in.debug
                fprintf('COMMAND: %s\n',command_str);
            end
            
            %NEURON.comm_obj.java_comm_obj.write
            %NEURON.comm_obj.windows_comm_obj.write
            [success,result_str] = write(obj.comm_obj,command_str,in);
            
            if opt.log_commands
                obj.log.addCommand(command_str,result_str,success);
            end
            
            %Error Handling and Interactive Display Handling
            %--------------------------------------------------------------
            if ~success && length(result_str) > 14 && strcmp(result_str(1:14),'cygwin warning')
               %This is a hack placed in because apparently now cygwin
               %doesn't transform paths when retrieved as environment
               %variables and thus throws a warning
               %
               %Alternative Approach:
               %http://auxmem.com/2010/03/17/how-to-squelch-the-cygwin-dos-path-warning/
                   fprintf(2,'CYGWIN WARNING DETECTED\n-----------------------\n%s\n\n',result_str);
               success = 1;
            end
            
            if ~success && in.throw_error
                %Let user know what caused the error
                fprintf(2,'LAST COMMAND:\n%s\n\n',command_str);
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
                    %
                    %
                    %   Common Errors
                    %   -------------
                    %   - <string> is not a mechanism
                    %       This requires that the mechanism be recompiled.
                    %       Finding the the correct directory can be a bit
                    %       difficult and is based on the model being run.
                    %       For example, I often get "axnode" is not a
                    %       MECHANISM for the MRG model. 
                    %       TODO: allow specification of the cell model
                    %       and compiling based on that ...
                    %       -- I also found out that my code had an error
                    %       and was trying to load i386 instead of the
                    %       x86_64 bit, hopefully this is fixed now ...
                    %
                    %   
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
            
            str = ['{' h__propsValuesToStr(props,value_strings) '}'];
            
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
            
            str = ['{' h__propsValuesToStr(props,value_strings) '}'];
            
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
            %   Inputs
            %   ------
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
            %    -----------------------------
            %    http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/system.html#nrn_load_dll
            %
            %   See Also
            %   --------
            %   load_standard_dll
            
            %My question on not getting an error
            %https://www.neuron.yale.edu/phpBB/viewtopic.php?t=2558
            %
            %Ted clarifying how brackets works ...
            %https://www.neuron.yale.edu/phpBB/viewtopic.php?f=8&t=3604&p=15316&hilit=brackets#p15316
            
            %
            load_cmd = sprintf('nrn_load_dll("%s")',dll_path);
            [~,results] = obj.write(load_cmd);
            
            trimmed = strtrim(results);
            
            success = ~strcmp(trimmed,'0');
            
            if ~success && obj.options.throw_error
                cur_dir = obj.cd_get();
                error('Failed to load %s from %s',dll_path,cur_dir);
            end
        end
        function success = load_standard_dll(obj)
            %success
            %
            %    success = load_standard_dll(obj)
            %
            %   This method can be used to load the standard dll or
            %   library. It provides system dependent pathing to this file.
            %
            %   Note, by convention the dll must be located in the
            %   'mod_files' directory of the model. This workflow assumes
            %   all relevant mod files have been compiled into one
            %   directory.
            %
            %   Windows: nrnmech.dll
            %   Mac    : libnrnmech.so
            %
            %   See Also
            %   --------
            %   load_dll
            
            %NOTE: This might eventually need some modifications for the mac
            %build. I'm a bit surprised the shared object is nested so deep.
            %It might be possible to simplify this with changes to the
            %compile command.
            
            
            
            if ispc
                success = obj.load_dll('mod_files/nrnmech.dll');
            elseif ismac
                %This could be removed if we moved the file after
                %compiling.
                root = obj.cd_get();
                dll_path_64_partial = 'mod_files/x86_64/.libs/libnrnmech.so';
                dll_path_64_full = fullfile(root,dll_path_64_partial);
                if exist(dll_path_64_full,'file')
                    success = obj.load_dll(dll_path_64_partial);
                else
                    success = obj.load_dll('mod_files/i386/.libs/libnrnmech.so');
                end
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
            
            start_dir_cmd  = sprintf('chdir("%s")',NEURON.s.createNeuronPath(new_dir));
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
        %NEURON.cmd.loadMatrix
        data = loadMatrix(filePath)
    end
end


function str = h__propsValuesToStr(props,values,varargin)
%propsValuesToStr
%
%   str = strtools.propsValuesToStr(props,values,varargin)
%
%   OPTIONAL INPUTS
%   ================================================
%   prop_value_delimiter  : (default '=')
%   pair_delimiter        : (default ' ')
%
%   NOTE: Currently both delimiters are treated as literals and are not
%   intepreted ...
%
%   EXAMPLE
%   ====================================================
%   str = strtools.propsValuesToStr({'aasd','best'},{'123' 'asdfset1asdfasdf'})
%   aasd=123 best=asdfset1asdfasdf

%INPUT HANDLING
%=============================================
if ischar(props)
    props = {props};
end

if ischar(values)
    values = {values};
end

if ~iscellstr(props) || ~iscellstr(values)
    error('Both inputs must be cell arrays of strings')
end

%NOTE: These are not processed ...
in.prop_value_delimiter = '=';
in.pair_delimiter = ' ';
in = NEURON.sl.in.processVarargin(in,varargin);

%Initialization of the length
%========================================================
prop_lengths  = cellfun('length',props);
value_lengths = cellfun('length',values);
pv_delim_l    = length(in.prop_value_delimiter);
p_delim_l     = length(in.pair_delimiter);

nPairs = length(props);

if nPairs ~= length(values);
    error('Properties and Values must match in length\n%d Props Observed, %d Values Observed',...
        nPairs,length(values))
end

delimSpace = pv_delim_l*(nPairs) + p_delim_l*(nPairs-1);

%Initialization ----------------------------
str = blanks(delimSpace + sum(prop_lengths) + sum(value_lengths));
curIndex = 0;


%To avoid structure indexing in a loop :/
prop_value_delimiter = in.prop_value_delimiter;
pair_delimiter       = in.pair_delimiter;

for iProp = 1:nPairs
    str(curIndex+1:curIndex+prop_lengths(iProp)) = props{iProp};
    curIndex = curIndex + prop_lengths(iProp);
    
    str(curIndex+1:curIndex+pv_delim_l) = prop_value_delimiter;
    curIndex = curIndex + pv_delim_l;
    
    str(curIndex+1:curIndex+value_lengths(iProp)) = values{iProp};
    
    %NOTE: We don't want to added on a pair delimiter for the last value
    %...
    if iProp ~= nPairs
        curIndex = curIndex + value_lengths(iProp);
        str(curIndex+1:curIndex + p_delim_l) = pair_delimiter;
        curIndex = curIndex + p_delim_l;
    end
end

end
