function compile(mod_dir_path)
%compile Compiles mod files into a dll.
%
%   compile(mod_dir_path)
%
%   INPUTS
%   =======================================================================
%   mod_dir_path : Path to folder containing mod files.
%
%   NOTE: The goal of this file is take in a mod path and to compile the
%   necessary dll files instead of using NEURON's awful gui system. This is
%   especially useful when making changes to the file during development as
%   it allows hardcoding the 
%
%   IMPORTANT: 
%   Commenting out lines in mknrndll file will allow for not needing to 
%   press return
%
%   See Also:
%       NEURON.paths

if ~ispc
    error('Code needs to be modified for non-windows systems')
end

np = NEURON.paths;

%EXAMPLE PATHS
%================================================
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