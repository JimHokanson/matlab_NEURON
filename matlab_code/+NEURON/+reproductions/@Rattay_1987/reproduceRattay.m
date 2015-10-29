function reproduceRattay(obj,varargin)

% Attempt to reproduce figure 5 from Rattay 1987, but with a myelinated axon.

% 100us square pulse
% resistivity 300ohm-cm


in.debug = false;
in.local_debug = false;
in = NEURON.sl.in.processVarargin(in,varargin);

minStim = -10; maxStim = 10; stimStep = .5; % -10 to 10 mA
stimAmps = [minStim:stimStep:maxStim]*1000;
TISSUE_RESISTIVITY = obj.tissue_resistivity; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1; % 100us duration, square pulse
STIM_DURATIONS     = 0.1;
STIM_AMP        = 1;
props_paper         = obj.props_paper;
TEMP_CELSIUS       = obj.temp_celsius; % 27 C

minAxonDist = 0.01*1000; % 0.01 mm
maxAxonDist = 5*1000;  % 5 mm


nStimAmps = length(stimAmps);
N_FIBERS = 50;
stimData = zeros(nStimAmps*N_FIBERS,3); % (current,distance,fired?)
iSimTotal = 0;

% create extracellular_stim object, as well as tissue, electrode, and cell.
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic');
xstim_obj.cmd_obj.options.debug = in.debug;
xstim_obj.props_obj.changeProps('celsius',TEMP_CELSIUS);
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,STIM_DURATIONS,STIM_AMP);
xstim_obj.cell_obj.props_obj.setPropsByPaper(props_paper);

for iStim = 1:nStimAmps
    STIM_AMP = stimAmps(iStim);
    
    axon_distance = linspace(minAxonDist,maxAxonDist,N_FIBERS);
    parallel_distance = 0;
    for iSim = 1:N_FIBERS %should probably rename iSim to avoid confusion with iStim
        new_xyz = [0 axon_distance(iSim) parallel_distance];
        moveElectrode(xstim_obj.elec_objs,new_xyz)
        result_obj = sim__single_stim(xstim_obj,STIM_AMP);
        % includes properties such as ap_propogated (bool) and
        % membrane_potential (time x space), which can be plotted using mesh()
        
        iSimTotal = iSimTotal + 1;
        apFired = result_obj.ap_propagated;
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

resultObj.headings = {'Stim Amp (mA)' 'Electrode Distance (mm)'};
resultObj.firedPts = firedPts;
resultObj.nullPts = nullPts;
obj.fig5_myelinated_result = resultObj;

end