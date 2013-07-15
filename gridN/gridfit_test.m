% define training points
x = 0:2:24;
y = 0:4:50;

[X,Y] = ndgrid(x,y);
z = 5*X(:);

%determine unknonwn nodes
xn = 2:4:20;
yn = 0:4:20;

%interpolate new values
zgrid = gridfit(X(:),Y(:),z,xn,yn);

zgrid = reshape(zgrid',30,1);

figure

%calculate actual values
[xr, yr] = ndgrid(xn,yn);
zreal =  5*xr(:);

%plot everything
subplot(2,1,1)
plot(zgrid,'g.')
hold
plot(zreal, 'b.')
title('Real(b) and Predicted(g) values w/ even better training?')
grid on

subplot(2,1,2)
err3 = 100*abs(zreal - zgrid)/zreal;
plot(err3,'r')
title('Percent error for values above')
grid on


