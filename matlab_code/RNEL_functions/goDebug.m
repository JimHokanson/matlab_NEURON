function goDebug
%goDebug
%       
%   goDebug
%
%   Opens the editor to the location of a keyboard or bottom
%   of error stack
%   
%   ?? Rename function???

s = dbstack('-completenames');

%We want to go to the 2nd guy at the line
fullFilePath = which(s(2).file);
matlab.desktop.editor.openAndGoToLine(fullFilePath,s(2).line);


