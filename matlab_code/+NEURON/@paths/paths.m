classdef paths < handle
    %NEURON_paths 
    %
    %   USER CONSTANTS NEEDED
    %   ==================================================================
    %   C.NEURON_EXE_PATH 
    %   C.NEURON_SAVE_ROOT 
    %
    %IMPROVEMENTS
    %----------------------------
    %build in reset method - NEURON_paths.reset
    %build in support for model specific paths ...
    
    properties
        hoc_code_root         %Directory containing all hoc code
        hoc_code_model_root   %Directory specifially containing code for models
                              %(in subfolders of this directory)
        %Executable Related
        %------------------------------------------------------
        exe_path   	%From C.NEURON_EXE_PATH (userConstants)
                   	%This is needed in order to launch NEURON
        
        save_root   %Location where files are saved to send back and forth to NEURON

        %Compile Related - See NEURON.compile
        %------------------------------------------------------------
        c_root_install
        c_bash
        c_bashStartFile
        c_mknrndll
    end
    
    %INITIALIZATION METHODS
    methods
        function obj = paths
            root_toolbox_directory = fileparts(fileparts(getMyPath));
            
            obj.hoc_code_root = fullfile(root_toolbox_directory,'HOC_CODE');
            obj.hoc_code_model_root = fullfile(obj.hoc_code_root,'models');
            
            %C = getUserConstants({'NEURON_EXE_PATH' 'NEURON_SAVE_ROOT'});
            
            C = getUserConstants({'NEURON_EXE_PATH'});
            
            obj.exe_path  = C.NEURON_EXE_PATH;
            %obj.save_root = C.NEURON_SAVE_ROOT;
            
            getCompilePaths(obj)
        end
        function getCompilePaths(obj)
            obj.c_root_install   = fileparts(fileparts(obj.exe_path));
            obj.c_bash           = fullfile(obj.c_root_install,'bin','bash');
            obj.c_bashStartFile  = fullfile(obj.c_root_install,'lib','bshstart.sh');
            obj.c_mknrndll       = fullfile(obj.c_root_install,'lib','mknrndll.sh');
        end
    end

end

