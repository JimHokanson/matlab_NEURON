function reproduceRattay


% 100us square pulse (What about charge-balancing????)
% resistivity 300ohm-cm
% figure uses range -10mA-10mA for  38.4um diameter, and -5mA-5mA for 9.6
% um.

debug = true;

%stimAmps = [-10:.5:10]*1000; % -10mA-10mA
stimAmps = [-5:.5:5]*1000; % -5mA-5mA
TISSUE_RESISTIVITY = 300; % isotropic 300 ohm cm
STIM_START_TIME    = 0.1;
STIM_DURATIONS      = {[0.1, 0.1]};   % 100us duration, square pulse
STIM_SCALES = {[-1 1]}; % assume 100us stim, followed by 100us charge-balance stim
propsPaper = 'McNeal_1976'; % get properties from this paper, for now. %TODO: get properties used in Rattay_1987.


%minAxonDist = 0.1*1000; % 0.1 mm min dist from electrode to axon
%maxAxonDist = 3.25*1000; % 3.25 mm max dist from electrode to axon
minAxonDist = 0.01*1000; % 0.01 mm
maxAxonDist = 1.65*1000;  % 1.65 mm


nStimAmps = length(stimAmps);
N_FIBERS = 50;
firedPts = zeros(nStimAmps*N_FIBERS,2); % nAPs x2, (current,distance)
nAPs = 0;

% create extracellular_stim object, as well as tissue, electrode, and cell.
obj = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',TISSUE_RESISTIVITY,...
    'cell_type','generic','stim_scales',STIM_SCALES,'stim_durations',STIM_DURATIONS,...
    'stim_start_times',STIM_START_TIME,'debug',debug);

% set properties
setPropsByPaper(obj.cell_obj.props_obj,propsPaper)

for iStim = 1:nStimAmps
STIM_AMP = stimAmps(iStim);

axon_distance = minAxonDist + (maxAxonDist-minAxonDist)*rand(1,N_FIBERS);
node_spacing = obj.cell_obj.getAverageNodeSpacing;
parallel_distance = 0.5*node_spacing*rand(1,N_FIBERS);
for iSim = 1:N_FIBERS
   new_xyz = [0 axon_distance(iSim) parallel_distance(iSim)];
   moveElectrode(obj.elec_objs,new_xyz)
   result_obj = sim__single_stim(obj,STIM_AMP);
   keyboard
    
end
    
end
firedPts = firedPts(1:nAPs,:);






end