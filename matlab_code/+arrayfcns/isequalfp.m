function flag = isequalfp(A,B,small)
% fp_isequal  Determine equality of two floating point numbers within an epsilon
%
%   flag = isequalfp(A,B,*small,)
%
%   INPUTS
%   =======================================================================
%   A     : (numeric) operand A
%   B     : (numeric) operand B
%   
%   OPTIONAL INPUTS
%   =======================================================================
%   small : (numeric, default 2*eps) the maximum allowable deviation between 
%            the two operands before that are considered not equal
%
%   OUTPUT
%   =========================================================================
%   flag  : (logical) whether or not the operands were equal
%
%   FULL PATH:
%       arrayfcns.isequalfp
%
% tags: precision
% see also: fp_isinteger

if nargin < 3 || isempty(small)
    small = 2*eps;
end

if ~isequal(size(A),size(B))
    flag = false;
else
    flag = all(abs(A(:) - B(:)) <= small);
end