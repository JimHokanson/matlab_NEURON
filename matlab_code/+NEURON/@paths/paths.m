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
    
    %INITIALIZATION METHODS
    methods
        function obj = paths
            %matlab_code\NEURON\paths -> three directories that we need to go up
            root_toolbox_directory = fileparts(fileparts(fileparts(getMyPath)));
            
            obj.hoc_code_root       = fullfile(root_toolbox_directory,'HOC_CODE');
            obj.hoc_code_model_root = fullfile(obj.hoc_code_root,'models');
                        
            %NOTE: This is the only call to the user constants ...
            C = getUserConstants({'NEURON_EXE_PATH'});
            
            obj.exe_path  = C.NEURON_EXE_PATH;
            
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

