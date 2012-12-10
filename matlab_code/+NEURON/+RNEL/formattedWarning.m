function varargout = formattedWarning(messageStr,varargin)
%formattedWarning create a Formatted warning with a link to the calling method
%
% formattedWarning(messageStr,formatStr)
% prints a warning with an open to link link in the form of
% [WARNING <file>:<line> ] <message>
%
% str = formattedWarning(messageStr)
%
% If an output is requested output is quenched.
%
%
% tags: text, display
% See Also: 
%   getCallingFunction
%   createOpenToLineLink

%NOTE: This function is modified from the RNEL version in that it does not
%use the NotifierManager.

if nargin > 1
    messageStr = sprintf(messageStr,varargin{:});
end
[name, file, line] = getCallingFunction;
link_txt = sprintf('%s.m:%d',name,line);
% check if java is enabled ( it is usually on ), if it is print a nice link 
% to the code, otherwise print the raw text.  This helps when 

if usejava('desktop')
    link_str = createOpenToLineLink(file,line,link_txt);
else
    link_str = link_txt;
end

warning_str = sprintf('[WARNING %s] %s', link_str, messageStr);

if nargout < 1
    fprintf(2,'%s\n',warning_str);
else
    varargout{1} = warning_str;
end
