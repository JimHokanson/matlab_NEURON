function singleThresholdTest(obj)
%
%
%   p = NEURON.reproductions.Peterson_2011
%   p.singleThresholdTest
%
%   NEURON.reproductions.Peterson_2011.singleThresholdTest

%Here we wish to examine whether or not 



% define props
EAS_all = [50,300]; % um, place cell at these locations, center electrodes at origin
N_EAS = length(EAS_all);
fiber_diams = 4:20; % um
N_diams = length(fiber_diams);
tissue_resistivity = [obj. resistivity_transverse obj. resistivity_transverse obj.resistivity_longitudinal];

% define stimulus: 11 electrodes: 6 anodes, 5 cathodes
stim_start_time = 0.1;
stim_duration   = 20/1000; % 20 us

%TODO: Move this to being a method or property of the class ...
stim_amps = {0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4}; % defined in fig 1d

% define electrode locations: adjacent electrode spacing = 650 um
%Make this a method as well ...
elec_spacing = 650;
% spaceFactor = -7;
% electrode_locations = zeros(11,3);
% for iElec = 1:11
%     spaceFactor = spaceFactor + 1;
%     electrode_locations(iElec,:) = [0 0 elec_spacing*spaceFactor]; % vary z
% end

electrode_locations = zeros(11,3);
electrode_locations(:,3) = (-5:5)*elec_spacing;
%------------------------------------------------------------------------


% define cell locations
cell_locations = {0 EAS_all 0};

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_locations);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
xstim.elec_objs.setStimPattern(stim_start_time,stim_duration,stim_amps);

%cell.props_obj.changeFiberDiameter(5);
cell.moveCenter([0 300 0]);

%r = xstim.sim__single_stim(1);

keyboard

for iDiam = 4:20
    fprintf('Running diam %d\n',iDiam)
    cell.props_obj.changeFiberDiameter(iDiam);
%amps = 0.5:0.5:15;
%amps = 50:10:350;
prop = false(1,length(amps));
for iStim = 1:length(amps)
   r = xstim.sim__single_stim(amps(iStim));
   prop(iStim) = r.ap_propagated;
end
if any(diff(prop) == -1)
   keyboard 
end
end



%stim_levels_test = 

%ap_prop = false


% thresholds = zeros(N_diams,N_EAS);
% % get thresholds
% for iDiam = 1:N_diams
%     fiber_diameter = fiber_diams(iDiam);
%     % change diameter
%     
%     
%     % test all EAS
%     thresholds(iDiam,:) = xstim.sim__getThresholdsMulipleLocations(cell_locations);
%     
% end