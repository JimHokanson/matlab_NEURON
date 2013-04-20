function figure4(obj)
% recreate figure 4

%% a (vary EAS)

tissue_resistivity = [obj. resistivity_transverse obj. resistivity_transverse obj.resistivity_longitudinal];
fiber_diameter = 10; % ?? not specified
EAS = 100:100:3000;

% 100 us pulse
stim_duration = 100./1000;
stim_start_time = 0.1;
stim_amp = -1;

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',tissue_resistivity,'electrode_locations',[0 0 0]); % placed at origin, cell will be moved away
xstim.elec_objs.setStimPattern(stim_start_time,stim_duration,stim_amp);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
cell.props_obj.changeFiberDiameter(fiber_diameter);

cell_locations = {0 EAS 0};

% active sim
thresh_active = xstim.sim__getThresholdsMulipleLocations(cell_locations);
thresh_active = squeeze(thresh_active);

% predictions
thresh_mdf1 = obj.computeThresholdMultipleLocations(xstim,cell_locations,1);
thresh_mdf2 = obj.computeThresholdMultipleLocations(xstim,cell_locations,2);

% threshold error
mdf1_error = obj.thresholdError(thresh_mdf1,thresh_active);
mdf2_error = obj.thresholdError(thresh_mdf2,thresh_active);

% plot
figure
%plot(EAS,mdf1_error,'s--',EAS,mdf2_error,'-')
plot(EAS,mdf1_error,'s--','linewidth',3,'markersize',10)
fontsize = 18;
xlabel('Electrode-Axon-Spacing [\mum]','fontsize',fontsize)
ylabel('Threshold Error [%]','fontsize',fontsize)
ylim([-40 40])
%legend('Single Node Method','Weighted Sum Method')
legend('Single Node Method')
set(gca,'fontsize',fontsize - 2)


%% b (vary alignment offset)

% props,stim,sim defined in (a)

internodal_length = cell.props_obj.internode_length;

perc_offset = -50:5:50; % percent internodal_length
abs_offset = (perc_offset./100)*internodal_length;
cell_locations = {0 200 abs_offset}; % 200 EAS, offset in z

% active sim
thresh_active = xstim.sim__getThresholdsMulipleLocations(cell_locations);
thresh_active = squeeze(thresh_active);

% predictions
thresh_mdf1 = obj.computeThresholdMultipleLocations(xstim,cell_locations,1);
thresh_mdf2 = obj.computeThresholdMultipleLocations(xstim,cell_locations,2);

% threshold error
mdf1_error = obj.thresholdError(thresh_mdf1,thresh_active);
mdf2_error = obj.thresholdError(thresh_mdf2,thresh_active);

% plot
figure
plot(perc_offset,mdf1_error,'s--',perc_offset,mdf2_error,'-')
xlabel('Alignment Offset [% Internodal Length]','fontsize',fontsize)
ylabel('Threshold Error [%]','fontsize',fontsize)
%ylim([-10 25])
legend('Single Node Method','Weighted Sum Method')
set(gca,'fontsize',fontsize - 2)

%% c (vary diameter)

% define props
fiber_diams = 6:2:20; % um
N_diams = length(fiber_diams);
cell_locations = [0 200 0]; % 200 um EAS
% stimulus define in (a)

%simulation created in (a), w/ electrode at (0,0,0)
cell.moveCenter(cell_locations);

% initialize thresholds
thresh_active = zeros(N_diams,1);
thresh_mdf1 = thresh_active;
thresh_mdf2 = thresh_active;

% loop over diameters and test
for iDiam = 1:N_diams
    fiber_diameter = fiber_diams(iDiam);
    cell.props_obj.changeFiberDiameter(fiber_diameter);
    % active
    result = xstim.sim__determine_threshold(1);
    thresh_active(iDiam) = result.stimulus_threshold;
    % mdf1
    thresh_mdf1(iDiam) = obj.computeThreshold(xstim,1);
    % mdf2
    thresh_mdf2(iDiam) = obj.computeThreshold(xstim,2);
end

% normalize
thresh_active = thresh_active./max(thresh_active);
thresh_mdf1 = thresh_mdf1./max(thresh_mdf1);
thresh_mdf2 = thresh_mdf2./max(thresh_mdf2);

% plot
figure
plot(fiber_diams,thresh_active,'o',fiber_diams,thresh_mdf1,'s--',fiber_diams,thresh_mdf2,'-','markersize',6)
xlabel('Axon Diameter [\mum]','fontsize',fontsize)
ylabel('Normalized Activation Threshold','fontsize',fontsize)
legend('Active Axon Model','Single Node Method','Weighted Sum Method')
ylim([0 1])
set(gca,'fontsize',fontsize - 2)

end