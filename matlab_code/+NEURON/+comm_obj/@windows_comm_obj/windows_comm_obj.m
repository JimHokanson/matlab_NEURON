classdef windows_comm_obj < NEURON.comm_obj
    %
    %   Class:
    %       NEURON.comm_obj.windows_comm_obj
    %   
    %   IMPORTANT**********   The Java implementation is preffered as
    %   random Matlab crashes would occur with this class.
    %
    %   See Also:
    %       NEURON.comm_obj.java_comm_obj
    %
    %   This class wraps a .NET process allowing back and forth
    %   communication with NEURON. Specifically it makes use of
    %   System.Diagnostics.Process to launch the NEURON executable as a
    %   process. This gives this program access to NEURON's stdin and
    %   stdout. The process window is subsequently hidden using a user32
    %   process.
    %
    %   Asynchronous reads are used to allow back and forth communication.
    %   Alternatively the .NET lib would wait for the process to completely
    %   finish, and I could get the results of the process having run. This
    %   was essentially how I interacted with NEURON before hand. Now I can
    %   send a command, get the result, and then send another command to
    %   the same process without NEURON restarting.
    %
    %   METHODS IN OTHER FILES
    %   ===========================================================
    %   NEURON.comm_obj.cleanNeuronStr
    %   NEURON.comm_obj.windows_comm_obj.init_dotnet_code
    
    properties
        paths       %Class: NEURON.paths
        
        std_in_obj  %handle to System.Diagnostics.Process.StandardInput .NET object
        process_obj %handle to System.Diagnostics.Process .NET object
        
        %Not Currently Used
        lh_out  %Listener handle for stdout (.NET class)
        lh_err  %Listener handle for error
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
        %These are the buffers we get back from the NEURON program.
        %Unfortunately we don't get back the entire string at once.
        %Instead we get it back in parts, broken up by every new line.
        temp_stdout_str   = char(zeros(1,2000)); %first instance of ... caused overflow
        temp_stdout_index = 0
        temp_stderr_str   = char(zeros(1,2000));
        temp_stderr_index = 0
        
        %.write() %.
        running_cmd %Set true when writing a command and waiting for Neuron to respond
        %Set false when the callback functions have decided that NEURON
        %is done running the command
        
        
        %RESULTS ----------------------------------------------------------
        result_str  %Result from writing a command, set by the callback functions
        success     %Indicates whether result came from the error stream or from the output stream
        %NOTE: This does not indicate whether or not the code was
        %successful, as the code called may not throw an error but return
        %an error flag (see NEURON_cmd.chdir in which a failure is
        %indicated by a returned status byte, not by throwing an error)
        %NOTE: This is also set by the callback functions
    end
    
    methods
        function obj = windows_comm_obj(paths_obj)
            obj.paths = paths_obj;
            init_dotnet_code(obj)
        end
        function delete(obj)
            %delete
            %
            %   delete(obj)
            %
            %   This method is meant to force the NEURON process to stop
            %   executing.
            
            %http://msdn.microsoft.com/en-us/library/system.diagnostics.process.kill.aspx
            
            %See process nrniv.exe *32 in Windows Task Manager
            %If this is done improperly this process will still exist
            %after termination ...
            delete(obj.lh_out)
            delete(obj.lh_err)
            if ~obj.process_obj.HasExited
                %Is this better: CloseMainWindow
                obj.process_obj.Kill
            end
        end
    end
    
    methods (Static)
        function init_system_setup
            %init_system_setup Method needed to allow .NET process communication
            %
            %   The System .NET Assembly needs to be added
            %   to the Matlab path in order to run this class. This method
            %   only needs to be called once per Matlab session. I
            %   generally call this in my startup function.
            %
            %   FULL PATH:
            %   NEURON.comm_obj.windows_comm_obj.windows_comm_obj
            
            user32.init();
            NET.addAssembly('System');
        end
    end
    
    %COMMUNICATION METHODS  ======================================
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
            obj.running_cmd  = true;
            obj.last_cmd_str = command_str;
            obj.std_in_obj.WriteLine(command_str);
            
            %Forcing a newline
            %--------------------------------------------------------------
            %In general Neuron doesn't always do a line return with an <oc>
            %prompt. It is possible to search the end of a return string to
            %find an <oc>, but this seemed messy. Instead we explicitly
            %look for a seperate transmission of <oc>. The first newline
            %forces a separate transmission, since the .NET process looks
            %for newlines. The second newline ends the transmission.
            
            obj.std_in_obj.WriteLine('{fprint("\n<oc>\n")}');
            obj.std_in_obj.Flush;
            
            %NOTE: It would be nice on system error to cancel this
            %i.e. errors that occur in callback method ...
            [success,results] = waitForFinish(obj,option_structure.max_wait);
            
            
        end
        function setFinalString(obj)
            %setFinalString
            %
            %   This method is called by setResultAndTerminateWait
            
            %Options:
            %1) all good
            %2) all bad
            %3) bad, but some good was present
            
            if obj.temp_stderr_index > 0
                is_good = false;
                if obj.temp_stdout_index > 0
                    obj.partial_good_str = obj.temp_stdout_str(1:obj.temp_stdout_index-1);
                end
                %NOTE: remove -1 for the last newline
                str = obj.temp_stderr_str(1:obj.temp_stderr_index-1);
            else
                %all good
                is_good = true;
                str = obj.temp_stdout_str(1:obj.temp_stdout_index-1);
                
            end
            
            %This is a bit sloppy but is a result of the extra
            %termination string we write after the command
            if ~isempty(str) && str(end) == char(10)
                str(end) = [];
            end
            
            %Final assignments and resetting results
            %--------------------------------------------------
            obj.result_str        = str;
            obj.success           = is_good;
            obj.temp_stderr_index = 0;
            obj.temp_stdout_index = 0;
        end
    end
    
    methods (Hidden)
        %NEURON.comm_obj.windows_comm_obj.setResultAndTerminateWait
        setResultAndTerminateWait(ref,ev_data,is_success)
    end
    
end

