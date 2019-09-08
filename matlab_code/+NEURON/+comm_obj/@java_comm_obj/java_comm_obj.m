classdef java_comm_obj < NEURON.comm_obj
    %
    %   Class:
    %   NEURON.comm_obj.java_comm_obj
    %
    %   java_comm_obj < NEURON.comm_obj
    %
    %   This is a Java implementation of the communication object. It
    %   relies upon a Java class in the private directory, called
    %   NEURON_reader.
    %
    %   The Java implementation is the preferred communication object as it
    %   seems to run a bit faster, should work on all os systems, and
    %   seems less susceptible to random Matlab crashes.
    %
    %   Improvements
    %   ------------
    %   1) Change the java reader to dynamically update string sizes when
    %   an overflow occurs.
    %   2) Allow interruption of the JAVA reader instead of pausing during
    %   read result in this class.
    %       See: NEURON.comm_obj.java_comm_obj.readResult
    %
    %
    %   Static Methods - most of these are internal use only
    %   ----------------------------------------------------
    %   NEURON.comm_obj.java_comm_obj.compileJavaProgram
    %   NEURON.comm_obj.java_comm_obj.editJavaCode
    %
    %   Installation
    %   ------------
    %   Installation requires calling the static method:
    %       NEURON.comm_obj.java_comm_obj.init_system_setup
    %
    %   This should be called by NEURON.s.init_system()
    
    
    
    properties
        %j => prefix to indicate Java class
        %------------------------------------------------------------------
        j_process  %Class: Implementation of java.lang.Process
        %
        %   The process is held onto for destruction when this class
        %   gets destroyed
        
        %Streams   ---------------------------------------------------------
        j_error_stream   %Implementation of java.io.InputStream
        %https://docs.oracle.com/javase/7/docs/api/java/io/InputStream.html
        
        j_input_stream   %Implementation of java.io.InputStream
        %http://docs.oracle.com/javase/7/docs/api/java/io/BufferedInputStream.html
        
        j_output_stream  %Class: java.io.BufferedOutputStream (Windows)
        %http://download.java.net/jdk7/archive/b123/docs/api/java/io/BufferedOutputStream.html
        %------------------------------------------------------------------
        
        j_reader %Class: NEURON_reader, local Java class implemented
        %specifically for communication with NEURON
        
        cmd_array %cellstr, commands sent to the process builder to start
        %the secondary process (i.e. the NEURON process)
    end
    
    properties (Constant, Hidden)
        % -isatty vs -notatty
        % Forum discussion on topic here:
        % http://www.neuron.yale.edu/phpBB/viewtopic.php?f=4&t=2732
        %cmd_options_pc   = {'-nogui' '-nobanner' '-isatty'}
        %cmd_options_unix = {'-nogui' '-nobanner' '-notatty'}
        
        %This also is what is run on Windows for newer versions of NEURON
        cmd_options_unix = {'-nogui' '-nobanner' '-notatty' '-nopython'}
        
        %Hines intention:
        %-isatty unbuffered stdout, print prompt when waiting for stdin
        %-notatty buffered stdout and no prompt
        %
        %I had problems with isatty so I switched to notatty
    end
    
    methods (Hidden)
        function obj = java_comm_obj()
            %java_comm_obj
            %
            %   obj = NEURON.comm_obj.java_comm_obj()
            
            paths_obj = NEURON.paths.getInstance;
            
            %In later versions of NEURON the bash executable is missing
            %so this only runs on Windows for older NEURON versions
            if ispc && exist(paths_obj.win_bash_exe_path,'file')
                %In NEURON 7.3 I'm getting a warning about DOS paths
                %when running chdir(). I'm not sure where that is coming
                %from since I'm using cygwin pathing
                
                cmd_array = {paths_obj.win_bash_exe_path '-c' [NEURON.sl.dir.getCygwinPath(paths_obj.exe_path) ' -nobanner']};
            else
                % Here i'm assuming mac and unix behave the same ...
                cmd_array = [paths_obj.exe_path obj.cmd_options_unix];
            end
            
            %java.lang.ProcessBuilder
            pb = java.lang.ProcessBuilder(cmd_array);
            
            %On my mac for NEURON 7.7 I was getting an error about not
            %being able to find a bash script that is in the same location
            %as the nrniv executable. To fix this we add the folder
            %containing the executable to the PATH variable of the
            %NEURON process.
            %
            %Note that using setenv() in Matlab does not work (this was
            %tested), as presumably this only modifies Matlab's version
            %of the system path, not NEURON's.
            %
            %https://stackoverflow.com/questions/41263358/java-process-builder-add-path-to-environment-not-working
            pb.environment().put('PATH',[ ...
                fileparts(paths_obj.exe_path) ...
                char(java.io.File.pathSeparator) getenv('PATH')]);
            %save for debugging
            obj.cmd_array = cmd_array;
            
            %Starting the process
            %--------------------------------------------------
            obj.j_process       = pb.start();
            obj.j_error_stream  = obj.j_process.getErrorStream;
            obj.j_input_stream  = obj.j_process.getInputStream;
            obj.j_output_stream = obj.j_process.getOutputStream;
            
            %Java Reader class:
            %   local code, added during initialization
            %
            %   Initialized in call to NEURON.s.init_system
            %   NEURON.comm_obj.java_comm_obj.init_system_setup
            %
            %Source code: ./private/java_code/src/NEURON_reader.java
            
            
            
            try
                %NEURON_reader(BufferedInputStream pin, FileInputStream perr, Process p)
                %
                %   On Mac:
                %   - java.lang.UNIXProcess
                %   - java.lang.UNIXProcess$ProcessPipeInputStream
                %   - java.lang.UNIXProcess$ProcessPipeOutputStream
                obj.j_reader = NEURON_reader(obj.j_input_stream,...
                    obj.j_error_stream,obj.j_process);
            catch ME
                fprintf(2,['Failed to instantiate NEURON_reader class\n' ...
                    'this most often happens when failing to call\n' ...
                    'NEURON.s.init_system() on system startup\n' ...
                    '--------------------------------------------------\n']);
                %Call initialize_matlab_NEURON() on startup
                %
                %    I generally prefer to place this in a startup file:
                %        root_path = 'D:\repos\matlab_git\matlab_NEURON\matlab_code';
                %        addpath(root_path)
                %        initialize_matlab_NEURON()
                %
                ME.rethrow();
            end
            
            %Some debugging of a CYGWIN path error
            %[success,results] = obj.write('1');
        end
        
        function delete(obj)
            %delete
            %
            %   delete(obj)
            
            %This destroys the Java process
            if isjava(obj.j_process)
                obj.j_process.destroy;
            end
        end
    end
    
    %Setup and Validation
    %----------------------------------------------------------------------
    methods (Static,Hidden)
        function compileJavaProgram()
            %
            %   NEURON.comm_obj.java_comm_obj.compileJavaProgram()
            
            bin_path = NEURON.comm_obj.java_comm_obj.getJavaBinPath();
            code_root = fileparts(bin_path);
            java_target = fullfile(code_root,'src','NEURON_reader.java');
            NEURON.utils.java.compile(java_target)
            
            current_breakpoints = dbstatus('-completenames');
            evalin('base', 'clear java');
            pause(0.1)
            dbstop(current_breakpoints);
            
            
            src = fullfile(code_root,'src','NEURON_reader.class');
            dest = fullfile(bin_path,'NEURON_reader.class');
            movefile(src,dest)
        end
        function editJavaCode()
            %
            %   NEURON.comm_obj.java_comm_obj.editJavaCode()
            %
            bin_path = NEURON.comm_obj.java_comm_obj.getJavaBinPath();
            code_root = fileparts(bin_path);
            java_target = fullfile(code_root,'src','NEURON_reader.java');
            edit(java_target)
        end
        function reinstall_java()
            %reinstall_java
            %
            %   This function is meant to clear java when we are updating
            %   the Java reader class. It also holds onto break points.
            %
            %   NEURON.comm_obj.java_comm_obj.reinstall_java
            
            current_breakpoints = dbstatus('-completenames');
            evalin('base', 'clear java');
            pause(0.1)
            dbstop(current_breakpoints);
            
            NEURON.comm_obj.java_comm_obj.init_system_setup
        end
        function [flag,reason] = validate_installation
            %validate_installation
            %
            %    [flag,reason] = NEURON.comm_obj.java_comm_obj.validate_installation
            %
            %    The goal of this method is to verify that things are
            %    properly installed.
            
            java_paths = javaclasspath(); %Current java paths defined in Matlab
            
            %Desired path to be defined
            java_bin_path = NEURON.comm_obj.java_comm_obj.getJavaBinPath;
            
            %??? - does this work for unix and mac?
            flag = any(cellfun(@(x) strcmp(x,java_bin_path),java_paths));
            
            if flag
                reason =  '';
                try
                    %Static method call to class to test installation
                    NEURON_reader.test_install;
                catch ME %#ok<NASGU>
                    flag = false;
                    %Should also do: usejava('awt')
                    reason = ['Sources is on path but calling class failed'...
                        ', perhaps Java versions differ???'];
                end
            else
                reason = 'NEURON_reader not found in java class path';
            end
            
        end
        function java_bin_path = getJavaBinPath()
            %
            %   java_bin_path = NEURON.comm_obj.java_comm_obj.getJavaBinPath()
            %
            %   Outputs
            %   -------
            %   java_bin_path : String
            %       Returns path to the folder which contains the local
            %       Java class which is needed for reading data from
            %       NEURON.
            
            my_path = NEURON.sl.stack.getMyBasePath();
            java_bin_path = fullfile(my_path,'private','java_code','bin');
        end
        function init_system_setup()
            %init_system_setup
            %
            %   NEURON.comm_obj.java_comm_obj.init_system_setup()
            %
            %   Adds the NEURON_reader
            %
            %   NOTE: For non-jar file we add the directory, not the
            %   class files
            
            %Let's first check that the class is not in the static path
            if NEURON.comm_obj.java_comm_obj.validate_installation
                %Do nothing
            else
                javaaddpath(NEURON.comm_obj.java_comm_obj.getJavaBinPath);
            end
        end
    end
    
    %MAIN COMMUNICATION METHOD
    %----------------------------------------------------------------------
    methods
        function [success,results] = write(obj,command_str,option_structure)
            %write
            %
            %   [success,results] = write(obj,command_str,*option_structure)
            %
            %   This is the main function which is responsible for sending
            %   a message to NEURON and waiting for a response.
            %
            %
            %    Inputs
            %    ------
            %    command_str : (string)
            %           Command to run
            %    option_structure : (structure) (not a class)
            %        .max_wait    - (default 10), -1 indicates waiting
            %               forever, wait time in seconds before read
            %               timeout occurs
            %        .debug       - (default true) whether to print
            %                        messages or not ...
            %
            %   See Also
            %   --------
            %   NEURON.cmd.write
            %   NEURON.comm_obj.java_comm_obj.writeLine
            %
            %   Full Path:
            %   NEURON.comm_obj.java_comm_obj.write
            %
            %   Design Note
            %   -----------
            %   Normally this function should be called by NEURON.cmd.write
            %
            %   I added defaults to allow calling this code directly when
            %   testing
            %
            %   The input is a structure to avoid input processing as this
            %   function may be called often.
            
            if ~exist('option_structure','var')
                option_structure = struct('debug',true,'max_wait',10);
            end
            
            debug = option_structure.debug;
            
            
            %TODO: Ideally some of this would be done in the Java class
            %since the Java class needs to know about the terminator anyway
            
            %TODO: Consider merging these two lines to have a single flush
            %and improve performance ...
            obj.writeLine(command_str);
            
            %We need to transmit something to NEURON that gets echoed back
            %to us to let us know that the above command has finished. I 
            %originally had something with newlines, but somewhere carriage
            %returns were getting added ...
            obj.writeLine('{fprint("<xxocxx>")}');
            
            max_wait = option_structure.max_wait;
            
            [success,results] = obj.readResult(max_wait,debug);
        end
    end
    
    methods (Hidden)
        function s = getJavaReaderInfo(obj)
            %TODO: I don't think this is everything in the class ...
            r = obj.j_reader;
            s = struct;
            s.success_flag = r.success_flag;
            s.error_flag = r.error_flag;
            s.detected_end_statement = r.detected_end_statement;
            s.input_string = char(r.getCurrentInputString);
            s.error_string = char(r.getCurrentErrorString);
        end
    end
    
    %COMMUNICATION HELPER METHODS
    %----------------------------------------------------------------------
    methods (Access = private)
        function writeLine(obj,str_to_write)
            %writeLine
            %
            %   writeLine(obj,str_to_write)
            %
            %   This short method encapsulates sending a string to NEURON.
            %
            %   See Also
            %   --------
            %   write
            
            out = obj.j_output_stream;
            
            %NOTE: To every string we add on a newline.
            str = java.lang.String([str_to_write char(10)]); %#ok<CHARTEN>
            
            %On writing we need to pass in a byte array. Hence the use of
            %a Java string above and using the getBytes method
            out.write(str.getBytes,0,length(str));
            
            %NOTE: Remember to flush!
            try
                out.flush;
            catch ME
                %On my mac this failed on startup because of a setup
                %error.
                %
                % error identifier: 'MATLAB:Java:GenericException'
                %
                %   The error was something about a dylib being missing
                %   which required x11
                %
                %   X11 => https://www.xquartz.org/
                %
                %   Basically the output stream was closed, so the flush
                %   fails. Normally I think this section is avoided because
                %   errors come our messages sent to NEURON (i.e. after
                %   flushing), whereas this error came simply from starting
                %   NEURON, thus our first write fails.
                
                %This is the Matlab way of reading from the stream, rather
                %than calling our local Java class.
                n_available = obj.j_error_stream.available();
                err = obj.j_error_stream;
                output = zeros(1,n_available);
                for i = 1:n_available
                    %Other read methods require passing a pointer
                    %to a byte array. With this approach we get one
                    %byte at a time which for some reason is returned
                    %as a double (we could cast at reading, but I just
                    %cast before printing)
                    output(i) = err.read();
                end
                fprintf(2,'------------   error from NEURON ... --------------\n');
                fprintf(2,char(output));
                fprintf(2,'\n-----------------------------------------------\n\n\n');
                
                error('See error message above')
            end
        end
        
        function [success,results] = readResult(obj,wait_time,debug)
            %readResult
            %
            %    [success,results] = readResult(obj,wait_time,debug)
            %
            %   Inputs
            %   ------
            %   wait_time : (s)
            %       Apparently this value gets casted to an integer ...
            %
            %       -1 is a special value, meaning that the code will wait
            %       indefinitely.
            %   debug : boolean
            %       If true ...
            %
            %   NOTE: In general it is expected that this method is called
            %   from the write() method.
            %
            %   See Also
            %   --------
            %   write
            
            %Reader:
            
            r = obj.j_reader;
            
            r.init_read(wait_time,debug);
            done = false;
            %NOTE: I decided to do the pausing here so that you can
            %intterupt the read in Matlab as opposed to trying to intterupt
            %the Java process which I found to be much more difficult.
            t = tic;
            while ~done
                done = r.read_result;
                %NOTE: One can always set debug to true to see why this is
                %not working ...
                %Other methods:
                %   r.getCurrentInputString
                %   r.getCurrentErrorString
                if ~done
                    pause(0.001)
                end
                %   %In case of problems with timing out ...
                %
                %                 if toc(t) > 2
                %                    keyboard
                %                 end
            end
            
            %debugging: s = obj.getJavaReaderInfo();
            
            error_flag = r.error_flag;
            success    = r.success_flag;
            
            %Success processing
            %--------------------------------------------------
            results = char(r.result_str);
            if ~error_flag
                if ~isempty(results) && results(end) == char(10);
                    results(end) = [];
                end
            else
                if ~r.process_running
                    fprintf(2,'\nLAST ERROR BEFORE PROCESS CLOSED:\n%s\n\n',results);
                    error('Process is no longer running')
                elseif r.stackdump_present
                    fprintf(2,'\nLAST NEURON ERROR BEFORE STACKDUMP:\n%s\n\n',results);
                    error('Stackdump detected');
                elseif r.read_timeout
                    %TODO: Incorporate current strings ...
                    %
                    %
                    %r.getCurrentInputString
                    %r.getCurrentErrorString
                    error('Read timeout');
                else
                    %If this runs I must have added an extra case in the
                    %Java code which would cause the error flag to
                    %be set ...
                    
                    fprintf(2,'\nERROR MSG (might be empty)\n%s\n\n',results);
                    
                    error('Unhandled java comm error case, see code')
                end
            end
            
            
        end
    end
    
end

