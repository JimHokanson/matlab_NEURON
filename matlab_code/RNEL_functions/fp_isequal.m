function flag = fp_isequal(A,B,small,onAll)
% fp_isequal  Determine equality of two floating point numbers within an epsilon
%
%   flag = fp_isequal(A,B,*small,*onAll)
%
%   INPUTS
%   =======================================================================
%   A     : (numeric) operand A
%   B     : (numeric) operand B, A & B must be the same size
%   
%   OPTIONAL INPUTS
%   =======================================================================
%   small : (numeric, default 2*eps) the maximum allowable deviation between 
%            the two operands before that are considered not equal
%   onAll : (default false), if true, computes whether the entire matrix
%           is equal or not
%
%   OUTPUT
%   =========================================================================
%   flag  : (logical) whether or not the operands were equal
%
% tags: precision
% see also: fp_isinteger

if nargin < 3 || isempty(small)
    small = 2*eps;
end

if nargin < 4 || isempty(onAll)
    onAll = false;
end

flag = abs(A - B) <= small;

if onAll
    flag = all(flag(:));
end

end