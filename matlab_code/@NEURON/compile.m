function compile(mod_dir_path)
%
%   compile(mod_dir_path)
%
%   NOTE: The goal of this file is take in
%   a mod pathand to compile the necessary dll files
%   instead of using NEURON's awful gui system
%   This is especially useful when making changes to the file
%   during development
%
%IMPORTANT: 
%Commenting out lines in mknrndll file will allow for not needing to press return

np = NEURON.paths;

%EXAMPLE PATHS
%================================================
%          c_root_install: 'C:\nrn72'
%                  c_bash: 'C:\nrn72\bin\bash'
%         c_bashStartFile: 'C:\nrn72\lib\bshstart.sh'
%              c_mknrndll: 'C:\nrn72\lib\mknrndll.sh'

mod_dir_path = getCygwinPath(mod_dir_path);

bash_path       = np.c_bash;
bash_start_file = getCygwinPath(np.c_bashStartFile);
mknrndll        = getCygwinPath(np.c_mknrndll);
NEURON_root     = getCygwinPath(np.c_root_install);

%Call bash, running their startup script, cding to mod path and then
%calling their function with the correct root directory as an input
temp = [bash_path ' --rcfile ' bash_start_file ' -c "cd ' mod_dir_path ' && ' mknrndll ' ' NEURON_root '"'];

fprintf(2,'------------------  Compiling mod functions  ------------------\n');
dos(temp,'-echo');
fprintf(2,'------------------  Compile End  ------------------\n');







%OLD CODE
%===========================================================================



% % % % %NEURON_compile compiles mod code for directory specified
% % % % %
% % % % %   CALLING FORMS
% % % % %   ==================================================
% % % % %   NEURON_compile(mod_mech_dir)
% % % % %
% % % % %   NEURON_compile(model)
% % % % 
% % % % %NOTE: I am unsure if I needed to make any changes to the Neuron install in
% % % % %order to get this to work ..., If I did it might have been to a batch
% % % % %file in one of the Neuron directories indicated by some of the paths
% % % % %from NEURON_getPaths
% % % % 
% % % % if exist(model,'dir')
% % % %     mod_dir = model;
% % % %     neuronPaths = NEURON_getPaths();
% % % % else
% % % %     neuronPaths = NEURON_getPaths(model);
% % % %     mod_dir = neuronPaths.mod_dir;
% % % % end
% % % % 
% % % % if ispc
% % % %     mod_path    = getCygwinPath(mod_dir);
% % % %     bash_rc     = getCygwinPath(neuronPaths.c.bashStartFile);
% % % %     mknrndll    = getCygwinPath(neuronPaths.c.mknrndll);
% % % %     root_neuron = getCygwinPath(neuronPaths.c.root_install);
% % % % else
% % % %     mod_path    = mod_dir;
% % % %     bash_rc     = neuronPaths.c.bashStartFile;
% % % %     mknrndll    = neuronPaths.c.mknrndll;
% % % %     root_neuron = neuronPaths.c.root_install;
% % % % end
% % % % 
% % % % bash_path = neuronPaths.c.bash;
% % % % 
% % % % %Call bash, running their startup script, cding to mod path and then
% % % % %calling their function with the correct root directory as an input
% % % % temp = [bash_path ' --rcfile ' bash_rc ' -c "cd ' mod_path ' && ' mknrndll ' ' root_neuron '"'];
% % % % 
% % % % fprintf(2,'------------------  Compiling mod functions  ------------------\n');
% % % % [tempStatus,tempResults] = dos(temp,'-echo');
% % % % fprintf(2,'------------------  Compile End  ------------------\n');
% % % % 
% % % % %keyboard
% % % % %Commenting out lines in mknrndll file will allow for not needing to press
% % % % %return