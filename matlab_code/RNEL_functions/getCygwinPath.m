function cygPath = getCygwinPath(filePath,varargin)
%getCygwinPath Creates a cygwin path
%
%   This function is meant for windows ...
%
%   cygPath = getCygwinPath(filePath,varargin)
%
%   This might need some to introduce some defaults that can be changed ...

%Change all \ to /, drop the colon
tempFilePath = regexprep(filePath,'\\','/');
cygPath = ['/cygdrive/' tempFilePath(1) tempFilePath(3:end)];

