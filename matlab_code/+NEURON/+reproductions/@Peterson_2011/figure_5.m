function figure_5(obj)
% recreate figure 5

% props
fiber_diameter = 10; % um
tissue_resistivity = [obj. resistivity_transverse obj. resistivity_transverse obj.resistivity_longitudinal];
EAS = 100:100:2000; % um
N_EAS = length(EAS);
stim_duration = [20,50,100,500]./1000; % us -> ms
N_stim_durations = length(stim_duration);
stim_start_time = 0.1;
stim_amp = -1;

%% a

% create simulation
xstim = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',tissue_resistivity,'electrode_locations',[0 0 0]); % placed at origin, cell will be moved away
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
cell.props_obj.changeFiberDiameter(fiber_diameter);

thresholds = zeros(N_stim_durations,N_EAS);
% get thresholds
for i_stim_duration = 1:N_stim_durations
    % set stim
    xstim.elec_objs.setStimPattern(stim_start_time,stim_duration(i_stim_duration),stim_amp);
    
    % test all EAS
    thresholds(i_stim_duration,:) = xstim.sim__getThresholdsMulipleLocations({0 EAS 0});  
end

% normalize thresholds
thresholds = thresholds./max(max(thresholds));

% plot
figure
markerSpec = {'bs' 'gv' 'r^' 'co'};
for i_stim_duration = 1:N_stim_durations
    plot(EAS,thresholds(i_stim_duration,:),markerSpec{i_stim_duration})
    hold on
end
legend('20 \mus','50 \mus','100 \mus','500 \mus','Location','NorthWest')
xlabel('Electrode-to-Axon Spacing \mus')
ylabel('Normalized Threshold')

end