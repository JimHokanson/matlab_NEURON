function figure2(obj)
fd = 4; % arbitrary fiber diameter off of chart, there's actually no dependence
pw = [0.02,0.2];

for iPW = 1:2
   subplot(1,2,iPW)
   [v,m] = getVM(obj,1,fd,pw(iPW));
   plot(v,m)
   title(['Pulse Duration = ',num2str(pw(iPW)*1000),' \mus'])
   xlabel('Peak Extracellular Voltage (V_e) [mV]')
   ylabel('Second Nodal Difference (\Delta^2V_e) [mV]')
   set(gca,'XLim',[0 500],'YLim',[0 180])
end

% ====== This verifies there's no dependence of fiber diameter on MDF 1.
% 
% fds = 4:2:20; %um
% %pw  = [.02 .05 .1 .2 .5 1 2 5 10]; %ms
% pw = [0.02,0.2];
% 
% figure
% iPlot = 6;
% for iFD = 1:length(fds)
%     for iPW =1:length(pw)
%         iPlot = iPlot + 1;
%         if iPlot == 7
%             figure
%             subplot(3,2,1)
%             iPlot = 1;
%         end
%         
%         subplot(3,2,iPlot)
%         [v,m] = getVM(obj,1,fds(iFD),pw(iPW));
%         plot(v,m)
%         title(['(fd,pw) = (',num2str(fds(iFD)),',',num2str(pw(iPW)),')'])
%         ylim([0 180])
%     end
% end


end