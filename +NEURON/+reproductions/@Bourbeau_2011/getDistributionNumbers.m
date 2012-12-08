%Old code copied from Dennis ...
%with some slight modificaitons ...

drFibers = [12263,14741,11808,11118,10979,9760,13635,10733,8081,13822];
sumDRfibers = mean(drFibers);
folder = 'C:\D\SVN_FOLDERS\matlab_toolboxes\NEURON\+NEURON\+reproductions\@Bourbeau_2011\';
file = 'Risling_etal_fig.png';
Ref_image = imread([folder file],'png');
yRefDataBins = [8 30 68 109 78 44 31 14 11 16 23 57 55 72 79 65 76 79 47 30 9 4 6];
binSize = (14-1)/(23);
xBins = 1 + binSize/2;
for i = 1:22
    xBins(i+1) = xBins(i) + binSize;
end

xRefDataDist = xBins/0.7;
yRefDataDist = yRefDataBins.*sumDRfibers./sum(yRefDataBins);
% bar(xRefDataDist,yRefDataDist);
areaFibers = sum(yRefDataDist(8:end).*((pi/4).*xRefDataDist(8:end).^2));
% DRGAreaPredicted = areaFibers/0.14;
DRGdFiber = sqrt((areaFibers/0.14)*(4/pi))/1000;

MINyRefDataDist = yRefDataBins.*min(drFibers)./sum(yRefDataBins);
MINareaFibers = sum(MINyRefDataDist(8:end).*((pi/4).*xRefDataDist(8:end).^2));
% MINDRGAreaPredicted = MINareaFibers/0.14;
MINDRGdFiber = sqrt((MINareaFibers/0.14)*(4/pi))/1000;

MAXyRefDataDist = yRefDataBins.*max(drFibers)./sum(yRefDataBins);
MAXareaFibers = sum(MAXyRefDataDist(8:end).*((pi/4).*xRefDataDist(8:end).^2));
% MAXDRGAreaPredicted = MAXareaFibers/0.14;
MAXDRGdFiber = sqrt((MAXareaFibers/0.14)*(4/pi))/1000;

xBinsSub = [xBins(7:end) xBins(end) + binSize];
xBinsScaled = xBinsSub/0.7;    % Scaling factor taken from Suh et al. 1984
yRefDataBinsSub = [0 yRefDataBins(8:end) 0];
yRefDataNorm = yRefDataBinsSub/sum(yRefDataBinsSub);
xRefData = floor(min(xBinsScaled)):0.1:ceil(max(xBinsScaled));
yRefData = interp1(xBinsSub,yRefDataNorm,xRefData,'spline');
yRefDataScaled = interp1(xBinsScaled,yRefDataNorm,xRefData,'spline');

% bar(xElec_Data,yElec_Data);
% hold on;
% axis([0 25 0 0.22]);
% plot(xRefData,yRefData,'linewidth',2,'color','g');
plot(xRefData,yRefDataScaled,'linewidth',2,'color','r');
legend('reference data','location','NW');
xlabel('D_f_i_b_e_r');
ylabel('Relative fiber count, normalized to maximum fiber count');