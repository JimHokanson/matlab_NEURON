function reproduceRattay(varargin)

% Attempt to reproduce figure from Rattay 1987.

% 100us square pulse (What about charge-balancing????)
% resistivity 300ohm-cm
% figure uses range -10mA-10mA for  38.4um diameter, and -5mA-5mA for 9.6
% um.

in.debug = false;
in.local_debug = false;
in = processVarargin(in,varargin);

minStim = -5; maxStim = 5; stimStep = .5; % -5 to 5 mA (corresponds to fiber diameter 9.6um, tested for distances ~ .05 to 1.7 mm)
stimAmps = [minStim:stimStep:maxStim]*1000;
%stimAmps = [-10:.5:10]*1000; % -10mA-10mA
%stimAmps = [-5:.5:5]*1000; % -5mA-5mA
TISSUE_RESISTIVITY = 300; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATIONS      = 0.1;   % 100us duration, square pulse
STIM_SCALES = 1;
propsPaper = 'Rattay_1987'; % get properties from this paper, for now. %TODO: get properties used in Rattay_1987.
TEMP_CELSIUS = 27;

%minAxonDist = 0.1*1000; % 0.1 mm min dist from electrode to axon
%maxAxonDist = 3.25*1000; % 3.25 mm max dist from electrode to axon
minAxonDist = 0.01*1000; % 0.01 mm
maxAxonDist = 3.5*1000;  % 3.5 mm


nStimAmps = length(stimAmps);
N_FIBERS = 50;
stimData = zeros(nStimAmps*N_FIBERS,3); % (current,distance,fired?)
iSimTotal = 0;

% create extracellular_stim object, as well as tissue, electrode, and cell.
obj = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic','cell_options',{'paper',propsPaper},'stim_scales',STIM_SCALES,'stim_durations',STIM_DURATIONS,...
    'stim_start_times',STIM_START_TIME,'debug',in.debug,'celsius',TEMP_CELSIUS);


for iStim = 1:nStimAmps
    STIM_AMP = stimAmps(iStim);
    
    axon_distance = minAxonDist + (maxAxonDist-minAxonDist)*rand(1,N_FIBERS);
    node_spacing = obj.cell_obj.getAverageNodeSpacing;
    parallel_distance = 0.5*node_spacing*rand(1,N_FIBERS);
    for iSim = 1:N_FIBERS %should probably rename iSim to avoid confusion with iStim
        new_xyz = [0 axon_distance(iSim) parallel_distance(iSim)];
        moveElectrode(obj.elec_objs,new_xyz)
        result_obj = sim__single_stim(obj,STIM_AMP);
        % includes properties such as ap_propogated (bool) and
        % membrane_potential (time x space), which can be plotted using mesh()
        
        iSimTotal = iSimTotal + 1;
        apFired = result_obj.ap_propogated; % note mispelling, if that's fixed, need to change here
        stimData(iSimTotal,:) = [STIM_AMP,axon_distance(iSim),apFired];
        
    end
    
end

% separate points that fired or did not fire, and convert units from micro
% to milli
firedPts = stimData(stimData(:,3) == 1,1:2)./1000;
nullPts = stimData(stimData(:,3) == 0,1:2)./1000;

figure % rattay figure
plot(firedPts(:,1),firedPts(:,2),'rx')
hold on
plot(nullPts(:,1),nullPts(:,2),'k.','markerSize',0.5)
legend('Activated','Not Activated')
xlabel('Stim Current (mA)')
ylabel('Electrode Distance (mm)')
set(gca,'XLim',[minStim maxStim],'YLim',[0 maxAxonDist/1000])
if in.local_debug
    keyboard
end

end