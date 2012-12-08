function params = NEURON_readParamsFile(model,hocFileName,variable_file_name)
%NEURON_readParamsFile
%
%   params = NEURON_readParamsFile(model,hocFileName, *variable_file_name)
%
%   DOCUMENTATION NEEDED
%
%
%   NOTE: This does not currently support ignoring variables from multiline
%   quotes
%   

%CODE NEEDS DOCUMENTATION ...
persistent p_params p_file_str p_variable_file_path

if ~exist('variable_file_name','var')
    variable_file_name = '';
end

neuronPaths = NEURON_getPaths(model,hocFileName,variable_file_name);

if ~exist(neuronPaths.variable_file_path,'file')
    error('Hoc variable file: "%s", does not exist',neuronPaths.variable_file_path)
end

file_str = fileread(neuronPaths.variable_file_path);

if strcmp(p_variable_file_path,neuronPaths.variable_file_path) && isequal(file_str,p_file_str)
   params = p_params;
   return
end

lines = regexp(file_str,'\r\n|\n','split');
if ~isempty(lines) && isempty(lines{end})
   lines(end) = []; 
end

p_variable_file_path = neuronPaths.variable_file_path;
p_file_str = file_str;

params = cellfun(@parseVariableName,lines,'un',0);

params(cellfun('isempty',params)) = [];

p_params = params;

end

function var_name = parseVariableName(str)

comment_I = strfind(str,'//');

%Might be able to make faster if finding equals as well ...
%and then if no equals, skipping, if // before equals, skipping
%otherwise going to the first equals

if isempty(comment_I)
    comment_I = length(str) + 1;
end

var_name = regexp(str(1:comment_I-1),'(\<[^\s=].*)\s*=','tokens','once');
if isempty(var_name)
    var_name = '';
else
    var_name = var_name{1};
end

end