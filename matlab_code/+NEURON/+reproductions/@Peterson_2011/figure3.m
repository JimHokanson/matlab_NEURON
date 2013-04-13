function figure3(obj)
%
%   This data doesn't match their results at all. What's going on?
%
%
fds = [6 10 16 20]; %um
pw  = [0.02 0.2]; %ms

for iPW = 1:2
    subplot(2,1,iPW)
    cla
    hold all
    for iFD =1:4
       [v,m] = getVM(obj,2,fds(iFD),pw(iPW));
       plot(v,m)
    end
    hold off
end


end