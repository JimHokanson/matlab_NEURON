function figure0()
%
%   NEURON.reproductions.Hokanson_2013.figure0
%
%   This is a figure which attempts to summarize the calculations being
%   made in this paper.
%
%
%   I started going through and cleaning this code up, somewhat ...
%
%   Design Notes
%   1) Two electrodes 400 microns apart in X
%   2) Default fiber size - 10 microns

%? - show potential summation relative to individual summation ...

%Random placement statistics
%What is the density?

C.N_SIMS          = 10000;  %# of random drawings of neurons to use in
        %comparing random data to normal data

C.FONT_SIZE       = 18;

C.PAIRING_USE     = 7; %400 um separation in X direction
C.STEP_SIZE       = 20;

C.Y_TEST_MAX = 800;
C.Y_TEST_MIN = -1*C.Y_TEST_MAX;

%There is a bug in arrayfcns.replicate3dData
%which doesn't support 2d data for interpolation ...
C.XYZ_MESH_DOUBLE = {-500:C.STEP_SIZE:500 [0 C.STEP_SIZE] C.Y_TEST_MIN:C.STEP_SIZE:C.Y_TEST_MAX};
C.XYZ_MESH_SINGLE = {-300:C.STEP_SIZE:300 [0 C.STEP_SIZE] C.Y_TEST_MIN:C.STEP_SIZE:C.Y_TEST_MAX};
C.X_LIM           = [-500 500];
C.Y_LIM           = [-800 800];
C.X_MERGE_Y_LIMS  = [-200 200]; %Where to draw the lines
C.C_LIM           = [0 35];

C.STIM_RESOLUTION = 0.1;

C.MAX_THRESHOLD   = 30;
MIN_STIM_TO_COUNT = 2;

C.THRESHOLD_TEST  = 10;

n_neurons = 1000; %TODO: Eventually make this dependent on the density

obj          = NEURON.reproductions.Hokanson_2013;
current_pair = obj.ALL_ELECTRODE_PAIRINGS{C.PAIRING_USE};


temp_struct = helper__getRecruitmentData(obj,C,current_pair);

threshold_counts_double = temp_struct.threshold_counts_double;
extras_double           = temp_struct.extras_double;
threshold_counts_single = temp_struct.threshold_counts_single;
extras_single           = temp_struct.extras_single;
thresholds_single_non_rep = temp_struct.thresholds_single_plotting;
thresholds_double_2d    = temp_struct.thresholds_double_2d;





stim_amplitudes_used = extras_single.stim_amplitudes;
xyz_used_single      = extras_single.xyz_cell;
xyz_used_double      = extras_double.xyz_cell;

%Plotting Results
%--------------------------------------------------------------------------
avg_node_spacing      = temp_struct.xstim_obj.cell_obj.getAverageNodeSpacing;
half_avg_node_spacing = avg_node_spacing/2;

%NOTE: The output of the volume counts will give us this info ...
%Use that instead ???
[temp,xyz_single_temp] = arrayfcns.replicate3dData(thresholds_single_non_rep,...
                            C.XYZ_MESH_SINGLE,current_pair,C.STEP_SIZE);
                        
              
thresholds_single_2d = squeeze(min(temp(:,1,:,:),[],4)); 
        
line_props = {'Color' 'w' 'Linewidth' 3 'LineStyle' '-'};
    
z_lim = [half_avg_node_spacing half_avg_node_spacing];
z_line_top    = @()(line(C.X_LIM,z_lim,line_props{:}));
z_line_bottom = @()(line(C.X_LIM,-z_lim,line_props{:}));

line_props{2} = 'k';
x_line        = @()(line([0 0],C.X_MERGE_Y_LIMS,line_props{:}));


figure()
%scatter(0,0,100,'w','filled','^')
%hold on
tcs_non_replicated = squeeze(thresholds_single_non_rep(:,1,:))';    
h = imagesc(C.XYZ_MESH_SINGLE{1},C.XYZ_MESH_SINGLE{3},tcs_non_replicated);
%PLOT_imagescToPatch(h);
axis equal
% scatter(0,0,100,'w','filled','^')
% hold off
colorbar
set(gca,'CLim',C.C_LIM);


figure()
%NOTE: This looks better if the figure is magnified first ...
subplot(1,3,1)
set(gca,'FontSize',C.FONT_SIZE)
h = imagesc(xyz_single_temp{1},xyz_single_temp{3},thresholds_single_2d');
%PLOT_imagescToPatch(h);
axis equal
hold on
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
axis equal
set(gca,'XLim',C.X_LIM,'CLim',C.C_LIM,'YLim',C.Y_LIM);
axis equal
z_line_top();
z_line_bottom();
x_line();
colorbar
title('Non-Simultaneous Stim')
xlabel('X')
ylabel('Z - main neuron axis')

subplot(1,3,2)
set(gca,'FontSize',C.FONT_SIZE)
h = imagesc(C.XYZ_MESH_DOUBLE{1},C.XYZ_MESH_DOUBLE{3},thresholds_double_2d');
%PLOT_imagescToPatch(h);
hold all
scatter(current_pair(:,1),current_pair(:,3),100,'w','filled','^')
hold off
axis equal
set(gca,'XLim',C.X_LIM,'CLim',C.C_LIM,'YLim',C.Y_LIM);
axis equal
z_line_top();
z_line_bottom();
x_line();
colorbar
title('Simultaneous Stim')
xlabel('X')
ylabel('Z - main neuron axis')

subplot(1,3,3)
set(gca,'FontSize',C.FONT_SIZE)
%NOTE: This is for plotting only, the number listed in the title
%already takes this into account
y_keep = xyz_single_temp{3} >= -half_avg_node_spacing & xyz_single_temp{3} <= half_avg_node_spacing;
[c1,h1] = contour(xyz_single_temp{1},xyz_single_temp{3}(y_keep),...
    thresholds_single_2d(:,(y_keep))',[C.THRESHOLD_TEST C.THRESHOLD_TEST]);

%y_keep = xyz_used_double{3} >= -half_avg_node_spacing & xyz_used_double{3} <= half_avg_node_spacing;
hold on
[c2,h2] = contour(C.XYZ_MESH_DOUBLE{1},C.XYZ_MESH_DOUBLE{3}(y_keep),...
    thresholds_double_2d(:,(y_keep))',[C.THRESHOLD_TEST C.THRESHOLD_TEST]);
scatter(current_pair(:,1),current_pair(:,3),100,'k','filled','^')
hold off
set(h1,'Linewidth',2,'LineColor','r')
%NOTE: Often the export of the contour produces a bunch of lines
%that don't play well together in Illustrator, minimal style
%editing in Illustrator is desired
set(h2,'Linewidth',2,'LineColor','k','LineStyle','-')
set(gca,'XLim',C.X_LIM,'CLim',C.C_LIM,'YLim',C.Y_LIM);
axis equal
colorbar
value_show = find(stim_amplitudes_used == C.THRESHOLD_TEST);
title(sprintf('Volume Ratio %0.2f, %d uA threshold',...
    threshold_counts_double(value_show)/threshold_counts_single(value_show),C.THRESHOLD_TEST))


%==========================================================================
%==========================================================================
%                            Growth Rates
%==========================================================================
%==========================================================================

internode_length = temp_struct.xstim_obj.cell_obj.getAverageNodeSpacing;

[temp,xyz_single_temp_g] = temp_struct.act_obj_single.getSliceThresholds(C.MAX_THRESHOLD,2,0,'replication_points',current_pair);                        
     
thresholds_single_2d_g = squeeze(temp);

figure()
subplot(3,1,1)
set(gca,'FontSize',18);
counts_merged = [threshold_counts_double(:) threshold_counts_single(:)];
plot(stim_amplitudes_used,counts_merged,'Linewidth',3)
ylabel('Volumes')
legend({'Simultaneous','Independent'})
subplot(3,1,2)
set(gca,'FontSize',18);
[x_new,dy] = arrayfcns.getDerivative(stim_amplitudes_used,counts_merged,0.1);
%[x_new,dy] = arrayfcns.getDerivative(x_new,dy,1);
plot(x_new,dy,'Linewidth',3)

[x_lim__amp,z_lim__amp,x_lim__y_val,z_lim__y_val] = ...
                getLimitInfo(obj,x_new(:),dy(:,2),thresholds_single_2d_g,xyz_single_temp_g,internode_length);
[X_lim__amp,Z_lim__amp,X_lim__y_val,Z_lim__y_val] = ...
                getLimitInfo(obj,x_new(:),dy(:,1),thresholds_double_2d,C.XYZ_MESH_DOUBLE,internode_length);

            
%plotLimits(obj,xz_amp,xz_value)            
obj.plotLimits([x_lim__amp,z_lim__amp,X_lim__amp,Z_lim__amp],[x_lim__y_val,z_lim__y_val,X_lim__y_val,Z_lim__y_val])
ylabel('Derivatives')

subplot(3,1,3)
set(gca,'FontSize',18);
plot(stim_amplitudes_used,threshold_counts_double./threshold_counts_single,'Linewidth',3);
ylabel('Volume Ratio')
xlabel('Stimulus Amplitudes')

%==========================================================================
%==========================================================================
%                         Random Simulation
%==========================================================================
%==========================================================================
%Do I then want to show the results as will be presented in the next figure
%for this figure?
%1) Volume with varying amplitude
%2) Random placement ...

s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);

n_xyz_total = C.N_SIMS*n_neurons;
xyz = zeros(n_xyz_total,3);
xyz(:,1) = 2*(rand(1,n_xyz_total)-0.5)*xyz_used_double{1}(end);
xyz(:,2) = 2*(rand(1,n_xyz_total)-0.5)*xyz_used_double{2}(end);
xyz(:,3) = 2*(rand(1,n_xyz_total)-0.5)*half_avg_node_spacing;

estimated_thresholds_single = temp_struct.act_obj_single.computeThresholdsRandomNeurons(xyz,C.MAX_THRESHOLD,'replication_points',current_pair);
estimated_thresholds_dual   = temp_struct.act_obj_dual.computeThresholdsRandomNeurons(xyz,C.MAX_THRESHOLD);

estimated_thresholds_single_r = reshape(estimated_thresholds_single,[C.N_SIMS n_neurons]);
estimated_thresholds_dual_r   = reshape(estimated_thresholds_dual,[C.N_SIMS n_neurons]);

%Thresholds to n

n_single = histc(estimated_thresholds_single_r,[0 stim_amplitudes_used],2);
n_double = histc(estimated_thresholds_dual_r,[0 stim_amplitudes_used],2);

n_keep = length(stim_amplitudes_used);

n_single_c = cumsum(n_single(:,1:n_keep),2);

%??? What value is encompassed by the plotted limit
%See figure for rough value ...
%ONLY VALID UP TO 10 ...
n_double_c = cumsum(n_double(:,1:n_keep),2);

vol_ratio = n_double_c./n_single_c;


%We run into problems at low amplitudes where we have nothing
%for the single but 1 or more for the double, which yields Inf for the
%ratio 
%Compute inverse then

vol_ratio_inverse = n_single_c./n_double_c;

%vol_sort = sort(vol_ratio_inverse,1);
%Get 95% confidence intervals for each point
%How to do when discrete - use bootstrap procedure?????
%You need to ask, what if I had done this a couple of times, let's say 10
%Then you select from the group 10, average those, and that counts as 
%an observation. This is a distribution estimate of the mean ...

mean_vol_ratio = 1./nanmean(vol_ratio_inverse);

figure()
subplot(1,2,1)
plot(stim_amplitudes_used,vol_ratio(1:1000:end,:)')
set(gca,'YLim',[1 10],'FontSize',18)
ylabel('Volume Ratio')
xlabel('Stimulus Amplitudes (uA)')
subplot(1,2,2)
plot(stim_amplitudes_used,vol_ratio')
hold on
plot(stim_amplitudes_used,threshold_counts_double./threshold_counts_single,'Linewidth',3,'Color','k')
plot(stim_amplitudes_used,mean_vol_ratio,'Linewidth',3,'Color','w')
hold off
set(gca,'YLim',[1 10],'FontSize',18)

end

function temp_struct = helper__getRecruitmentData(obj,C,current_pair)

%Thresholds single electrode
%--------------------------------------------------------------------------
options = {...
    'electrode_locations',[0 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

thresholds_single = xstim_obj.sim__getThresholdsMulipleLocations(C.XYZ_MESH_SINGLE);

%NEURON.simulation.extracellular_stim.results.activation_volume
act_obj_single   = xstim_obj.sim__getActivationVolume();
%act_obj.bounds(:,3) = [C.Y_TEST_MIN; C.Y_TEST_MAX];

[threshold_counts_single,extras_single] = act_obj_single.getVolumeCounts(C.MAX_THRESHOLD,...
               'replication_points',current_pair,'stim_resolution',C.STIM_RESOLUTION);


           
%Thresholds double electrode
%---------------------------------------------------------------------------
options = {...
    'electrode_locations',current_pair,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

thresholds_double = xstim_obj.sim__getThresholdsMulipleLocations(C.XYZ_MESH_DOUBLE);

thresholds_double_2d = squeeze(thresholds_double(:,1,:));

act_obj_dual  = xstim_obj.sim__getActivationVolume();

[threshold_counts_double,extras_double] = act_obj_dual.getVolumeCounts(C.MAX_THRESHOLD,'stim_resolution',C.STIM_RESOLUTION);

temp_struct = struct;
temp_struct.threshold_counts_double = threshold_counts_double;
temp_struct.extras_double = extras_double;
temp_struct.threshold_counts_single = threshold_counts_single;
temp_struct.extras_single = extras_single;
temp_struct.thresholds_single_plotting = thresholds_single;
temp_struct.thresholds_double_2d = thresholds_double_2d;
temp_struct.xstim_obj = xstim_obj;
temp_struct.act_obj_single = act_obj_single;
temp_struct.act_obj_dual = act_obj_dual;

end