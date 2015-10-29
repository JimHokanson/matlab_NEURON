function [x_new,dy] = getDerivative(x,y,x_dt,varargin)
%
%   [x_new,dy] = arrayfcns.getDerivative(x,y,x_dt,varargin)
%   
%   INPUTS
%   =======================================================================
%   x    - series on which the data is based
%   y    - values to take the derivative of
%   x_dt - 
%
%   OPTIONAL INPUTS
%   =======================================================================
%   method : (default 'pchip') interpolation method for upsampling before
%            taking the derivative

in.method = 'pchip';
in = NEURON.sl.in.processVarargin(in,varargin);

x_temp = x(1):x_dt:x(end);

y_new = interp1(x,y,x_temp,in.method);

%Take the derivative and convert to meaningful units
dy = diff(y_new)./x_dt;

x_new = x_temp(2:end) - x_dt/2;