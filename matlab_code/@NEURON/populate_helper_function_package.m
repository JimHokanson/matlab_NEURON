function populate_helper_function_package

%NOTE: I might want some simple methods
%to be modified and moved here
%- formattedWarning - remove NotifierManager reference ...
%-

RNEL_FUNCTIONS_FOLDER = 'RNEL_functions';
PERMANENT_SUB_FOLDER  = 'permanent';

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

%NOTE: I need to support packages ... strtools.propsValuesToStr

my_path          = fileparts(mfilename('fullpath')); %This will return the
%path to the @NEURON directory ...
matlab_root_path = fileparts(my_path);

base_directory = fullfile(

%TODO: For each of these functions create a copy in the RNEL package