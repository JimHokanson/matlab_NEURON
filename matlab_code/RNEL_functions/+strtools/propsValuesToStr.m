function str = propsValuesToStr(props,values,varargin)
%propsValuesToStr
%
%   str = strtools.propsValuesToStr(props,values,varargin)
%
%   OPTIONAL INPUTS
%   ================================================
%   prop_value_delimiter  : (default '=')
%   pair_delimiter        : (default ' ')
%
%   NOTE: Currently both delimiters are treated as literals and are not
%   intepreted ...
%
%   EXAMPLE
%   ====================================================
%   str = strtools.propsValuesToStr({'aasd','best'},{'123' 'asdfset1asdfasdf'})
%   aasd=123 best=asdfset1asdfasdf

%INPUT HANDLING
%=============================================
if ischar(props)
    props = {props};
end

if ischar(values)
    values = {values};
end

if ~iscellstr(props) || ~iscellstr(values)
    error('Both inputs must be cell arrays of strings')
end

%NOTE: These are not processed ...
in.prop_value_delimiter = '=';
in.pair_delimiter = ' ';
in = processVarargin(in,varargin);

%Initialization of the length
%========================================================
prop_lengths  = cellfun('length',props);
value_lengths = cellfun('length',values);
pv_delim_l    = length(in.prop_value_delimiter);
p_delim_l     = length(in.pair_delimiter);

nPairs = length(props);

if nPairs ~= length(values);
    error('Properties and Values must match in length\n%d Props Observed, %d Values Observed',...
        nPairs,length(values))
end

delimSpace = pv_delim_l*(nPairs) + p_delim_l*(nPairs-1);

%Initialization ----------------------------
str = blanks(delimSpace + sum(prop_lengths) + sum(value_lengths));
curIndex = 0;


%To avoid structure indexing in a loop :/
prop_value_delimiter = in.prop_value_delimiter;
pair_delimiter       = in.pair_delimiter;

for iProp = 1:nPairs
    str(curIndex+1:curIndex+prop_lengths(iProp)) = props{iProp};
    curIndex = curIndex + prop_lengths(iProp);
    
    str(curIndex+1:curIndex+pv_delim_l) = prop_value_delimiter;
    curIndex = curIndex + pv_delim_l;
    
    str(curIndex+1:curIndex+value_lengths(iProp)) = values{iProp};
    
    %NOTE: We don't want to added on a pair delimiter for the last value
    %...
    if iProp ~= nPairs
        curIndex = curIndex + value_lengths(iProp);
        str(curIndex+1:curIndex + p_delim_l) = pair_delimiter;
        curIndex = curIndex + p_delim_l;
    end
end





end