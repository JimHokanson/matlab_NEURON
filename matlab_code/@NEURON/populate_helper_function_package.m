function populate_helper_function_package
%
%
%   NEURON.populate_helper_function_package
%
%   USAGE NOTES:
%   ======================================================================
%	1) This is only setup to work with the RNEL functions on the path and
%	the local toolbox functions not on the path, which should normally be
%	the case if you have access to the RNEL functions as the initializer
%	(see initialize.m in root directory) won't add the local copies ...
%
%   2) Only copying of functions or partial packages are currently
%   supported.

%NOTE: I might want some simple methods
%to be modified and moved here
%- formattedWarning - remove NotifierManager reference ...

RNEL_FUNCTIONS_FOLDER = 'RNEL_functions';

methods = {
    'cellArrayToString'         %processVarargin()
    'createOpenToLineLink'      %formattedWarning()
    'getCallingFunction'        %formattedWarning()    
    'getCygwinPath' 
    'getMyPath'                 %NEURON.paths, initialize.m
    'ismember_str'              %processVarargin()
    'processVarargin'           %used everywhere ...
    'strtools.propsValuesToStr' %NEURON.cmd , 
    'load2'
    };



my_path          = fileparts(mfilename('fullpath')); %This will return the
%path to the @NEURON directory ...
matlab_root_path = fileparts(my_path);

base_directory = fullfile(matlab_root_path,RNEL_FUNCTIONS_FOLDER);

%TODO: For each of these functions create a copy in the RNEL package

nMethods = length(methods);
for iMethod = 1:nMethods
   cur_method       = methods{iMethod};
   method_full_path = which(cur_method);
   
   method_parts      = regexp(cur_method,'\.','split');
   method_parts{end} = [method_parts{end} '.m'];
   
   if length(method_parts) > 1
      method_parts(1:end-1) = cellfun(@(x) ['+' x],method_parts(1:end-1),'un',0); 
   end
   
   new_method_path = fullfile(base_directory,method_parts{:});
   disp(new_method_path);
   
      %NOTE: Need to handle folder creation ...
   if length(method_parts) > 1
       mkdir(fileparts(new_method_path))
   end
   
   copyfile(method_full_path,new_method_path)
   
end