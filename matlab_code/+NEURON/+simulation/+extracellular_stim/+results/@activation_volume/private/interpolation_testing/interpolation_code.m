x = 1:5:200;
y = 1:10:200;
z = 1:20:200;

%
values  = 1:200^3;
values  = reshape(values,[200 200 200]);
values2 = values(x,y,z); 


dx = x(2)-x(1);
dy = y(2)-y(1);
dz = z(2)-z(1);

x2 = linspace(0,1,dx+1)';
y2 = linspace(0,1,dy+1);
z2 = permute(linspace(0,1,dz+1),[1 3 2]);

x2_3d = repmat(x2,[1 dy+1 dz+1]);
y2_3d = repmat(y2,[dx+1 1 dz+1]);
z2_3d = repmat(z2,[dx+1 dy+1 1]);
x1_3d = 1 - x2_3d;
y1_3d = 1 - y2_3d;
z1_3d = 1 - z2_3d;

N = 10000;

tic
for i = 1:N
new_values2 = interp3_old([1 11],[1 6],[1 21],values2(1:2,1:2,1:2),(1:11)',1:6,1:21);
%new_values2 = permute(new_values2,[2 1 3]);
end
toc

F = griddedInterpolant({[1 6],[1 11],[1 21]},values2(1:2,1:2,1:2));
tic
for i = 1:N
new_values3 = F({1:6,1:11,1:21});  
end
toc


%Initial code, let's see if we can hardcode the factors
tic
for i = 1:N
c1 = x1_3d*values2(1,1,1) + x2_3d*values2(2,1,1);
c2 = x1_3d*values2(1,2,1) + x2_3d*values2(2,2,1);
c3 = x1_3d*values2(1,1,1) + x2_3d*values2(2,1,1);
c4 = x1_3d*values2(1,2,2) + x2_3d*values2(2,2,2);

c5 = y1_3d.*c1 + y2_3d.*c2;
c6 = y1_3d.*c3 + y2_3d.*c4;

new_values = z1_3d.*c5 + z2_3d.*c6;

end
toc


%Final optimized form
%--------------------------------------------------------------------------
f1 = x1_3d.*y1_3d.*z1_3d;
f2 = x2_3d.*y1_3d.*z1_3d;
f3 = x1_3d.*y2_3d.*z1_3d;
f4 = x2_3d.*y2_3d.*z1_3d;
f5 = x1_3d.*y1_3d.*z2_3d;
f6 = x2_3d.*y1_3d.*z2_3d;
f7 = x1_3d.*y2_3d.*z2_3d;
f8 = x2_3d.*y2_3d.*z2_3d;

tic
for i = 1:N
new_values = f1*values2(1,1,1) + f2*values2(2,1,1) ...
+ f3*values2(1,2,1) + f4*values2(2,2,1) ...
+ f5*values2(1,1,2) + f6*values2(2,1,2) ...
+ f7*values2(1,2,2) + f8*values2(2,2,2);   
end
toc