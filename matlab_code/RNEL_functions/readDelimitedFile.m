function [output,extras] = readDelimitedFile(filePath,delimiter,varargin)
%readDelimitedFile  Reads a delimited file
%
%   Simple interface to regexp with some post-processing options for
%   reading a delimited file OR DELIMITED STRING.
%
%   FORMS ===========================================================
%   [output,extras] = readDelimitedFile(filePath,delimiter,varargin)
%
%   %Ugly hack to process input as string
%   [output,extras] = readDelimitedFile({'str' str_data},delimiter,varargin)   
%   In this case 
%   
%   EXAMPLES
%   ========================================================
%   readDelimitedFile(filePath,'\s*:\s*') - read file with a ':' delimiter
%       that might have space on either side ...
%
%   INPUT
%   ========================================================
%   filePath  : path to the file to read
%   delimiter : delimiter to use in reading the file
%
%   OPTIONAL INPUTS
%   ========================================================
%   merge_lines  : (default true), if true returns a cell array matrix
%                  if false, returns a cell array of cell arrays
%   header_lines : (default 0), if non-zero then the lines should be
%           rerned without processing
%   default_ca   : (default ''), the default empty entry for a cell array
%                   This is used when creating a matrix with rows that
%                   don't have the same number of columns
%   deblank_all  : (default false), if true uses deblank() on all entries
%   strtrim_all  : (default false), if true uses strtrim() on all entries
%   remove_empty_lines : (default false), if true, removes empty lines
%                         see Implementation Notes
%   row_delimiter : (default '\r\n|\n'), goes into regexp to get lines of
%                   delimited file ...
%   make_row_delimiter_literal : (default false), if true then backslashes
%       will be converted so that they are treated as backslashes during
%       matching, i.e. instead of \n matching a newline, it will match \n
%   make_delimiter_literal : (default false), same effect as above
%       property, just for the column delimiter
%   single_delimiter_match : (default false), true can be used
%       for property value files ...
%
%   OUTPUTS
%   ========================================================
%   output : either a 
%               - cellstr matrix {'a' 'b'; 'c' 'd'}
%               - cell array of cellstr {{'a' 'b'} {'c' 'd'}}
%               See merge_lines input
%   extras : (structure)
%       .raw           - raw text from file
%       .header_lines  - first n lines, see "header_lines" optional input
%   
%   IMPLEMENTATION NOTES
%   =========================================================
%   1) The last line if empty is always removed ...
%   2) Removal of empty lines is done before delimiter parsing, not
%   aftewards, i.e. a row with only delimiters will not be removed ...
%   
%   IMPROVEMENTS
%   =========================================================
%   - pass the read text into a string function, instead of the current hack of 
%   using this function both for files and strings ...
%
%   See Also:
%       


in.merge_lines  = true;
in.header_lines = 0; %NYI
in.default_ca   = '';
in.deblank_all  = false;
in.strtrim_all  = false;
in.row_delimiter = '\r\n|\n';
in.make_row_delimiter_literal = false;
in.make_delimiter_literal = false;
in.remove_empty_lines = false;
in.single_delimiter_match = false;
in = processVarargin(in,varargin);

%Obtaining the text data
%--------------------------------------------------------------------
if iscell(filePath)
    if length(filePath) == 2 && strcmp(filePath{1},'str')
       text = filePath{2}; 
    else
        error('Cell entry to readDelimitedFile should be of form {''str'' str_data}')
    end
else
    if ~exist(filePath,'file')
        error('Missing file %s',filePath)
    end

    text = fileread(filePath);
end

%Fixing delimiters
%-------------------------------------------------------
if in.make_row_delimiter_literal
    in.row_delimiter = regexptranslate('escape',in.row_delimiter);
end

if in.make_delimiter_literal
    delimiter = regexptranslate('escape',delimiter);
end

%Lines handling
%--------------------------------------------------------
lines = regexp(text,in.row_delimiter,'split');

if in.header_lines > 0
   extras.header_lines = lines(1:in.header_lines);
   lines(1:in.header_lines) = [];
end

if isempty(lines{end})
    lines(end) = [];
end

if in.remove_empty_lines
   lines(cellfun('isempty',lines)) = [];
end

nLines = length(lines);

%Delimiter handling 
%------------------------------------------------------
if in.single_delimiter_match
    temp = regexp(lines,delimiter,'split','once');
else
    temp = regexp(lines,delimiter,'split');
end
%1st layer, lines, 
%2nd layer should be columns

%OLD CODE: Might eventually be useful
%NOTE: This required reconstructing the delimiter
% if in.max_delimiters_per_line > 0
%    %ex. one delimiter splits two entries
%    max_entries = in.max_delimiters_per_line + 1;
%    for iLine = 1:nLines
%       cur_entry = temp{iLine};
%       if length(cur_entry) > max_entries
%          cur_entry{max_entries} = [cur_entry{max_entries:end}];
%          cur_entry(max_entries+1:end) = [];
%          temp{iLine} = cur_entry;
%       end
%    end
% end


if in.strtrim_all || in.deblank_all
    if in.strtrim_all && in.deblank_all
        error('Only one space removal option should be set')
    elseif in.strtrim_all
        fHandle = @strtrim;
    else
        fHandle = @deblank_all;
    end
    
   for iLine = 1:nLines
      temp{iLine} = cellfun(fHandle,temp{iLine},'un',0); 
   end
end

if in.merge_lines
   %Get the length of each cell array
   %Make a matrix from all lines
   nEach  = cellfun('length',temp);
   output = cell(nLines,max(nEach));
   output(:) = {in.default_ca};
   for iLine = 1:nLines
      output(iLine,1:nEach(iLine)) = temp{iLine}; 
   end
end

extras.raw = text;