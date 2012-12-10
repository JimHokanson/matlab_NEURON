function initialize
% INITIALIZE Initialize the NEURON toolbox

%Addition of main Matlab code folder ...
my_path          = fileparts(mfilename('fullpath'));
matlab_code_path = fullfile(my_path,'matlab_code');
addpath(matlab_code_path);

%Addition of functions for users without access to RNEL files
if ~exist('RNEL_LIBRARY.txt','file')
    addpath(fullfile(matlab_code_path,'RNEL_functions'))
    addpath(fullfile(matlab_code_path,'RNEL_functions','permanent'))
end

end