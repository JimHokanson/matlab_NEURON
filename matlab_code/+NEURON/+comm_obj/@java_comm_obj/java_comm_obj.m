classdef java_comm_obj < NEURON.comm_obj
    %
    %   Class:
    %       NEURON.comm_obj.java_comm_obj
    %   
    %   java_comm_obj < NEURON.comm_obj
    %
    %   This is a Java implementation of the communication object. It
    %   relies upon a Java class in the private directory, called 
    %   NEURON_reader.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Change the java reader to dynamically update string sizes when
    %   an overflow occurs.
    
    properties
        paths      %Class: NEURON.paths
        
        %j => Java
        j_process  %Class: java.lang.ProcessImpl
        
        %Streams   ---------------------------------------------------------
        j_error_stream   %Class: java.io.FileInputStream
        %http://docs.oracle.com/javase/7/docs/api/java/io/FileInputStream.html
        
        j_input_stream   %Class: java.io.BufferedInputStream
        %http://docs.oracle.com/javase/7/docs/api/java/io/BufferedInputStream.html
        
        j_output_stream  %Class: java.io.BufferedOutputStream
        %http://download.java.net/jdk7/archive/b123/docs/api/java/io/BufferedOutputStream.html
        
        j_reader
    end
    
    %DEBUGGING   -----------------------------------------------
    properties
        %.write()
        %--------------------------------------------------------
        debug           %if
        last_cmd_str
        
        %.setResultAndTerminateWait()
        %-----------------------------------------------------
        termination_str_observed  %I don't think I really need this
        %Could probably remove the code ...
        
        %.setFinalString()
        %------------------------------------------------------------
        partial_good_str         %Set if an error occurred but the stdout is not empty
        %termination_str_observed %String observed that caused termination
    end
    
    properties (Constant, Hidden)
        % -isatty vs -notatty
        % check here
        % http://www.neuron.yale.edu/phpBB/viewtopic.php?f=4&t=2732
        cmd_options_pc = {'-nogui' '-nobanner' '-isatty'}
        cmd_options_unix = {'-nogui' '-nobanner' '-notatty'}
    end
    
    methods
        function obj = java_comm_obj(paths_obj)
            %
            %   For direct call testing:
            %   NEURON.comm_obj.java_comm_obj(NEURON.paths);
            %
            %
            obj.paths = paths_obj;
            
            if ispc
                cmd_array = [obj.paths.exe_path obj.cmd_options_pc];
            else % here i'm assuming mac and unix behave the same, if there's an issue with unix, fix this
                cmd_array = [obj.paths.exe_path obj.cmd_options_unix];
            end
            
            %java.lang.ProcessBuilder
            temp_process_builder = java.lang.ProcessBuilder(cmd_array);
            
            if ispc
                %For hiding window later ...
                process_array = System.Diagnostics.Process.GetProcessesByName('nrniv');
                
                %For focus management ...
                mde = com.mathworks.mde.desk.MLDesktop.getInstance;
                cw = mde.getClient('Command Window');
                cw_has_focus  = cw.hasFocus;
                %                if ~cw_has_focus
                %                    ed = mde.getGroupContainer('Editor').getTopLevelAncestor;
                %                    ed_has_focus = ed.isActive;
                %                end
            end
            
            %Starting the process
            %--------------------------------------------------
            obj.j_process       = temp_process_builder.start();
            
            obj.j_error_stream  = obj.j_process.getErrorStream;
            obj.j_input_stream  = obj.j_process.getInputStream;
            obj.j_output_stream = obj.j_process.getOutputStream;
            
            %Java Reader class - local code, added during initialization
            obj.j_reader        = NEURON_reader(obj.j_input_stream,...
                obj.j_error_stream,obj.j_process);
            
            if ispc
                % hide window
                hideWindow(obj,process_array)
                
                %Giving focus back ...
                if cw_has_focus
                    %NOTE: I'm not sure that you lose focus for mac or unix
                    commandwindow
                    % %                 elseif ed_has_focus
                    % %                    ed.requestFocus;
                end
            end
        end
        
        function delete(obj)
            %delete
            %
            %   delete(obj)
            
            if isjava(obj.j_process)
                obj.j_process.destroy;
            end
        end
    end
    
    methods (Static)
        function init_system_setup
            %
            
            %NOTE: For non-jar files we add the directory, not the class
            %files
            my_path       = getMyPath;
            java_bin_path = fullfile(my_path,'private','java_code','bin');
            javaaddpath(java_bin_path);
        end
    end
    
    %COMMUNICATION METHODS  ======================================
    methods (Hidden)
        function writeLine(obj,str_to_write)
            %writeLine
            %
            %   writeLine(obj,str_to_write)
            %
            %   This short method encapsulates sending a string to NEURON.
            %
            %   See Also:
            %       NEURON.comm_obj.java_comm_obj.write()
            
            out = obj.j_output_stream;
            %NOTE: To every string we add on a newline.
            str = java.lang.String([str_to_write char(10)]);
            %On writing we need to pass in a byte array. Hence the use of
            %a Java string above and using the getBytes method
            out.write(str.getBytes,0,length(str));
            
            %NOTE: Remember to flush!
            out.flush;
        end
        function [success,results] = readResult(obj,wait_time)
            %
            %    [success,results] = readResult(obj,wait_time,debug)
            %
            %   NOTE: In general it is expected that this method is called
            %   from the write() method.
            
            r = obj.j_reader;
            r.init_read(wait_time,obj.debug);
            done = false;
            %NOTE: I decided to do the pausing here so that you can
            %intterupt the read in Matlab as opposed to trying to intterupt
            %the Java process which I found to be much more difficult
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
            end
            
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
                    %JAH TODO: Need to create methods for returning
                    %either character array (in or err) instead of
                    %result_str
                    error('Read timeout');
                else
                   %If this runs I must have added an extra case
                   %which would cause this to error
                   
                   fprintf(2,'\nERROR MSG (might be empty)\n%s\n\n',results);
                   
                   error('Unhandled java comm error case, see code') 
                end
            end
            
            
        end
    end
    
    methods
        function [success,results] = write(obj,command_str,option_structure)
            %
            %
            %
            %    INPUTS
            %    ===========================================================
            %    option_structure (structure)
            %        .max_wait    - -1, wait forever?
            %        .debug       - whether to print messages or not ...
            
            obj.debug        = option_structure.debug;
            
            obj.last_cmd_str = command_str;
            
            obj.writeLine(command_str);
            
            %Forcing a newline
            %--------------------------------------------------------------
            %In general Neuron doesn't always do a line return with an <oc>
            %prompt. It is possible to search the end of a return string to
            %find an <oc>, but this seemed messy. Instead we explicitly
            %look for a seperate transmission of <oc>. The first newline
            %forces a separate transmission, since the .NET process looks
            %for newlines. The second newline ends the transmission.
            obj.writeLine('{fprint("\n<oc>\n")}');
            
            max_wait = option_structure.max_wait;
            
            [success,results] = readResult(obj,max_wait);
        end
    end
    
    
    
end

