classdef paths < handle_light
    %
    %   Class: NEURON.paths
    %
    %   This is the main class for handling NEURON related pathing.
    %
    %   USER CONSTANTS NEEDED
    %   ===================================================================
    %   C.NEURON_EXE_PATH
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Build in reset method - NEURON_paths.reset
    %   2) Provide better customization of paths that are likely to change,
    %     specifically NEURON executable paths that will change with
    %     versioning
    
    properties
        hoc_code_root         %Directory containing all hoc code
        hoc_code_model_root   %Directory specifially containing code 
        %for models
        %(i.e. subfolders of this directory contain the model code)
        
        %Executable Related
        %------------------------------------------------------------------
        exe_path   %Path to executable. 
        %See NEURON.user_options, property: neuron_exe_path
        %
        %examples:
        %C:\nrn72\bin\nrniv.exe
        %/Applications/NEURON-7.3/nrn/i386/bin/nrniv
        %/usr/local/nrn/i686/bin/nrniv
        
        win_bash_exe_path %Path to bash executable for Windows. This is only
        %populated for Windows.
        
        %Not yet implemented, move from simulation into here ...
        %base_save_root
    end
    
    %INITIALIZATION METHODS   %============================================
    methods (Access = private)
        function obj = paths()
            %paths
            %
            %   obj = paths()
            %
            %   SINGLETON
            %   See: NEURON.paths.getInstance
            %
            
            %matlab_code\NEURON\paths -> three directories that we need to go up
            root_toolbox_directory  = filepartsx(getMyPath,3);
            
            obj.hoc_code_root       = fullfile(root_toolbox_directory,'HOC_CODE');
            obj.hoc_code_model_root = fullfile(obj.hoc_code_root,'models');
            
            user_options = NEURON.user_options.getInstance;
            
            obj.exe_path = user_options.neuron_exe_path;
            
            if ispc
                obj.win_bash_exe_path = fullfile(fileparts(obj.exe_path),'bash.exe');
            end
        end
    end
    
    methods (Static)
        function obj = getInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = NEURON.paths;
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end 
        function s = getCompilePaths()
            %getCompilePaths
            %
            %   s = getCompilePaths()
            %   
            %   OUTPUTS
            %   ===========================================================
            %   s : (structure), contents are system dependent
            %
            %   IMPLEMENTATION NOTE
            %   ===========================================================
            %   Given how infrequently these values are used I moved this
            %   code to a static function with a structure return instead
            %   of being a part of the object.
            %
            %   See Also:
            %       NEURON.compile
            
            obj = NEURON.paths.getInstance;
            
            if ispc
                s.c_root_install   = filepartsx(obj.exe_path,2);
                s.c_bash           = fullfile(s.c_root_install,'bin','bash');
                s.c_bashStartFile  = fullfile(s.c_root_install,'lib','bshstart.sh');
                s.c_mknrndll       = fullfile(s.c_root_install,'lib','mknrndll.sh');
            elseif ismac
                s.c_root_install = filepartsx(obj.exe_path,4);
                s.c_mknrndll     = fullfile(fileparts(obj.exe_path),'nrnivmodl');
            else
                warning('Compiling .mod files on non-mac Unix systems is not yet supported.')
            end
        end
    end
    
end

