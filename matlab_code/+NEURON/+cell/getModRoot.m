function root = getModRoot(name)
%
%   root = NEURON.cell.getModRoot(name)
%
%   Inputs
%   ------
%   name : string
%       'mrg'
%
%   Example
%   -------
%   root = NEURON.cell.getModRoot('mrg')

p = NEURON.paths.getInstance();

switch lower(name)
    case 'mrg'
        root = fullfile(p.hoc_code_model_root,'MRG_Axon','mod_files');
end


end