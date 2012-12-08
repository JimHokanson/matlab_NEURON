function populate_helper_function_package

%NOTE: I might want some simple methods
%to be modified and moved here
%- formattedWarning - remove NotifierManager reference ...
%- 

methods = {
    'cellArrayToString'         %processVarargin()
    'createOpenToLineLink'      %formattedWarning()
    'getCygwinPath'             
    'getCallingFunction'        %formattedWarning()
    'ismember_str'              %processVarargin()
    'processVarargin'           %used everywhere ...
    'strtools.propsValuesToStr' %NEURON.cmd , 
    'load2'
    };

%TODO: For each of these functions create a copy in the RNEL package