function file_path = createNeuronPath(file_path)
%NEURON_createNeuronPath
%
%   file_path = NEURON_createNeuronPath(file_path)
%
%   NOTE: This function should provide a path that is safe for
%   passing into Neuron. This basically involves creating a
%   cygwin path for windows.


if ispc
    file_path = NEURON.sl.dir.getCygwinPath(file_path);
end
end