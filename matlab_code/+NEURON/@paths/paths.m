classdef paths < handle
    %NEURON_paths 
    %
    %   USER CONSTANTS NEEDED
    %   ==================================================================
    %   C.NEURON_EXE_PATH 
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   build in reset method - NEURON_paths.reset
    %   build in support for model specific paths ...
    
    properties
        hoc_code_root         %Directory containing all hoc code
        hoc_code_model_root   %Directory specifially containing code for models
                              %(i.e. subfolders of this directory contain
                              %the model code)
                              
        %Executable Related
        %------------------------------------------------------------------
        exe_path   	%From C.NEURON_EXE_PATH (userConstants)
                   	%This is needed in order to launch NEURON
        
        save_root   %Location where files are saved to send back and forth to NEURON

        %Compile Related - See NEURON.compile
        %------------------------------------------------------------------
        c_root_install
        c_bash
        c_bashStartFile
        c_mknrndll
    end
    
    properties (Constant)
        % Default nrniv install directories, by OS
        % Must change the appropriate property if nrniv installed somewhere
        % else
        NRNIV_WIN_PATH = 'C:\nrn72\bin\nrniv.exe'
        NRNIV_MAC_PATH = '/Applications/NEURON-7.2/nrn/i386/bin/nrniv'
        NNRNIV_LINUX_PATH = '/usr/local/nrn/i686/bin/nrniv'
    end
    
    %INITIALIZATION METHODS
    methods
        function obj = paths
            %matlab_code\NEURON\paths -> three directories that we need to go up
            root_toolbox_directory = fileparts(fileparts(fileparts(getMyPath)));
            
            obj.hoc_code_root       = fullfile(root_toolbox_directory,'HOC_CODE');
            obj.hoc_code_model_root = fullfile(obj.hoc_code_root,'models');
                        
            %NOTE: This is the only call to the user constants ...
            if exist('getUserConstants','file')
                C = getUserConstants({'NEURON_EXE_PATH'});
                obj.exe_path  = C.NEURON_EXE_PATH;
            else
                if ispc % Windows
                    obj.exe_path  = obj.NRNIV_WIN_PATH;
                elseif ismac % Mac
                    obj.exe_path = obj.NRNIV_MAC_PATH;
                else % Linux, etc.
                   obj.exe_path = obj.NRNIV_LINUX_PATH; 
                end
            end

            getCompilePaths(obj)
        end
        function getCompilePaths(obj)
            if ispc
                obj.c_root_install   = fileparts(fileparts(obj.exe_path));
                obj.c_bash           = fullfile(obj.c_root_install,'bin','bash');
                obj.c_bashStartFile  = fullfile(obj.c_root_install,'lib','bshstart.sh');
                obj.c_mknrndll       = fullfile(obj.c_root_install,'lib','mknrndll.sh');
            else % mac, possibly for unix too, untested
                if ~ismac
                    warning('non-mac unix has not been tested.')
                end
                obj.c_root_install = fileparts(fileparts(fileparts(fileparts(obj.exe_path))));
                obj.c_mknrndll = fullfile(obj.c_root_install,'nrn','i386','bin','nrnivmodl');
            end
        end
    end

end

