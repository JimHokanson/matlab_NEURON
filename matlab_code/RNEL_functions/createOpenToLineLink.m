function str = createOpenToLineLink(filePath, line, name, varargin)
%createOpenToLineLink  Produces a string, that when printed, creates a link to a specific file and line
%
%   str = createOpenToLineLink(filePath, line, name)
%
%   The created links operate like those produced when an error is thrown.
%
%   INPUTS
%   =======================================================================
%   filePath - (string) full path to file to open
%   line     - (numeric) line in file to open to
%   name     - (string) displayed link text
%
%   OPTIONAL INPUTS
%   =======================================================================
%   text_proceeding_open : text to evaluate before the open to line link
%                        originally implemented for placing keyboard
%                        dynamically 
%
%   POSSIBLE IMPROVEMENTS
%   =======================================================================
%   Newer function: matlab.desktop.editor.openAndGoToLine instead of
%   opentoline
%
% tags: utility, undocumented matlab, text

in.text_proceeding_open = '';
in = processVarargin(in,varargin);

func_name = 'opentoline';
%opentoline(FILENAME, LINENUMBER, COLUMN)
%2011a and newer - matlab.desktop.editor.openAndGoToLine

str = sprintf('<a href="matlab: %s %s(''%s'',%d,1)">%s</a>',...
    in.text_proceeding_open,func_name,filePath, line, name);