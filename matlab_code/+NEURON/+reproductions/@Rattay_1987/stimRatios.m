function ratios = stimRatios(resultObj)
firedPts = resultObj.firedPts; % nAPs x 2 (stim amp, distance) (mA,mm)

minDist = 0.01;
maxDist = 5;
N_distances = 50;
distances = linspace(minDist,maxDist,N_distances);

minAbsStim = 0.5;
maxAbsStim = 10;
stimIncrement = 0.5;
absStimAmps = minAbsStim:stimIncrement:maxAbsStim;
nAbsStimAmps = length(absStimAmps);

ratios = zeros(nAbsStimAmps,2);
iRatio = 0;
% for iAbsStim = 1:nAbsStimAmps
%    stimAmp = absStimAmps(iAbsStim);
%    plusPt = max(firedPts(firedPts(:,1) == stimAmp,2));
%    minusPt = max(firedPts(firedPts(:,1) == -stimAmp,2));
%    
%    if plusPt == maxDist || minusPt == maxDist % ratio is meaningless if top of curve not determined
%        continue
%    end
%    
%    iRatio = iRatio + 1; 
%    ratios(iRatio,1) = stimAmp;
%    ratios(iRatio,2) = minusPt/plusPt;
% 
% end
% ratios = ratios(1:iRatio,:); 
% 
% figure
% plot(ratios(:,1),ratios(:,2))
% xlabel('Absolute Stimulus Amplitude (mA)')
% ylabel('Distance Ratio of -Stim/+Stim')

% perhaps doing ratio of amplitudes at each distance is more informative

for iDist = 1:N_distances
    dist = distances(iDist);
    distPts = firedPts(firedPts(:,2) == dist,1);
    plusPt = min(distPts(distPts > 0));
    minusPt = min(abs(distPts(distPts < 0)));
    
    if isempty(plusPt) || isempty(minusPt) || plusPt == maxAbsStim || minusPt == maxAbsStim
       continue 
    end
    
    iRatio = iRatio + 1;
    ratios(iRatio,1) = dist;
    ratios(iRatio,2) = minusPt/plusPt;
    
end

figure
plot(ratios(:,1),ratios(:,2),'o')
xlabel('Electrode Distance (mm)')
ylabel('Stim Amp Ratio (-Stim/+Stim)')

end