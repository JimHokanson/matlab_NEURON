function figure2(obj)
%
%   Diameter not specified in function
%
%   

FIBER_DIAMETER = 10;
pw  = [0.02 0.2]; %ms

for iPW = 1:2
    subplot(2,1,iPW)
    cla
    hold all
   [v,m] = getVM(obj,1,FIBER_DIAMETER,pw(iPW));
   plot(v,m)
    hold off
end