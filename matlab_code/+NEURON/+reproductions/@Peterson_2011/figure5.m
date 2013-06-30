function figure5(obj)
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

thresh_active = zeros(N_stim_durations,N_EAS);
thresh_mdf1 = thresh_active;
%thresh_mdf2 = thresh_active;

cell_locations = {0 EAS 0};

% get thresholds
for i_stim_duration = 1:N_stim_durations
    % set stim
    xstim.elec_objs.setStimPattern(stim_start_time,stim_duration(i_stim_duration),stim_amp);
    
    % test all EAS
    thresh_active(i_stim_duration,:) = xstim.sim__getThresholdsMulipleLocations(cell_locations);
    thresh_mdf1(i_stim_duration,:) = obj.computeThresholdMultipleLocations(xstim,cell_locations,1);
   %thresh_mdf2(i_stim_duration,:) = obj.computeThresholdMultipleLocations(xstim,cell_locations,2);
end

% normalize thresholds
thresh_active = thresh_active./max(max(thresh_active));
thresh_mdf1 = thresh_mdf1./max(max(thresh_mdf1));
%thresh_mdf2 = thresh_mdf2./max(max(thresh_mdf2));

% plot
plotFig5(EAS,thresh_active,'Active Axon Simulation')
plotFig5(EAS,thresh_mdf1,'Single Node Method')
%plotFig5(EAS,thresh_mdf2,'Weighted Sum Method')

end

function plotFig5(EAS,thresholds,title_string)
figure
lineSpec = {'bs-' 'gv-' 'r^-' 'co-'};
for i_stim_duration = 1:size(thresholds,1)
    plot(EAS,thresholds(i_stim_duration,:),lineSpec{i_stim_duration},'linewidth',3,'markerSize',10)
    hold on
end
fontsize = 18;
legend('20 \mus','50 \mus','100 \mus','500 \mus','Location','NorthWest')
xlabel('Electrode-to-Axon Spacing [\mum]','fontsize',fontsize)
ylabel('Normalized Threshold','fontsize',fontsize)
title(title_string,'fontsize',fontsize + 2)
set(gca,'fontsize',fontsize - 2)

end