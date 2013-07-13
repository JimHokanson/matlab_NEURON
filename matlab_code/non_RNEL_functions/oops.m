function oops

%1) Which file is open in the editor and active?

active_doc = matlab.desktop.editor.getActive;
active_doc.close();

%Bug ????
evalin('caller','dbquit');
%dbquit;

%Close open function
%dbquit