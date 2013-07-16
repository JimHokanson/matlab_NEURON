% gridN notes

% So the usuage is just like gridfit. The initial bug that I was having with
% this was that when developing the sparse matrix for the bilinear
% interpolation I referenced the indices as:
% ind, ind+1, ind+ny, ind+ny+1, ind+nz, ind+nz+1, ind+ny+nz, ind+ny+nz+1
% nx,ny,nz are the lengths of the respective nodes for x, y, z.

% This of course was wrong. The indices should refer to the cell, which has been
% linearized to a 1 x ngrid vector. (ngrid == nx*ny*nz)

% referencing into the vector using the x,y,z values is done by:
% x(i) + nx*y(i-1) + nx*ny*z(i-1)

% This meant that what I need to do in order to reference the appropriate 
% right edges would have been:

%ind, ind+1, ind+nx, ind+nx+1, ind+nx*ny, ind+nx*ny+1. etc...

%the irony however was that I usually saw a smaller error margin they way I
%was initially doing it. (0-200 whereas now it can be around 800-1000)

%For testing purposes I am not currently using the regularizer. Once I am
%sure the function works with respect to just doing trilinear interpolation
%I'll add that back in. This also means that there are variables NR (norm 
%of the regularizer) and NA (norm of the interp matrix) that also are not
%curretnly being used. Another irony, I think D'errico's code works better
%for linear tests such as the ones I've been doing if these aren't used...
%If you want to use the regularizer uncomment one of the 'S = [S;P]' lines
%(71 and 72), and line 76 where we lengthen rhs.

%In D'Errico's code he had a few variables for smoothing like
%'xyrelativestiffness' and 'smoothingparam'. These were set to a
%default of 1, so for the time being they are not included in this code.

%There are 3 helper functions included in gridn:
% helper__adjustNodes
% helper__regularMatrix
% helper__interpMatrix

% 'adjustNodes' changes the values of the nodes in the case that they do not
% encapsulate the values of the training data.

% 'regularMatrix' creates the regularizer matrix.

% 'interpMatrix' creates the interpolation matrix. This is the code where
% my inital problem was located... I'm actually not sure what is wrong with
% the code at the moment... Or if the strategy I'm using for the set of
% data simply is not optimal.

% 'regularMatrix' corresponds to lines 572:593 in D'errico's code
% 'interpMatrix'  corresponds to lines 458:506 in D'errico's code

%My code can still afford to be commented/structured better...

