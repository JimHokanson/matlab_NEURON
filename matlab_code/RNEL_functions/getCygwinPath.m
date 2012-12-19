function cygPath = getCygwinPath(filePath,varargin)
%getCygwinPath Creates a cygwin path
%
%   This function is meant for windows ...
%
%   cygPath = getCygwinPath(filePath,varargin)
%
%   This might need some to introduce some defaults that can be changed ...

if ~ispc
    error('Function not designed for non-pc calls')
end

%Change all \ to /, drop the colon
tempFilePath = regexprep(filePath,'\\','/');

%For absolute paths ...
%e.g. C:\ to /cygdrive/c/
if length(filePath) > 2 && filePath(2) == ':'
    cygPath = ['/cygdrive/' tempFilePath(1) tempFilePath(3:end)];
end

