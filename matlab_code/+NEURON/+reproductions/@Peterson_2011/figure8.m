function figure8(obj)
% recreate figure 8
%
%   p = NEURON.reproductions.Peterson_2011
%   p.figure_8
%

% define props
EAS_all = [50,300]; % um, place cell at these locations, center electrodes at origin
N_EAS = length(EAS_all);
fiber_diams = obj.all_fiber_diameters; % um
N_diams = length(fiber_diams);
tissue_resistivity = [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal];

% define stimulus: 11 electrodes: 6 anodes, 5 cathodes
stim_start_time = 0.1;
stim_duration   = 20/1000; % 20 us

stim_amps = obj.eleven_electrode_amps; % defined in fig 1d

% define electrode locations: adjacent electrode spacing = 650 um
%Make this a method as well ...
elec_spacing = 650;
electrode_locations = zeros(11,3);
electrode_locations(:,3) = (-5:5)*elec_spacing;

% define cell locations
cell_locations = {0 EAS_all 0};

% create sim
xstim = NEURON.simulation.extracellular_stim.create_standard_sim(...
    'tissue_resistivity',tissue_resistivity,'electrode_locations',electrode_locations);
cell = xstim.cell_obj;
cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
xstim.elec_objs.setStimPattern(stim_start_time,stim_duration,stim_amps);

thresh_active = zeros(N_diams,N_EAS);
thresh_mdf1 = thresh_active;
%thresh_mdf2 = thresh_active;
% get thresholds
for iDiam = 1:N_diams
    fiber_diameter = fiber_diams(iDiam);
    % change diameter
    cell.props_obj.changeFiberDiameter(fiber_diameter);
    
    % test all EAS
    thresh_active(iDiam,:) = xstim.sim__getThresholdsMulipleLocations(cell_locations);
    thresh_mdf1(iDiam,:) = obj.computeThresholdMultipleLocations(xstim,cell_locations,1);
    %thresh_mdf2(iDiam,:) = obj.computeThresholdMultipleLocations(xstim,cell_locations,2);
    
end

% normalize thresholds
thresh_active = normalizeThresholdsLocal(thresh_active);
thresh_mdf1 = normalizeThresholdsLocal(thresh_mdf1);
%thresh_mdf2 = normalizeThresholdsLocal(thresh_mdf2);

% plot
for iEAS = 1:N_EAS
    figure
    %plot(fiber_diams,thresh_active(:,iEAS),'o',fiber_diams,thresh_mdf1(:,iEAS),'s--',fiber_diams,thresh_mdf2(:,iEAS),'-','markersize',6)
    plot(fiber_diams,thresh_active(:,iEAS),'o',fiber_diams,thresh_mdf1(:,iEAS),'s--','markersize',10,'linewidth',3)
    fontsize = 18;
    xlabel('Axon Diameter [\mum]','fontsize',fontsize)
    ylabel('Normalized Activation Threshold','fontsize',fontsize)
    %legend('Active Axon','Single Node','Weighted Sum')
    legend('Active Axon','Single Node')
    title(sprintf('Electrode-to-Axon Spacing = %i \\mum',EAS_all(iEAS)),'fontsize',fontsize+2)
    xlim([4 20])
    ylim([0 1.2])
    set(gca,'fontsize',fontsize-2)
end

end

function norm_thresholds = normalizeThresholdsLocal(thresholds)
    max_thresholds = max(thresholds);
    norm_thresholds = bsxfun(@rdivide,thresholds,max_thresholds);
end