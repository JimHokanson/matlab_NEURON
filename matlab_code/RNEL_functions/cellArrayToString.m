function str = cellArrayToString(cellArray,delimiter,noInterp,varargin)
%cellArrayToString  Converts a cell array of strings to a single string.
%
%   STRING = cellArrayToString(CELL_ARRAY, *delimiter, *noInterp, varargin)
%   Converts a CELL_ARRAY of strings to a single string with DELIMITERs 
%   between entries.  
%
%   CELL_ARRAY : cell array of strings
%
%
%   OPTIONAL INPUTS
%   =======================================================================
%   delimiter  : (default comma), delimiter to use between strings
%                 An empty delimiter will use the default, if a truly empty
%                 delimiter is required this function is not needed
%                 str = [cellArray{:}];
%   noInterp   : (default false), if true, doesn't interpret the input
%                 string, for example if you want to insert \t and not tab,
%                 you can input \t as the DELIMITER, and set NO_INTERP to
%                 true
%
%   EXAMPLE
%   =============================================
%   cellArray = {'one' 'two' 'three'};
%   delimiter = ',';
%   str = cellArrayToString(cellArray,delimiter);
%   
%   str = 'one,two,three'
%
%   cellArrayToString({'1' '2'},'\t',true)
%   str => '1\t2'
%   
%   cellArrayToString({'1' '2'},'\t',false)
%   str => '1	2'
%
%   See also: 
%       stringToCellArray
%       cellArrayMatrixToString
%   
%   tags: cell, text

if nargin < 2 || isempty(delimiter)
   delimiter = ','; 
end

if nargin < 3
    noInterp = false;
end

if isempty(cellArray)
    str = '';
else
    if ~iscell(cellArray)
       error('Input to %s must be a cell array',mfilename) 
    end
    P = cellArray(:)' ; 
    if noInterp
        P(2,:) = {delimiter};
    else
        P(2,:) = {sprintf([delimiter '%s'],'')} ;  %Added on printing to handle things like \t and \n
    end
    P{2,end} = [] ; 
    str = sprintf('%s',P{:});
end
