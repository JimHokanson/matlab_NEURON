function s = getMyPath(fName)
%getMyPath  Returns path of calling function or script.
%   
%   FORMS
%   1) 
%   S = getMyPath
%
%   2) Useful for executing in a script where you want the script path
%   S = getMyPath('myFileName')
%   
%   S - Contains only the path, not a filename
%       When called from a script or command line returns the current directory
%
%   Replaces: fileparts(mfilename('fullpath')) 
%
% tags: path, directory, dupe
% see also: getMfileDirectory

%NOTE: the function mfilename() can't be used with evalin
%   (as of 2009b)

if nargin == 0
stack = dbstack('-completenames');
if length(stack) == 1
    s = cd;
else
    s = fileparts(stack(2).file);
end
else
   filePath = which(fName);
   s = fileparts(filePath);
end
