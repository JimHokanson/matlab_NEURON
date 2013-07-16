function [ out ] = gridN( x,y,z,t,xnodes,ynodes,znodes )
%Creates an N dimensional table from the m points in the n*m matrix x.

params.interp = 'linear';
params.regularizer = 'gradient';
params.xscale = 1;
params.yscale = 1;
params.zscale = 1;

% check lengths of the data
n = length(x);
if (length(y)~=n) || (length(z)~=n) || (length(t)~=n)
    error 'Data vectors are incompatible in size.'
end
if n<3
    error 'Insufficient data for surface estimation.'
end

% verify the nodes are distinct %WHY was this needed?
if any(diff(xnodes)<=0) || any(diff(ynodes)<=0) || any(diff(znodes)<=0)
    error 'xnodes and ynodes must be monotone increasing'
end

% ensure these are column vectors,drop any NaN data
x = x(:);
y = y(:);
z = z(:);
t = t(:);
k = isnan(x) | isnan(y) | isnan(z) | isnan(t);
if any(k)
    x(k)=[];
    y(k)=[];
    z(k)=[];
    t(k)=[];
end

xnodes=xnodes(:);
ynodes=ynodes(:);
znodes=znodes(:);

% Because the xnodes must fall within the range of the given x's we are
% extending the xnodes to encompass the min and the max+1 of the xs this
% might be a modify-able option later on.
[xnodes, ynodes, znodes] = helper__adjustNodes(x,y,z,xnodes,ynodes,znodes);

dx = diff(xnodes);
dy = diff(ynodes);
dz = diff(znodes);

params.xscale = mean(dx);
params.yscale = mean(dy);
params.zscale = mean(dz);

nx = length(xnodes);
ny = length(ynodes);
nz = length(znodes);

ngrid = nx*ny*nz;

% create the matrix from linear interpolation of the 
% points realation to each cell 
interp = params.interp;
S = helper__interpMatrix(x,y,z,xnodes,ynodes,znodes,interp);

% create regularizer matrix
P = helper__regularMatrix(params, nx, ny, nz, dx, dy, dz, ngrid);

temp = size(P,1);
NA = norm(S,1);
NR = norm(P,1);
%S = [S;P*(NA/NR)];
%S = [S;P];

%Solve
rhs = t;
%rhs = [rhs;zeros(temp,1)];
out = S\rhs;
%out = reshape(S\rhs,nz,ny,nx); %???? what order?
%     out = S\G; %which is faster? what is the best solver option?
end


function S = helper__interpMatrix(x,y,z,xnodes,ynodes,znodes,interp)
var = 3; %number of independent variables

% determine which cell in the array each point lies in
% nodes: [length of each var, var nodes]
[~,indx] = histc(x,xnodes);
[~,indy] = histc(y,ynodes);
[~,indz] = histc(z,znodes);

n = length(x);

nx = length(xnodes);
ny = length(ynodes);
nz = length(znodes);

ngrid = nx*ny*nz;

dx = diff(xnodes);
dy = diff(ynodes);
dz = diff(znodes);

% any point falling at the last node is taken to be
% inside the last cell.
k=(indx==nx);
indx(k)=indx(k)-1;
k=(indy==ny);
indy(k)=indy(k)-1;
k=(indz==nz);
indz(k)=indz(k)-1;

ind = indx + nx*(indy-1) + nx*ny*(indz-1);

switch(interp)
    case 'linear' %uses linear/bilinear/trilinear interpolation
        %likely not effective for more than 3-dimensions
        tx = min(1,max(0,(x - xnodes(indx))./dx(indx)));
        ty = min(1,max(0,(y - ynodes(indy))./dy(indy)));
        tz = min(1,max(0,(z - znodes(indz))./dz(indz)));
        
        cmb = 2^var; % cmb == 8... 
        indMat1 = repmat((1:n)',1,cmb);
        indMat2 = [ind,    ind+1,    ind+nx,    ind+nx+1,...
            ind+(nx*ny), ind+(nx*ny)+1, ind+nx+(ny*nx), ind+nx+(ny*nx)+1]; %not right :P
        
        % Matrix of variables representing linear distance
        % this is a nightmare, is there a way to not hard-code this?
        dstMat = [(1-tx).*(1-ty).*(1-tz), (tx).*(1-ty).*(1-tz), (1-tx).*(ty).*(1-tz), (tx).*(ty).*(1-tz),...
                  (1-tx).*(1-ty).*(tz),   (tx).*(1-ty).*(tz),   (1-tx).*(ty).*(tz),   (tx).*(ty).*(tz)];
        % So essentially the index values up above refer to point's
        % relation to each cell. +1 means next x cell, +nx means next y
        % cell, + (ny*ny) means next z cell. All indexing has essentially
        % been done in this manner.
        
        %dstMat = fliplr(dstMat);
end

S = sparse(indMat1,indMat2,dstMat,n,ngrid);
end


%Adjusts the locations given by the nodes in the event that the min/max of
%the training data is outside of the node boundaries.
function [xnodes, ynodes, znodes] = helper__adjustNodes(x,y,z,xnodes,ynodes,znodes)
xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);
zmin = min(z);
zmax = max(z);

% did they supply a scalar for the nodes?
%and do the nodes encopmass the traingin data?
if length(xnodes)==1
    xnodes = linspace(xmin,xmax,xnodes)';
    xnodes(end) = xmax; % make sure it hits the max
end
if xmin < xnodes(1)
    xnodes(1) = xmin;
end
if xmax > xnodes(end)
    xnodes(end) = xmax;
end

%now for the y nodes
if length(ynodes)==1
    ynodes = linspace(ymin,ymax,ynodes)';
    ynodes(end) = ymax; % make sure it hits the max
end
if ymin < ynodes(1)
    ynodes(1) = ymin;
end
if ymax > ynodes(end)
    ynodes(end) = ymax;
end

%now for the z nodes
if length(znodes)==1
    znodes = linspace(zmin,zmax,znodes)';
    znodes(end) = zmax; % make sure it hits the max
end
if zmin < znodes(1)
    znodes(1) = zmin;
end
if zmax > znodes(end)
    znodes(end) = zmax;
end


end


function Areg = helper__regularMatrix(params, nx, ny, nz, dx, dy, dz, ngrid)
switch(params.regularizer)
    %In what order should these be developed???
    case 'gradient'
        % X gradient regularization
        [i,j,k] = ndgrid(2:(nx-1),1:ny,1:nz);
        ind = i(:) + nx*(j(:)-1) + ny*nx*(k(:)-1);
        dx1 = dx(i(:)-1)/params.xscale;
        dx2 = dx(i(:))/params.xscale;
        
        Areg = sparse(repmat(ind,1,3),[ind-1,ind,ind+1], ...
            [-2./(dx1.*(dx1+dx2)), ...
            2./(dx1.*dx2), -2./(dx2.*(dx1+dx2))],ngrid,ngrid);
        
        % Y gradient regularization
        [i,j,k] = ndgrid(1:nx,2:(ny-1),1:nz);
        ind = i(:) + nx*(j(:)-1) + ny*nx*(k(:)-1);
        dy1 = dy(j(:)-1)/params.yscale;
        dy2 = dy(j(:))/params.yscale;
        
        Areg = [Areg;sparse(repmat(ind,1,3),[ind-nx,ind,ind+nx], ...
            [-2./(dy1.*(dy1+dy2)), ...
            2./(dy1.*dy2), -2./(dy2.*(dy1+dy2))],ngrid,ngrid)];
        
        % Z gradient regularization
        [i,j,k] = ndgrid(1:nx,1:ny,2:(nz-1));
        ind = i(:) + nx*(j(:)-1) + ny*nx*(k(:)-1);
        dz1 = dz(k(:)-1)/params.zscale;
        dz2 = dz(k(:))/params.zscale;
        
        Areg = [Areg;sparse(repmat(ind,1,3),[ind-(nx*ny),ind,ind+(nx*ny)], ...
            [-2./(dz1.*(dz1+dz2)), ...
            2./(dz1.*dz2), -2./(dz2.*(dz1+dz2))],ngrid,ngrid)];
        
end
end


