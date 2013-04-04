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
        hoc_code_model_root   %Directory specifially containing code for models
        %(i.e. subfolders of this directory contain
        %the model code)
        
        %Executable Related
        %------------------------------------------------------------------
        exe_path   	%From C.NEURON_EXE_PATH (userConstants)
        %This is needed in order to launch NEURON
        
        base_save_root
    end
    
    properties (Constant)
        % Default nrniv install directories, by OS
        % Must change the appropriate property if nrniv installed somewhere
        % else
        NRNIV_WIN_PATH    = 'C:\nrn72\bin\nrniv.exe'
        NRNIV_MAC_PATH    = '/Applications/NEURON-7.3/nrn/i386/bin/nrniv'
        NNRNIV_LINUX_PATH = '/usr/local/nrn/i686/bin/nrniv'
    end
    
    %INITIALIZATION METHODS   %============================================
    methods (Access = private)
        function obj = paths()
            %matlab_code\NEURON\paths -> three directories that we need to go up
            root_toolbox_directory = fileparts(fileparts(fileparts(getMyPath)));
            
            obj.hoc_code_root       = fullfile(root_toolbox_directory,'HOC_CODE');
            obj.hoc_code_model_root = fullfile(obj.hoc_code_root,'models');
            
            if ispc % Windows
                obj.exe_path  = obj.NRNIV_WIN_PATH;
            elseif ismac % Mac
                obj.exe_path  = obj.NRNIV_MAC_PATH;
            else % Linux, etc.
                obj.exe_path   = obj.NRNIV_LINUX_PATH;
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

