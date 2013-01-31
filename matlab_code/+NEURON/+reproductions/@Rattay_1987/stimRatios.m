function stimRatios(obj,varargin)
% get ratios of cathodal to anodal stim amplitudes needed to activate over
% a range of distances

% This should be updated to use sim_logger to get a more precise threshold,
% rather than simply using the result from reproduceRattay.

in.debug = false;
in = processVarargin(in,varargin);

TISSUE_RESISTIVITY = obj.tissue_resistivity; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATIONS      = 0.1;   % 100us duration, square pulse
STIM_SCALES = 1;
propsPaper = obj.propsPaper;

%Props that differ from defaults ...
TEMP_CELSIUS = obj.temp_celsius;

minDist = 0.01*1000;
maxDist = 5*1000;
N_distances = 50;
distances = linspace(minDist,maxDist,N_distances);

xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic',...
    'cell_options',{'paper',propsPaper},...
    'stim_scales',STIM_SCALES,...
    'stim_durations',STIM_DURATIONS,...
    'stim_start_times',STIM_START_TIME,...
    'debug',in.debug,...
    'celsius',TEMP_CELSIUS);

catThresholds = -1*xstim_obj.sim__getThresholdsMulipleLocations({0 distances 0},'threshold_sign',-1);
anodeThresholds = xstim_obj.sim__getThresholdsMulipleLocations({0 distances 0},'threshold_sign',1);
ratios = catThresholds./anodeThresholds;
%{
firedPts = obj.fig5MyelinatedResult.firedPts; % nAPs x 2 (stim amp, distance) (mA,mm)

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
%}

figure
plot(distances./1000,ratios)
% hold on
% plot(distances./1000,ratios,'o')
xlabel('Electrode Distance (mm)')
ylabel('Stim Amp Ratio (-Stim/+Stim)')
ylim([0 1])
hold on
plot(distances./1000,ratios,'o')

obj.myelinatedStimRatios = ratios;

end