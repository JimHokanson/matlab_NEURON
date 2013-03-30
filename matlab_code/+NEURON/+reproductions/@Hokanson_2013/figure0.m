function figure0()
%
%   NEURON.reproductions.Hokanson_2013.figure0
%
%   This is a figure which attempts to summarize the calculations being
%   made in this paper.
%
%   Design Notes
%   1) Two electrodes 400 microns apart in X
%   2) Default fiber size - 10 microns


%New thoughts on setup figure
%-------------------------------------------
%1) timeline of stimuli - maybe hold off for now ...
%2) response to individual stimulus, show overlaps
%3) dual response
%4) show area overlap - it would be nice to know the volume result
%even though I am only showing the area ...

FONT_SIZE       = 18;

PAIRING_USE     = 7; %400 um separation in X direction
STEP_SIZE       = 20;

%There is a bug in arrayfcns.replicate3dData
%which doesn't support 2d data for interpolation ...
XYZ_MESH_DOUBLE = {-400:STEP_SIZE:400 [0 STEP_SIZE] -600:STEP_SIZE:600};
XYZ_MESH_SINGLE = {-200:STEP_SIZE:200 [0 STEP_SIZE] -600:STEP_SIZE:600};
X_LIM           = [-400 400];
Y_LIM           = [-600 600];
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

thresholds_single = xstim_obj.sim__getThresholdsMulipleLocations(XYZ_MESH_SINGLE);

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

thresholds_double_2d = squeeze(thresholds_double(:,1,:));

act_obj   = xstim_obj.sim__getActivationVolume();

threshold_counts_double = act_obj.getVolumeCounts(THRESHOLD_TEST);


%Plotting Results
%--------------------------------------------------------------------------
[temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single,...
                            XYZ_MESH_SINGLE,current_pair,STEP_SIZE);
                        
single_thresholds_for_plotting = squeeze(min(temp(:,1,:,:),[],4)); 
                        
                        
subplot(1,3,1)
set(gca,'FontSize',FONT_SIZE)
imagesc(xyz_single_temp{1},xyz_single_temp{3},single_thresholds_for_plotting')
axis equal
hold on
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title('Single Electrode Replicated')

subplot(1,3,2)
set(gca,'FontSize',FONT_SIZE)
imagesc(XYZ_MESH_DOUBLE{1},XYZ_MESH_DOUBLE{3},thresholds_double_2d')
hold all
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title('Sync Stim Results')


subplot(1,3,3)
set(gca,'FontSize',FONT_SIZE)
[c1,h1] = contour(xyz_single_temp{1},xyz_single_temp{3},...
    single_thresholds_for_plotting',[THRESHOLD_TEST THRESHOLD_TEST]);
hold on
[c2,h2] = contour(XYZ_MESH_DOUBLE{1},XYZ_MESH_DOUBLE{3},...
    thresholds_double_2d',[THRESHOLD_TEST THRESHOLD_TEST]);
scatter(current_pair(:,1),current_pair(:,3),100,'k','filled','^')
hold off
set(h1,'Linewidth',2,'LineColor','r')
%NOTE: Often the export of the contour produces a bunch of lines
%that don't play well together in Illustrator, minimal style
%editing in Illustrator is desired
set(h2,'Linewidth',2,'LineColor','k','LineStyle',':')
set(gca,'XLim',X_LIM,'CLim',C_LIM,'YLim',Y_LIM);
axis equal
colorbar
title(sprintf('Volume Ratio %0.2f, %d uA threshold',...
    threshold_counts_double(end)/threshold_counts_single(end),THRESHOLD_TEST))

keyboard

end