function figure7(obj)

% figure 7
% 100 us pulse, 10 um diameter, 200um EAS

%% a

% general props
EAS = 200;
fiber_diameter = 10;
tissue_resistivity = [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal];

% stimulus
stim_start_time = 0.1;
stim_duration = 0.1; % 100 us
stim_amps = obj.eleven_electrode_amps; % defined in fig 1d

% initial electrode locations
elec_spacings_all = 400:100:1500;
N_elec_spacing = length(elec_spacings_all);
electrode_locations = zeros(11,3);
electrode_locations(:,2) = EAS; % NOTE: cell will not need to be moved from origin
unit_spacing = -5:5;
electrode_locations(:,3) = unit_spacing*elec_spacings_all(1);

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_locations);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
electrodes = xstim.elec_objs;
electrodes.setStimPattern(stim_start_time,stim_duration,stim_amps);

% initialize thresholds
thresh_active = zeros(N_elec_spacing,1);
thresh_mdf1 = thresh_active;
thresh_mdf2 = thresh_active;

for i_elec_spacing = 1:N_elec_spacing
    % move electrodes
    electrode_locations(:,3) = unit_spacing*elec_spacings_all(i_elec_spacing);
    electrodes = moveElectrodesLocal(electrodes,electrode_locations);
    
    % active sim
    result = xstim.sim__determine_threshold(1);
    thresh_active(i_elec_spacing) = result.stimulus_threshold;
    %mdf1
    thresh_mdf1(i_elec_spacing) = obj.computeThreshold(xstim,1);
    thresh_mdf2(i_elec_spacing) = obj.computeThreshold(xstim,2);
    
end

% threshold error
mdf1_error = obj.thresholdError(thresh_mdf1,thresh_active);
mdf2_error = obj.thresholdError(thresh_mdf2,thresh_active);

% plot
figure
plot(elec_spacings_all,mdf1_error,'s--',elec_spacings_all,mdf2_error,'-')
fontsize = 15;
xlabel('Adjacent Electrode Spacing [  \mum]','fontsize',fontsize)
ylabel('Threshold Error [%]','fontsize',fontsize)
%ylim([-30 50])
legend('Single Node Method','Weighted Sum Method')
set(gca,'fontsize',fontsize - 2)

%% b, c
% 500,1000 um spacing, 10 um diameter, potential along axon

% Adapted from Jim's old code

ADJACENT_ELECTRODE_SPACING_7b = 500;
ADJACENT_ELECTRODE_SPACING_7c = 1000;
EAS = 200;

%FIGURE 7B/C
%===============================================================
adjacent_electrode_spacing = [ADJACENT_ELECTRODE_SPACING_7b ADJACENT_ELECTRODE_SPACING_7c];
figure
for iPlot = 1:2
    % move electrodes
    electrode_locations(:,3) = unit_spacing*adjacent_electrode_spacing(iPlot);
    electrodes = moveElectrodesLocal(electrodes,electrode_locations);
    
    % plot
    subplot(2,1,iPlot)
    xstim.plot__AppliedStimulus(1);
    xlabel('Distance Along Axon [mm]','fontsize',fontsize)
    ylabel('Extracellular Potential [mV]','fontsize',fontsize)
    title(['Adjacent Electrode Spacing = ',num2str(adjacent_electrode_spacing(iPlot)),'   \mum'],'fontsize',fontsize+2)
    set(gca,'fontsize',fontsize-2,'XLim',[0 20])

end



end

function elec_objs = moveElectrodesLocal(elec_objs,electrode_locations)
N_electrodes = length(elec_objs);
for i_elec = 1:N_electrodes
    elec_objs(i_elec).moveElectrode(electrode_locations(i_elec,:));
end
end
