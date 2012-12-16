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
            
            obj.j_reader        = NEURON_reader; %Java class
            
            
        end
        function delete(obj)
            %delete
            %
            %   delete(obj)
            
        end
    end
    
    methods (Static)
        function init_system_setup
            %
            
            %TODO: Add class file ...
            
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
            
            
            %NOTE: It would be nice on system error to cancel this
            %i.e. errors that occur in callback method ...
            [success,results] = waitForFinish(obj,option_structure.max_wait);
            
            
        end
    end
    

    
end

