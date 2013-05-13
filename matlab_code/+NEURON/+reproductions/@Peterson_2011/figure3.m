function figure3(obj)
%
%   This data doesn't match their results at all. What's going on?
%

fds = [6 10 16 20]; %um
pw  = [0.02 0.2]; %ms
fontsize = 15;
for iPW = 1:2
    subplot(1,2,iPW)
    cla
    hold all
    for iFD =1:4
       [v,m] = getVM(obj,2,fds(iFD),pw(iPW));
       plot(abs(v),m)
    end
    hold off
    xlabel('Extracellular Voltage (V_e) at Node n [mV]','fontsize',fontsize)
    ylabel('Weighted Sum Function Output','fontsize',fontsize)
    title(['Pulse Duration = ',num2str(pw(iPW)*1000),' \mus'],'fontsize',fontsize+2)
    legend(['Diameter = ',num2str(fds(1)),' \mum'],...
        ['Diameter = ',num2str(fds(2)),' \mum'],...
        ['Diameter = ',num2str(fds(3)),' \mum'],...
        ['Diameter = ',num2str(fds(4)),' \mum'])
    set(gca,'fontsize',fontsize-2)
end

return

%Figure 3 from figure 2 
x = [-10 -1 0 1 10];

for iPW = 1:2
    subplot(2,1,iPW)
    cla
    hold all
    for iFD =1:4
       [v,m] = getVM(obj,1,fds(iFD),pw(iPW));
       
       %Need weights ...
       w = obj.getWeights(pw(iPW),fds(iFD));
       
       w = [w(end:-1:2); w]';
       
       m2 = zeros(1,length(m));
       for iM = 1:length(m)
           cur_m = m(iM);
       %Might need to switch sign ...
       %if we fix ve sign ...
       neighbor_val = (cur_m-2*v(iM))/2;
       y = [0 neighbor_val v(iM) neighbor_val 0];
       
       %points = [x; y;];
       
       
       yy = pchip(x,y,-10:10);
       
       %Could do matrix math ...
       m2(iM) = sum(w.*yy);
       
% % % % %        wtf = cscvn(points);
% % % % %        
% % % % %        wtf2 = fnplt(wtf);
% % % % %        
% % % % %        n_vals = interp1(wtf2(1,:),wtf2(2,:),-10:10);
       
       end
       
       plot(v,m2)
    end
    hold off
end


end