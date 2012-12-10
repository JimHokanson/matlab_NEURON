classdef NEURON < handle_light
    %NEURON
    %
    %   REQUIRES
    %   ===================================================================
    %   1) Path initialization    - call NEURON.init_system (only needed once)
    %   2) RNEL library functions - I am working on moving these to a
    %   separate package which are optionally installed on startup if not
    %   detected in the path already, see initialize.m function in root
    %   code directory
    %
    %   NOTE: In my startup function I call NEURON.init_system
    %
    %   USAGE NOTES
    %   ===================================================================
    %   This class is meant to be run by a NEURON simulation class, however
    %   it can be called instantiated directly, as in the example below.
    %
    %   N = NEURON;
    %   N.opt__interactive_mode = true;
    %   N.write('a = 5')
    %   N.write('a')
    %
    %   KNOWN SIMULATION CLASSES
    %   ===================================================================
    %   NEURON.simualtion.extracellular_stim
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
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
        opt__interactive_mode    = false; %If true, this tries to setup the
                                   %NEURON writing process so that it is
                                   %like typing into NEURON
    end
    
    %FOR DEBUGGING  %====================================
    properties
        debug        = false   %If true spits back everything from NEURON
        last_cmd_str = ''      %Set during NEURON.write in case there is an error
    end
    
    %"PUBLIC METHODS"  %==================================
    methods
        function obj = NEURON
            %NEURON
            %
            %   See class description above -> help NEURON
            
            obj.path_obj = NEURON.paths;
            
            %Load communication object based on system type
            if ispc
                obj.comm_obj = NEURON.comm_obj.windows_comm_obj(obj.path_obj);
            else
                error('Unsupported system')
            end
        end
        function varargout = write(obj,command_str,varargin)
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
            elseif obj.opt__interactive_mode
                fprintf('%s\n',result_str);
            end
            
            %This cleans things up a bit during interactive mode
            %where the command line color will indicate success or failure.
            if nargout
               varargout{1} = success;
               varargout{2} = result_str;
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
            %   NOTE: This function should provide a path that is safe for
            %   passing into Neuron. This basically involves creating a
            %   cygwin path for windows.

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
