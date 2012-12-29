function s = getPropFileAsStruct(filePath,delimiter)
%getPropFileAsStruct Meant to be a simple interface for reading properties
%
%   s = getPropFileAsStruct(filePath, *delimiter)
%
%   INPUTS
%   ========================================================
%   filePath : path to file
%   
%   OPTIONAL INPUTS
%   ========================================================
%   delimiter : (default ':') delimiter between properties and values
%
%   OUTPUTS
%   ========================================================
%   s : (structure)
%
%   IMPORTANT USAGE NOTES
%   =========================================================
%   1) All first column names must evaluate to valid fields
%   2) Non-significant whitespace (on either end) is ignored
%
%   EXAMPLE
%   =========================================================
%   file contents:
%   a= 2
%   b=3
%   c =testing
%   
%   produces
%   s.a = '2'
%   s.b = '3'
%   s.c = 'testing'
%   

if ~exist('delimiter','var')
    delimiter = ':';
end
    
temp = readDelimitedFile(filePath,delimiter,...
    'merge_lines',true,'strtrim_all',true,...
    'single_delimiter_match',true);

values = temp(:,2);
fields = temp(:,1);

s = cell2struct(values,fields);

end