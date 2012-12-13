function varargout = load2(filepath,varargin)
%load2 Because you can always use a little more loading
%
%   This function allows one to load variables directly 
%   from a file. See notes below.
%
%   varargout = load2(filepath,varargin)
%
%   WHY USE THIS FUNCTION
%   =====================================================
%   More succinct code can help with reading files and understanding what
%   is going on in those files. This function tries to help minimize these
%   lines.
%
%   Other approaches might include:
%   1) load(filepath)
%   NOTE: This option "poofs" variables into existence and it isn't clear
%   what is loaded. This can be mitigated with the following
%   2) load(filepath,'test','variable_2')
%   This seems like it should be fine but the editor and perhaps the
%   interpreter don't seem to realize that this creates variables, which
%   leads to mlint warnings
%   Try this example:
%   load(filepath,'str')
%   str = str + 2;
%   3) The best approach is the following
%   h = load(filepath);
%   test = h.test;
%   variable_2 = h.variable_2;
%
%   However now we have 3 lines of code :/
%   
%   The following can be written as:
%   [test,variable_2] = load2(filepath,'test','variable_2');
%
%
%   EXAMPLE
%   =====================================================
%   [data,version] = load2(filepath,'data','version')


if ~exist(filepath,'file')
    error('Specified file does not exist:\n%s',filepath)
end

h = load(filepath);

varargout = cell(size(varargin));

for iInput = 1:numel(varargin)
   varargout{iInput} = h.(varargin{iInput}); 
end


end