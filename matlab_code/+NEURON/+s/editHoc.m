function editHoc()
%
%   INPUTS
%   =======================================================================
%   1) relative file - with .hoc extension or without any
%           -> open hoc file in code base
%   2) same as 1, but with model directory
%           -> requires model to directory resolution function
%   3) absolute filepath
%
%
%   FULL PATH:
%   NEURON.edit

uo = NEURON.user_options;

if isempty(uo.hoc_editor)
    error('Hoc editor must be specified to edit hoc files')
end

error('Function is not yet finished')