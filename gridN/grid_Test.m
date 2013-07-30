% x = -10:10;
% y = -10:10;
% z = -10:10;
% 
% [X,Y,Z] = meshgrid(x,y,z);
% 
% out = 2*X(:) + 3*Y(:) + Z(:);


clc
%==========================================================================
% xi = [1,2,5,4];
% yi = [1 5 7 3];
% zi = [2 3 2 3];
% ti = 2*xi(:) + 3*yi(:) + zi(:);
% 
% xn = 1:2:10;
% yn = 1:2:20;
% zn = 1:2:40;
% 
% tn = gridN(xi,yi,zi,ti,xn,yn,zn);
% %--------------------------------------------------------------------------
% 
% [Xr,Yr,Zr] = ndgrid(xn,yn,zn);
% treal = 2*Xr(:) + 3*Yr(:) + Zr(:);
% 
% figure
% subplot(2,3,1)
% plot(tn,'g')
% hold
% plot(treal, 'b')
% title('Real(b) and Predicted(g) values')
% grid on
% 
% subplot(2,3,4)
% err = 100*abs(treal - tn)/treal;
% plot(err,'r')
% title('Percent error for values above')
% grid on
% %==========================================================================
% % Better training data
% 
% xi2 = 1:5:50;
% yi2 = 1:5:50;
% zi2 = 1:5:50;
% ti2 = 2*xi2(:) + 3*yi2(:) + zi2(:);
% 
% xn2 = 1:2:10;
% yn2 = 1:2:20;
% zn2 = 1:2:40;
% 
% tn2 = gridN(xi2,yi2,zi2,ti2,xn2,yn2,zn2);
% 
% 
% %--------------------------------------------------------------------------
% [Xr2,Yr2,Zr2] = ndgrid(xn2,yn2,zn2);
% treal2 = 2*Xr2(:) + 3*Yr2(:) + Zr2(:);
% 
% subplot(2,3,2)
% plot(tn2,'g')
% hold
% plot(treal2, 'b')
% title('Real(b) and Predicted(g) values w/ better training?')
% grid on
% 
% subplot(2,3,5)
% err2 = 100*abs(treal2 - tn2)/treal2;
% plot(err2,'r')
% title('Percent error for values above')
% grid on
%==========================================================================
% Even Better training data???

x = 1:3:12;
y = 1:3:12;
z = 1:3:12;

[X,Y,Z] = ndgrid(x,y,z);

T = 2*X(:)+ Y(:) + 4*Z(:).^2 + 5;

xn3 = 0:13;
yn3 = 0:13;
zn3 = 0:13;

tn3 = gridN(X(:),Y(:),Z(:),T(:),xn3,yn3,zn3);


%--------------------------------------------------------------------------
[Xr3,Yr3,Zr3] = ndgrid(xn3,yn3,zn3);
treal3 = 2*Xr3(:) +Yr3(:)+ 4*Zr3(:).^2 + 5;

figure

subplot(2,1,1)
plot(treal3,'b')
hold
plot(tn3, 'g')
title('Real(b) and Predicted(g) values w/ even better training?')
grid on

subplot(2,1,2)
err3 = 100*abs(treal3 - tn3)/treal3; %check this is developed right...
plot(err3,'r')
title('Percent error for values above')
grid on

%==========================================================================
%Visulaization
%==========================================================================

figure
scatter3(Xr3(:),Yr3(:),Zr3(:), [], tn3(:), 'filled')

%--------------------------------------------------------------------------
figure

t = reshape(tn3, length(xn3), length(yn3), length(zn3));
slice(t, [], [], 1:size(t,3))
shading flat
%--------------------------------------------------------------------------
for k = 1:4
figure

imagesc(t(:,:,k))
end





