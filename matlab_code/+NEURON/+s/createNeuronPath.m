function file_path = createNeuronPath(file_path)
%NEURON_createNeuronPath
%
%   file_path = NEURON.s.createNeuronPath(file_path)
%
%   NOTE: This function should provide a path that is safe for
%   passing into Neuron. This basically involves creating a
%   cygwin path for windows.

%TODO: get neuron version ... and maybe escape if older version ...

if ispc
    %It appears as though only forward slashes or ok ...
    file_path = regexprep(file_path,'\\','/');
    %TODO: At somet point this was necessary ...
    %This causes problems with 7.7
    %file_path = NEURON.sl.dir.getCygwinPath(file_path);
end


end