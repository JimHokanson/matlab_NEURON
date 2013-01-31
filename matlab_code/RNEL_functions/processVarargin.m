function [in,extras] = processVarargin(in,v,varargin)
%processVarargin  Processes varargin and overrides defaults
%
%   Function to override default options.
%
%   [in,extras] = processVarargin(in,v,varargin) %SEE INPUTS as this is a
%   bit different convention than other functions
%
%   INPUTS
%   =======================================================================
%   in       : defaults structure
%   v        : varargin input from calling function, prop/value or structure with fields
%   varargin : see optiona inputs, prop/value or structure with fields
%
%   OPTIONAL INPUTS (specify via prop/value pairs)
%   =======================================================================
%   case_sensitive    : (default false)
%   allow_duplicates  : (default false) NOT YET IMPLEMENTED
%   partial_match     : (default false) NOT YET IMPLEMENTED
%   allow_non_matches : (default false) 
%
%   OUTPUTS
%   =======================================================================
%   extras
%       .non_matches : (cellstr), list of non matches, only non-empty 
%                       if allow_non_matches is true
%
%   EXAMPLES
%   =================================================================
%   1)
%   function test(varargin)
%   in.a = 1
%   in.b = 2
%   in = processVarargin(in,varargin,'allow_duplicates',true)
%
%   Similar functions:
%   http://www.mathworks.com/matlabcentral/fileexchange/22671
%   http://www.mathworks.com/matlabcentral/fileexchange/10670
%
%   IMPROVEMENTS
%   ===============================================================
%   1) For non-matched inputs, provide link to offending caller
%   2) Allow notation which only applies values to matching class
%           - what about subclasses or type? - provide different notation
%           - something like:
%                 - for function name matching
%                 ...,'@function_name',{'prop_a',1,'prop_b',2},'prop_local',true
%                 - for class matching
%                 ...,'#'
%                 Importantly these would not throw an error and if found
%                 would run extra code to determine evaluation ...

c.case_sensitive    = false;
c.allow_duplicates  = false;
c.partial_match     = false;
c.allow_non_matches = false;

%Update options using helper function
c = processVararginHelper(c,varargin,c,1);

%Update optional inputs of calling function with this function's options now set
[in,extras] = processVararginHelper(in,v,c,nargout);

end

function [in,extras] = processVararginHelper(in,v,c,nOut)

if nOut == 2
    extras             = struct; 
    extras.non_matches = {};
else
    extras = []; 
end

%Checking the optional inputs, either a structure or a prop/value cell
%array is allowed, or various forms of empty ...
if isempty(v)
    %do nothing
    parse_input = false;
elseif isstruct(v)
    %This case should generally not happen
    %It will if varargin is not used in the calling function
    parse_input = true;
elseif isstruct(v{1}) && length(v) == 1
    %Single structure was passed in as sole argument for varargin
    v = v{1};
    parse_input = true;
elseif iscell(v) && length(v) == 1 && isempty(v{1})
    %User passed in empty cell option to varargin instead of just ommitting input
    parse_input = false;
else
    parse_input = true;
    isStr  = cellfun('isclass',v,'char');
    if ~all(isStr(1:2:end))
        error('Unexpected format for varargin, not all properties are strings')
    end
    
    if mod(length(v),2) ~= 0
        error('Property/value pairs are not balanced, length of input: %d',length(v))
    end
    v = v(:)';
    v = cell2struct(v(2:2:end),v(1:2:end),2);
end

%NOTE: Need to be careful if we ever add on more outputs to the 
%structure "extras" later on since we are returning here
if ~parse_input
   return 
end

%At this point we should have a structure ...
fn_v = fieldnames(v);
fn_i = fieldnames(in);

%Matching location
%----------------------------------------
if c.case_sensitive
	[isPresent,loc] = ismember_str(fn_v,fn_i);
else
    [isPresent,loc] = ismember_str(upper(fn_v),upper(fn_i));
    %NOTE: I don't currently do a check here for uniqueness of matches ...
    %Could have many fields which case-insensitive are the same ...
end

if ~all(isPresent)
    if c.allow_non_matches
        extras.non_matches = fn_v(~isPresent);
    else
        %NOTE: This would be improved by adding on the restrictions we used in mapping
        badVariables = fn_v(~isPresent);
        error(['Bad variable names given in input structure: ' ...
            '\n--------------------------------- \n %s' ...
            ' \n--------------------------------------'],...
            cellArrayToString(badVariables,','))
    end
end

%Actual assignment
%---------------------------------------------------------------
for i = 1:length(fn_v)
    if isPresent(i)
    %NOTE: By using fn_i we ensure case matching
    in.(fn_i{loc(i)}) = v.(fn_v{i});
    end
end

end
