classdef cmd < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %   NEURON.cmd
    %
    %   This class is the gateway for sending commands to NEURON. It also
    %   holds methods that represent calls to NEURON commands.
    %
    %   Example Usage
    %   -------------
    %   options = NEURON.cmd.options;
    %   options.debug = true;
    %   options.log_commands = true;
    %   cmd = NEURON.cmd(options);
    %   version_str = cmd.version(1)
    %   cmd.run_command('a = 1 + 1')
    %   cmd.run_command('print a')
    %   cmd.log.command_history
    %
    %   See Also
    %   --------
    %   NEURON.simulation
    
    
    %   Old documentation:
    %   https://neuron.yale.edu/neuron/static/docs/help/
    
    properties (Hidden)
        comm_obj %Class: Implementation of NEURON.comm_obj
        %
        %   At one point I had tried a .NET implementation but
        %   I then settled on a Java implementation.
        %
        %       NEURON.comm_obj.java_comm_obj
    end
    
    properties
        options %NEURON.cmd.options
    end
    
    properties
        last_command_str %Set during write in case there is an error,
        %the user can see what the last error was.
        
        log %NEURON.cmd.log
        launch_duration
    end
    
    %Constructor  ----------------------------------------------
    methods (Hidden)
        function obj = cmd(cmd_options)
            %cmd
            %
            %   obj = NEURON.cmd(*cmd_options)
            %
            %   Inputs
            %   ------
            %   cmd_options : NEURON.cmd.options
            %       Further documentaton is inside that class.
            %
            %  This method should be called by:
            %  NEURON.simulation
            
            if nargin
                obj.options = cmd_options;
            else
                obj.options = NEURON.cmd.options();
            end
            
            opt = obj.options;
            
            if opt.log_commands
                obj.log = NEURON.cmd.log;
            end
            
            %Load communication object
            h_tic = tic;
            obj.comm_obj = NEURON.comm_obj.java_comm_obj();
            obj.launch_duration = toc(h_tic);
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
            %   a message to NEURON and then waits for the response.
            %
            %   User should call run_command() instead. Basically
            %   run_command just sounds nicer but calls this.
            %
            %   Outputs
            %   -------
            %   success : logical
            %       This only indicates that something didn't go horribly
            %       wrong. It is still possible that the command didn't
            %       work.
            %   results : string
            %       This is the reply message sent to NEURON. It may
            %       contain additional information that is needed to
            %       determine if the command actually ran as desired.
            %
            %   Further documentation of inputs and outputs is given in the
            %   public facing method:
            %       NEURON.cmd.run_command
            %
            %   See Also
            %   --------
            %   run_command
            
            opt = obj.options;
            in.throw_error = opt.throw_error;
            in.debug       = opt.debug;
            in.max_wait    = opt.max_wait;
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            obj.last_command_str = command_str;
            
            if in.debug
                fprintf('   COMMAND: %s\n',command_str);
                fprintf('  RESPONSE:\n'); 
            end
            
          	if opt.log_commands
                obj.log.initCommand(command_str);
            end
            
            %NEURON.comm_obj.java_comm_obj.write
            %TODO: I don't like that the comm obj is printing
            %- that should be done here ...
            [success,result_str] = obj.comm_obj.write(command_str,in);
            
            if opt.log_commands
                obj.log.terminateCommand(result_str,success);
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
                    %This could be thrown as caller but that is pretty
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
                    %       see: NEURON.s.compile
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
            %    Generic method to run a command in NEURON. In general
            %    I'm trying to get away from this because it requires the
            %    user to handle the results. Instead I'm building the
            %    NEURON commands as methods in this class.
            %
            %    Inputs
            %    ------
            %    str : string
            %       Command to run
            %
            %    Outputs
            %    -------
            %    flag : logical
            %       Indicates success (true) or not (false). Success
            %        is based upon whether or not NEURON throws an error.
            %        Some commands will fail, as indicated by their
            %        response, but will not throw an error.
            %    results : string
            %       String of response from NEURON program.
            %
            %    Optional Inputs
            %    ---------------
            %    Documentation for these properties can be found in:
            %    NEURON.cmd.options
            %    - debug
            %    - max_wait
            %    - throw_error
            %
            %   Example
            %   -------
            %   
            
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
        function success = xopen(obj,path_string)
            %
            %
            %   success = xopen(obj,path_string)
            %
            %   Example
            %   -------
            %   cmd.xopen('$(NEURONHOME)/lib/hoc/noload.hoc');

            %
            %   https://www.neuron.yale.edu/neuron/static/py_doc/programming/io/file.html#xopen
            %   https://www.neuron.yale.edu/neuron/static/py_doc/programming/io/ropen.html#xopen
            
            %cmd.run_command('xopen("$(NEURONHOME)/lib/hoc/noload.hoc")')
            
            xopen_cmd = sprintf('xopen("%s")',path_string);
            [~,results] = obj.write(xopen_cmd);
            
            %   Returns
            %   -------
            %   '' => failure
            %   1  => success
            %   1) 
            
            
            success = ~isempty(any(results == '1'));
            if ~success
                error('Call to xopen failed')
            end
            
        end
        function [success,results] = load_file(obj,file_path,reload_file)
            %load_file
            %
            %   [success,results] = load_file(obj,file_path,*reload_file)
            %
            %   Inputs
            %   ------
            %   file_path : 
            %       Relative paths are fine and are referenced to the
            %       current directory first, followed by different
            %       environment variables. When not in the current
            %       directory it is recommended to use full paths. For
            %       windows cygwin paths types are needed.
            %
            %   Optional Inputs
            %   ---------------
            %   reload_file : (default true)
            %       If true the file is reloaded. This is useful when
            %       changing variables in a script. In general false should
            %       never be used as it implies not knowing whether or not
            %       we've already called the function, which we should
            %       know. When false, if the file has previously been
            %       loaded, it won't be loaded again.
            %
            %   NEURON COMMAND: load_file()
            %   ---------------------------
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
            %   success = load_dll(obj,dll_path)
            %
            %   NEURON COMMAND - nrn_load_dll
            %   -----------------------------
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/system.html#nrn_load_dll
            %
            %   1 - success
            %   0 - failure
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
                temp_path = fullfile(cur_dir,dll_path);
                if ~exist(temp_path,'file')
                    error('Failed to load %s from %s, file doesn''t exist',dll_path,cur_dir);
                else
                    error('Failed to load %s from %s, even though file exists',dll_path,cur_dir);
                end
                %   Possible Fix
                %   ---------------------
                %   NEURON.s.compile(model_name)
                %   %e.g.
                %   NEURON.s.compile('mrg')
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
            %   
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
            %   Inputs
            %   ------
            %   new_dir : path
            %       Absolute or relative should be fine ...
            %
            %   Optional Inputs
            %   ----------------
            %
            %
            %   NEURON COMMAND - chdir
            %   ----------------------
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/0fun.html#chdir
            %
            %   0 - success
            %   -1 - failure
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
        function version_str = version(obj,type)
            %
            %   Input:
            %   -----
            %   type : scalar
            %       See below for examples
            %
            %   nrnversion()
            %   https://www.neuron.yale.edu/neuron/static/new_doc/programming/system.html?highlight=version#nrnversion
            %
            % oc>for i=0,6 print i,": ", nrnversion(i)
            % 0 : 7.1
            % 1 : NEURON -- VERSION 7.1 (296:ff4976021aae) 2009-02-27
            % 2 : VERSION 7.1 (296:ff4976021aae)
            % 3 : ff4976021aae
            % 4 : 2009-02-27
            % 5 : 296
            % 6 : '--prefix=/home/hines/neuron/nrnmpi' '--srcdir=../nrn' '--with-paranrn' '--with-nrnpython'
            if nargin == 1
                [success,version_str] = obj.write('nrnversion()');
            else
                if type < 0 || type > 6
                    error('Unsupported version type')
                end
                cmd_str = sprintf('nrnversion(%d)',type);
                [success,version_str] = obj.write(cmd_str);
            end
            
            if ~success
               error('Failed to retrieve the version string') 
            end
            
           
        end
        function [cur_dir,success] = cd_get(obj)
            %cd_set Wrapper for NEURON function that accomplishes cd() get functionality
            %
            %   [cur_dir,success] = cd_get(obj)
            %
            %   Neuron Command
            %   --------------
            %   getcwd()
            %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/function/0fun.html#getcwd
            
            
            [success,cur_dir] = obj.write('getcwd()');
            cur_dir = strtrim(cur_dir);
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

if nPairs ~= length(values)
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
