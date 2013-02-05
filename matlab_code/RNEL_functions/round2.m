function z = round2(x,y,fhandle)
%round2  Rounds number to nearest multiple of arbitrary precision.
%
%   Rounds x to the nearest multiple of y.
%
%   z = round2(x,y,*fhandle)
%
%   OPTIONAL INPUTS
%   =======================================================================
%   fhandle : (default: @round) Function handle to use instead of round.
%             Recommended values are @floor, @ceil, @fix
%
%
%Example 1: round PI to 2 decimal places
%   >> round2(pi,0.01)
%   ans =
%         3.14
%
%Example 2: round PI to 4 decimal places
%   >> round2(pi,1e-4)
%   ans =
%         3.1416
%
%Example 3: round PI to 8-bit fraction
%   >> round2(pi,2^-8)
%   ans =
%         3.1406
%
%Examples 4-6: round PI to other multiples
%   >> round2(pi,0.05)
%   ans =
%         3.15
%   >> round2(pi,2)
%   ans =
%         4
%   >> round2(pi,5)
%   ans =
%         5 
%
% See also ROUND.

%% defensive programming

if prod(size(y))>1
  error('n must be scalar')
end

if ~exist('fhandle','var')
   fhandle = @round; 
elseif ~isa(fhandle,'function_handle')
   error('Input fhandle must be a function handle')
end

%%
%z = round(x./y).*y;

z = fhandle(x./y).*y;
