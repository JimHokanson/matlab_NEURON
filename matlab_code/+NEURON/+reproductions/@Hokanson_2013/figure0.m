function figure0()
%
%   NEURON.reproductions.Hokanson_2013.figure0
%
%   Design Notes
%   1) Two electrodes 400 microns apart in X
%   2) Default fiber size - 

%New thoughts on setup figure
%-------------------------------------------
%1) timeline of stimuli - maybe hold off for now ...
%2) response to individual stimulus, show overlaps
%3) dual response
%4) show area overlap - it would be nice to know the volume result
%even though I am only showing the area ...


PAIRING_USE = 7; %400 um separation in X direction
XYZ_MESH_DOUBLE = {-400:20:400 0 -600:20:600};
XYZ_MESH_SINGLE = {-180:20:180 0 -600:20:600};
X_SHIFT_SINGLE  = 200;
X_LIM           = [-400 400];
Y_LIM           = [-800 800];
C_LIM           = [0 25];
THRESHOLD_TEST  = 10;

obj          = NEURON.reproductions.Hokanson_2013;
current_pair = obj.ALL_ELECTRODE_PAIRINGS{PAIRING_USE};

%Thresholds single electrode
%--------------------------------------------------------------------------
options = {...
    'electrode_locations',[0 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

%TODO: Shift thresholds to be on the one pair, crop results ....
thresholds_single = xstim_obj.sim__getThresholdsMulipleLocations(XYZ_MESH_SINGLE);

thresholds_single = squeeze(thresholds_single)';

act_obj   = xstim_obj.sim__getActivationVolume();

threshold_counts_single = act_obj.getVolumeCounts(THRESHOLD_TEST,...
               'replication_points',current_pair);
           
%Thresholds double electrode
%---------------------------------------------------------------------------
options = {...
    'electrode_locations',current_pair,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

thresholds_double = xstim_obj.sim__getThresholdsMulipleLocations(XYZ_MESH_DOUBLE);

thresholds_double = squeeze(thresholds_double)';

act_obj   = xstim_obj.sim__getActivationVolume();

threshold_counts_double = act_obj.getVolumeCounts(THRESHOLD_TEST);

%Plotting Results
%--------------------------------------------------------------------------
subplot(1,3,1)
imagesc(XYZ_MESH_SINGLE{1}-X_SHIFT_SINGLE,XYZ_MESH_SINGLE{3},thresholds_single)
hold all
imagesc(XYZ_MESH_SINGLE{1}+X_SHIFT_SINGLE,XYZ_MESH_SINGLE{3},thresholds_single)
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title('Single Electrode Replicated')

subplot(1,3,2)
imagesc(XYZ_MESH_DOUBLE{1},XYZ_MESH_DOUBLE{3},thresholds_double)
hold all
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title('Sync Stim Results')


subplot(1,3,3)
[c1,h1] = contour(XYZ_MESH_SINGLE{1}-X_SHIFT_SINGLE,XYZ_MESH_SINGLE{3},...
    thresholds_single,[THRESHOLD_TEST THRESHOLD_TEST]);
hold on
[c2,h2] = contour(XYZ_MESH_SINGLE{1}+X_SHIFT_SINGLE,XYZ_MESH_SINGLE{3},...
    thresholds_single,[THRESHOLD_TEST THRESHOLD_TEST]);
[c3,h3] = contour(XYZ_MESH_DOUBLE{1},XYZ_MESH_DOUBLE{3},...
    thresholds_double,[THRESHOLD_TEST THRESHOLD_TEST]);
scatter(current_pair(:,1),current_pair(:,3),100,'k','filled','^')
hold off
set(h1,'Linewidth',2,'LineColor','r')
set(h2,'Linewidth',2,'LineColor','r')
%NOTE: Often the export of the contour produces a bunch of lines
%that don't play well together in Illustrator, minimal style
%editing in Illustrator is desired
set(h3,'Linewidth',2,'LineColor','k','LineStyle',':')
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title(sprintf('Volume Ratio %0.2f, %d uA threshold',...
    threshold_counts_double/threshold_counts_single,THRESHOLD_TEST))

keyboard

end