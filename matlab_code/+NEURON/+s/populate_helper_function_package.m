function populate_helper_function_package
%populate_helper_function_package Copies RNEL functions to this repository
%
%   NEURON.populate_helper_function_package         (STATIC METHOD)
%
%   USAGE NOTES:
%   ======================================================================
%	1) This is only setup to work with the RNEL functions on the path and
%	the local toolbox functions not on the path. That should normally be
%	the case if you have access to the RNEL functions as the initializer
%	(see initialize.m in root directory) won't add the local copies to the
%	path. In this way the which() function should always evaluate to the
%	correct version, not a local out of date version.
%
%   2) Only copying of functions or partial packages are currently
%   supported.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Any changes to the local versions of the files are not currently
%   supported and could be overridden quite easily. We should add at
%   least a warning in the local copies that make this clear. Ideally we
%   would have a way of detecting local improvements and asking the user to
%   reconcile updates between the two versions.
%   2) On updating the file with a new version, highlight this with a color
%   change.

%Functions which have been manually changed from the RNEL library and
%copied here. This is done because they are different (usually simpler) and
%accomplish the same thing we are using them for in this repository.
%----------------------------------------------------------------------
%- formattedWarning - remove NotifierManager reference ...
%- user32           - currently we don't support class copying ...
%                     Ideally we wouldn't need this function at all ...

MATLAB_ROOT_PATH_NAME = 'matlab_code'; %Used to ensure correct path location
RNEL_FUNCTIONS_FOLDER = 'RNEL_functions';

methods = {
    'cellArrayToString'         %processVarargin()
    'createOpenToLineLink'      %formattedWarning()
    'getCallingFunction'        %formattedWarning()    
    'getCygwinPath'             %NEURON.createNeuronPath()
    'getMyPath'                 %NEURON.paths, initialize.m
    'getPropFileAsStruct'       %NEURON.user_options
    'readDelimitedFile'         %NEURON.user_options
    'goDebug'                   %Jim needs this
    'handle_light'              %NEURON
    'ismember_str'              %processVarargin()
    'processVarargin'           %used everywhere ...
    'strtools.propsValuesToStr' %NEURON.cmd , 
    'round2'                    %activation_volume (in xstim)
    'load2'
    'unique2'                   %NEURON.extracellular_stim_electrode.getMergedStimTimes
    };

my_path          = fileparts(mfilename('fullpath')); 
matlab_root_path = fileparts(fileparts(my_path));

[~,cur_dir_name] = fileparts(matlab_root_path);

if ~strcmp(cur_dir_name,MATLAB_ROOT_PATH_NAME)
%This is a check just in case we move this file.
%I've already moved this function once to try and clean things up
    error('Function path relative to library functions path has changed')
end

base_functions_directory = fullfile(matlab_root_path,RNEL_FUNCTIONS_FOLDER);

%Create a copy locally
%--------------------------------------------------------------------------
nMethods = length(methods);
for iMethod = 1:nMethods
   cur_method       = methods{iMethod};
   method_full_path = which(cur_method);  %This assumes that functions
   %in the repository are not on the path, which should be true if the
   %initialize() function is used.
   
   method_parts      = regexp(cur_method,'\.','split');
   method_parts{end} = [method_parts{end} '.m'];
   
   %For packages, such as a.b, replace path/a/b with path/+a/b
   %-----------------------------------------------------------------------
   %NOTE: This essentially forces an assumption of packages, not classes
   %and would need to be modified if we started using both
   if length(method_parts) > 1
      method_parts(1:end-1) = cellfun(@(x) ['+' x],method_parts(1:end-1),'un',0); 
   end
   
   new_method_path = fullfile(base_functions_directory,method_parts{:});
   disp(new_method_path);
   
   %NOTE: Need to handle folder creation for packages
   if length(method_parts) > 1
       new_dir = fileparts(new_method_path);
       if ~exist(new_dir,'dir')
          mkdir(new_dir)
       end
   end
   
   %TODO: 
   %1) Check if files are different - if both exist
   %2) if different, use git to check for local change
   %    and add to list of things not overridden
   copyfile(method_full_path,new_method_path)
end