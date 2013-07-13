function varargout = PLOT_imagescToPatch(imageHandle,deleteOriginal)
% PLOT_IMAGESCTOPATCH Transform an image into a set of patches
%
%   PLOT_imagescToPatch(imageHandle,*deleteOriginal)
%
%   This function was designed to make exporting and image to Adobe
%   Illustrator more palatable
%
%   It is assumed that the image was the lowest/deepest/bottom object on
%   the axis, so the resulting patches are placed on the bottom.  If you
%   had original occluded an object with the image it will be visible
%
% INPUTS
% =========================================================================
%   imageHandle    - (handle) graphics handle, either the image itself, or the
%       owning figure/axis.
%   deleteOriginal - (logical) Default: false. Delete source image yes/no
%
% OUTPUTS
% =========================================================================
%   CAA TODO These only support a single imagesc at a time ( only values
%   from last iteration are saved)
%   handles  - (handle) handles of created patches, returned in column major
%   order
%   value  - (handle) value of the patch
%
%
% tags: post process,imagesc,image, figure, plot
% see also: uistack
if nargin < 1
    imageHandle = findobj('type','image','-not','tag','TMW_COLORBAR');
end


% verify whether or not this
if all(ishandle(imageHandle))
    if all(isprop(imageHandle,'type'))
        if ~all(strcmp(get(imageHandle,'type'),'image'))
            imageHandle = findobj(imageHandle,'type','image','-not','tag','TMW_COLORBAR');
            assert(~isempty(imageHandle),'Supplied Axis did not contain an image object')
        end
    else
        error('Could not find image object children within input ''ImageHandle''')
    end
else
    error(' Input ''ImageHandle'' must be an handle object of some types')
end

for iiImage = 1:length(imageHandle)
    this_image = imageHandle(iiImage);
    s    = get(this_image);
    parent = s.Parent;
    
    if ~strcmp('scaled',s.CDataMapping)
        error('I haven''t done setup this code for non-scaled data')
    end
    
    xData  = s.XData;
    yData  = s.YData;
    %Yikes, XData

    xHWidth = 0.5*(xData(end)-xData(1))/(size(s.CData,2)-1);
    yHWidth = 0.5*(yData(end)-yData(1))/(size(s.CData,1)-1);

    xData = linspace(xData(1)-xHWidth,xData(end)+xHWidth,size(s.CData,2)+1);
    yData = linspace(yData(1)-yHWidth,yData(end)+yHWidth,size(s.CData,1)+1);
    
    sz = size(s.CData);

    h = patch(surf2patch(xData,yData,zeros(sz(1)+1,sz(2)+1),s.CData),'parent',parent);
    
    %set(h,'EdgeColor','none')
    %set(h,'FaceColor','none')
    
    shading flat
    
    delete(this_image)
end

if nargout >= 1
    mask = hAll ~= 0;
    varargout{1} = hAll(mask);
    if nargout >= 2
        varargout{2} = values(mask);
    end
end
end
