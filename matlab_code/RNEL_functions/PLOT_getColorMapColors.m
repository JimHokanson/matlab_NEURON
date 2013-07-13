function output = PLOT_getColorMapColors(range,values)
%PLOT_getColorMapColors  Computes colors for each value based on the range and current colormap
%
%   NOTE: This function was created for setting up a discrete color bar, in
%   which it was desirable to know the color value for a specific discrete
%   set of values, given the used range
%
%   COLORS = PLOT_getColorMapColors(RANGE,VALUES)
%
%   INPUTS
%   ================================================
%   RANGE  - (2 element vector), specifies how to map values to the color
%       map, i.e. a value of 2 for a range of [1 3], 2 is halfway through
%       the map, but for a range of [1 100], 2 is very close to the
%       starting value
%   VALUES - matrix of values to map to colors based on the RANGE and the
%       current colormap
%
%   OUTPUTS
%   =================================================
%   COLORS - size of values, plus one dimension of size 3 (R,G,B)
%       - If any of the input values are outside the original range they will be
%       set to the extrema of the range. 
%       - If any of the values are nan, as would occur for transparent
%       patches, they will be returned as nan
%
%   EXAMPLE
%   =================================================
%   %THESE TWO IMAGES SHOULD BE THE SAME
%   %-----------------------------------
%   r = rand(5,5);
%   subplot(2,1,1)
%   imagesc(r)
%   set(gca,'Clim',[0 1])
%
%   subplot(2,1,2)
%   colors = getColorMapColors([0 1],r);
%   image(colors)
%
% tags: visualization, plot
% See Also: colormap

% mask off nans, these arise as a result of a transparent alphamask
mask   = ~isnan(values(:));
output = nan([size(values) 3]);

r = zeros(size(values(mask)));
g = zeros(size(values(mask)));
b = zeros(size(values(mask)));

c = colormap;

x = linspace(range(1),range(2),size(c,1));

% crop values to range. This is necessary if values are outside clim
cropped_values = values(mask);
cropped_values(values(mask) > range(2)) = range(2);
cropped_values(values(mask) < range(1)) = range(1);

r(:) = interp1(x,c(:,1),cropped_values);
g(:) = interp1(x,c(:,2),cropped_values);
b(:) = interp1(x,c(:,3),cropped_values);



output([mask; false(size(mask)); false(size(mask))]) = r;
output([false(size(mask)); mask; false(size(mask))]) = g;
output([false(size(mask)); false(size(mask));mask])  = b;


if isa(output,'double')
    % CAA When color is type double MATLAB assert color >= 0 && color <= 1.0.
    % Due to FP math interp1 can return  numbers out of this range, if only by
    % a miniscule amount. Therefore I threshhold here
    output(output < 0 ) = 0;
    output(output > 1 ) = 1;
end
end