classdef NEURON < handle_light
    %NEURON
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
    %   the same process.
    %
    %   REQUIRES
    %   ====================================================================
    %   1) Path initialization    - call NEURON.initDotNet (only needed once)
    %   2) RNEL library functions - these are scattered throughout and not yet
    %       well characterized
    %
    %   USAGE NOTES
    %   ====================================================================
    %   This class is meant to be run by a NEURON simulation class, however it
    %   can be called instantiated directly.
    %
    %   KNOWN SIMULATION CLASSES
    %   ===================================================================
    %   NEURON.simualtion.extracellular_stim
    %
    %
    %   IMPROVEMENTS:
    %   ====================================================================
    %   - on deleting object, delete window, stop process (might be done
    %   already, check Windows processes
    %
    %
    %   COMMUNICATION OUTLINE
    %   ====================================================================
    %   METHODS:
    %       - setResultAndTerminateWait(ref,ev_data,is_success)
    %       - setFinalString(obj)
    %
    %   METHODS IN OTHER FILES
    %   openExplorerToMfileDirectory('NEURON')
    %   - NEURON.compile
    %   - NEURON.init_dotnet_code
    %   - NEURON.setResultAndTerminateWait
    %   - NEURON.waitForFinish
    
    
    %OBJECT REFERENCES
    %================================================================================
    properties
        path_obj    %Class: NEURON.paths
    end
    
    properties
        comm_obj    %Class: Implementation of NEURON.comm_obj, NOT YET IMPLEMENTED
    end
    
    %OPTIONS   %==========================================
    properties
        opt__throw_error_default = true;
        opt__interactive_mode    = false;
    end
    
    %FOR DEBUGGING  %====================================
    properties
        debug = false   %If true spits back everything from NEURON
        last_cmd_str    %Set during NEURON.write in case there is an error
    end
    
    %"PUBLIC METHODS"  %==================================
    methods
        function obj = NEURON
            %NEURON
            %
            %   See class description above
            
            obj.path_obj = NEURON.paths;
            
            if ispc
                obj.comm_obj = NEURON.comm_obj.windows_comm_obj(obj.path_obj);
            else
                error('Unsupported system')
            end
        end
        function [success,result_str] = write(obj,command_str,varargin)
            %write  Writes a command to the NEURON process
            %
            %   [success,results] = NEURON.write(str)
            %
            %   OUTPUTS
            %   ================================================
            %   success : Whether or not the NEURON program threw an error.
            %   results : stdout of NEURON from running command
            %
            %   See Also:
            %       NEURON.cmd      %Main access point for calling this function
            
            obj.last_cmd_str = command_str;
            
            in.throw_error = obj.opt__throw_error_default;
            in.max_wait    = -1;
            in.debug       = obj.debug;
            in = processVarargin(in,varargin);
            
            if in.debug
                fprintf('COMMAND:%s\n',command_str);
            end
            
            [success,result_str] = write(obj.comm_obj,command_str,in);
            
            if ~success && in.throw_error
                fprintf(2,'LAST COMMAND:\n%s\n',command_str);
                if obj.opt__interactive_mode
                    fprintf(2,'%s\n',result_str);
                else
                    error('ERROR FROM NEURON:\n%s',result_str)
                end
            end
        end
    end
    
    %SMALL HELPERS    ==============================================
    methods (Hidden)
        function delete(obj)
            delete(obj.comm_obj);
        end
    end
    
    %STATIC METHODS   ==============================================
    methods (Static)
        function init_system
        %init_system
        %
        %   Should be called on startup to initialize system, at least for
        %   Windows ...
        
            if ispc
                NEURON.comm_obj.windows_comm_obj.init_system_setup;
            else
                error('Unsupported system')
            end 
        end
        function file_path = createNeuronPath(file_path)
            %NEURON_createNeuronPath
            %
            %   file_path = NEURON_createNeuronPath(file_path)
            %
            %   NOTE: This function should provide a path that is safe for passing into
            %   Neuron. This basically involves creating a cygwin path for windows.

            if ispc
                file_path = getCygwinPath(file_path);
            else
                %Do nothing
                error('Not yet tested')
            end
        end
        compile(mod_path)  %Method will compile mod files into dll
        populate_helper_function_package
    end
end
