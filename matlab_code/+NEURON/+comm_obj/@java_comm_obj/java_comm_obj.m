classdef java_comm_obj < NEURON.comm_obj
    %
    %
    
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
        debug
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
    
    %MESSAGE RECEIVING   -----------------------------------------------
    properties
        
    end
    
    properties (Constant, Hidden)
        cmd_options = {'-nogui' '-nobanner' '-isatty'};
    end
    
    methods
        function obj = java_comm_obj(paths_obj)
            obj.paths = paths_obj;
            
            cmd_array = [obj.paths.exe_path obj.cmd_options];
            
            %java.lang.ProcessBuilder
            temp_process_builder = java.lang.ProcessBuilder(cmd_array);
            
            obj.j_process       = temp_process_builder.start();
            
            obj.j_error_stream  = obj.j_process.getErrorStream;
            obj.j_input_stream  = obj.j_process.getInputStream;
            obj.j_output_stream = obj.j_process.getOutputStream;
            %Java class
            obj.j_reader        = NEURON_reader(obj.j_input_stream,...
                obj.j_error_stream,obj.j_process);

            %NOTE: I can try and hide the window here ...
            
        end
        function [success,results] = readResult(obj,wait_time,debug)
           r = obj.j_reader;
           r.init_read(wait_time,debug);
            done = false;
            while ~done
                done = r.read_result;
                if ~done
                    pause(0.001)
                end
            end

            success = r.success_flag;
            
             if ~success
                process_running =  r.process_running;
                if ~process_running
                    error('Process is no longer running')
                end
                
                stackdump_present = r.stackdump_present;
                if stackdump_present
                    error('Stackdump detected');
                end
                
                read_timeout = r.read_timeout;
                if read_timeout
                    error('Read timeout');
                end
                
             end
            
            results = char(r.result_str);
            if ~isempty(results) && results(end) == char(10);
                results(end) = [];
            end     
        end
        function hideWindow(obj)
            if ispc
                %NOT YET IMPLEMENTED
                
                
                %hwnd = user32.getWindowHandleByName('C:\nrn72\bin\nrniv.exe')
               %.NET methods???
               % EnumWindows
               % GetWindowThreadProcessID
                
                %tasklist.exe - will yield process id
                
                %OLD CODE FOR WINDOWS COMM OBJ:
%                 HIDE_WINDOW_OPTION = 0;
%                 LAUNCH_TIMEOUT     = 2; %seconds, How long to wait for window to launch before throwing an error
%                 
%                 hwnd = 0;
%                 ti = tic;
%                 while hwnd == 0
%                     hwnd = p.MainWindowHandle.ToInt32;
%                     pause(0.001)
%                     t = toc(ti);
%                     if t > LAUNCH_TIMEOUT
%                         error('Failed to launch process successfully')
%                     end
%                 end
%                 user32.showWindow(hwnd,HIDE_WINDOW_OPTION)
                
            end
        end
        function delete(obj)
            %delete
            %
            %   delete(obj)
            
            %?? Should I exit first ????
            obj.j_process.destroy;
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
            out = obj.j_output_stream;
            str = java.lang.String([str_to_write char(10)]);
            out.write(str.getBytes,0,length(str));
            out.flush;
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
            
            [success,results] = readResult(obj,max_wait,obj.debug);
        end
    end
    
    
    
end

