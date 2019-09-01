function compile(mod_dir_path)
%compile Compiles mod files into a dll.
%
%   NEURON.s.compile(*mod_dir_path)
%   
%   NEURON.s.compile(model_name)
%
%
%   Inputs
%   ------
%   mod_dir_path : string
%       Path to folder containing mod files. If not specified 
%       a file dialog window will open.
%   model_name : string
%       This can be the name of a model.
%
%   NOTE: The goal of this file is take in a mod path and to compile the
%   necessary dll files instead of using NEURON's awful gui system. This is
%   especially useful when making changes to the file during development as
%   it allows hardcoding the command to recompile.
%
%   Important Notes
%   ---------------
%   1)Commenting out lines in mknrndll file will allow for not needing to
%   press return. This is a file shipped with NEURON (not with this code).
%
%   See Also
%   --------
%   NEURON.paths
%   NEURON.cell.getModRoot

np = NEURON.paths.getCompilePaths;

if ~exist(mod_dir_path,'dir')
    %Might be a model name
    try
        cell_name = mod_dir_path;
        mod_dir_path = NEURON.cell.getModRoot(cell_name);
    catch
        %Note, this might just mean we need to update NEURON.cell.getModRoot
        error('Specified input doesn''t exist as a directory and is not recognized as a cell name')
    end
end
    
    

if ispc
    %Example Paths
    %-------------
    %          c_root_install: 'C:\nrn72'
    %                  c_bash: 'C:\nrn72\bin\bash'
    %         c_bashStartFile: 'C:\nrn72\lib\bshstart.sh'
    %              c_mknrndll: 'C:\nrn72\lib\mknrndll.sh'
    
    mod_dir_path    = getCygwinPath(mod_dir_path);
    
    bash_path       = np.c_bash;
    bash_start_file = getCygwinPath(np.c_bashStartFile);
    mknrndll        = getCygwinPath(np.c_mknrndll);
    NEURON_root     = getCygwinPath(np.c_root_install);
    
    %Call bash, running their startup script
    %cd to mod path and then call their function with the correct root directory as an input
    temp = [bash_path ' --rcfile ' bash_start_file ' -c "cd ' mod_dir_path ' && ' mknrndll ' ' NEURON_root '"'];
    
    fprintf(2,'------------------  Compiling mod functions  ------------------\n');
    dos(temp,'-echo');
    fprintf(2,'------------------  Compile End  ------------------\n');
    
elseif ismac %may work for all unix systems, but untested
    mknrndll = np.c_mknrndll; % path to nrnivmodl
    
    cmdStr = ['cd ' mod_dir_path '&& ' mknrndll];
    
    fprintf(2,'------------------  Compiling mod functions  ------------------\n');
    unix(cmdStr);
    fprintf(2,'------------------  Compile End  ------------------\n');
    
else
    error('Code needs to be modified for non-mac unix systems')
end