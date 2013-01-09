% Reproduce Rattay fig. 5 (current-distance)

% see
% analysis\NeuronModeling\electrode_interactions\a004_002reproduceMcIntyreFigure
% this will vary the distance and find the threshold at each location. It
% will NOT vary the stimulus.

% Goal: Test various distances and currents. If AP fires, plot a dot.


% PARAMETERS
StimAmps = [-5:.5:5]*1000; % -5 to 5 mA (corresponds to fiber diameter 9.6um, tested for distances ~ .05 to 1.7 mm)
TISSUE_RESISTIVITY = 300; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATION      = 0.1;   % 100 us duration, square pulse
%STIM_AMP           = -1;    % Let's work with + numbers on the scales
%DEFAULT_GUESS      = 80;
%     MAX_THRESHOLD      = 500;   % outside this range will throw an error
STIM_SCALES        = 1;
save_data = true;
minAxonDist = .05*1000; % .05 mm minimum distance from electrode to axon
maxAxonDist = 1.7*1000; % 1.7 mm
% other parameters from paper:
% fiber diameter 9.6 um (also plots 38.4 um at another scale) (McIntyre
% used 10 um)
% T = 27 deg C


nStimAmp = length(StimAmps);
N_FIBERS = 50;
firedPts = zeros(nStimAmp*N_FIBERS,2); % will be size nAPs x 2, col 1 is current, col 2 is distance. To be plotted.
nAPs = 0;

obj = NEURON.simulation.extracellular_stim('debug',0);

%     t_obj = obj.threshold_cmd_obj;
%     t_obj.allow_opposite_sign = false;
%     t_obj.max_threshold       = MAX_THRESHOLD;

%tissue -------------------------------------------------
set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(TISSUE_RESISTIVITY));

%electrode ----------------------------------------------
e_obj = NEURON.extracellular_stim_electrode.create([0 0 0]); %Null for now, will move ...
setStimPattern(e_obj,STIM_START_TIME,STIM_DURATION,STIM_SCALES);
set_Electrodes(obj,e_obj);

%cell ---------------------------------------------------
set_CellModel(obj,NEURON.cell.axon.generic([0 0 0]))
paper = 'McNeal_1976'; % for now...
setPropsByPaper(obj.cell_obj.props_obj,paper)

if save_data
    vmCell = cell(nStimAmp*N_FIBERS,1);
end

for iStim = 1:nStimAmp
    STIM_AMP = StimAmps(iStim);
    
    %axon_distance     = 100 + 850*rand(1,N_FIBERS);
    axon_distance = minAxonDist + (maxAxonDist-minAxonDist)*rand(1,N_FIBERS);
    node_spacing      = obj.cell_obj.getAverageNodeSpacing;
    parallel_distance = 0.5*node_spacing*rand(1,N_FIBERS);
    %threshold = zeros(1,N_FIBERS);
    for iSim = 1:N_FIBERS
        new_xyz = [0 axon_distance(iSim) parallel_distance(iSim)];
        moveElectrode(e_obj,new_xyz)
        %threshold(iSim) = sim__determine_threshold(obj,DEFAULT_GUESS);
        %[apFired,extras] = sim__single_stim(obj,STIM_AMP,'save_data',save_data);
        result_obj = sim__single_stim(obj,STIM_AMP);
        keyboard
        if apFired
            nAPs = nAPs + 1;
            firedPts(nAPs,:) = [STIM_AMP,axon_distance(iSim)]; % convert distance from micro to milli
        end
        if save_data
            vmCell{N_FIBERS*(iStim-1)+iSim} = extras.vm;
        end
    end
    
end
firedPts = firedPts(1:nAPs,:);

figure % rattay figure
plot(firedPts(:,1),firedPts(:,2)/1000,'.')
xlabel('Stim Current')
ylabel('Electrode Distance')
set(gca,'XLim',[-5 5],'YLim',[0 maxAxonDist/1000])

% figure % McIntyre
% plot(axon_distance,threshold,'o')
%  set(gca,'XLim',[0 1000],'YLim',[0 160])

%  figure % switch xy axes of McIntyre
%  plot(threshold,axon_distance,'o')
% set(gca,'XLim',[0 160],'YLim',[0 1000])
% xlabel('Threshold')
% ylabel('axon distance')

