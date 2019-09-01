function figure_populationResponseVariability()
%
%   NEURON.reproductions.Hokanson_2013.figure_populationResponseVariability
%

%This is a work in progress

%Schiefer 2008
%   - source 20, human tibial nerve
%   H. S. Garven, F. W. Gairns, and G. Smith, “The nerve fibre populations
% of the nerves of the leg in chronic occlusive arterial disease in man,”
% Scott. Med. J., vol. 7, pp. 250–265, 1962.
%
%Mahnam 2009
%   - Eccles
%13.6 um mean
%1.55 um variance
%400 neurons
%400 um diameter
%
%
%Raspopovic 2011
% - mean 8.74 um
% - 1.5 standard deviation
% - source 24???
%
%   J. Badia, A. Pascual-Font, M. Vivo, E. Udina, and X. Navarro, “Top-
%   ographical distribution of motor fascicles in the sciatic-tibial nerve
%   of the rat,” Muscle Nerve, vol. 42, no. 2, pp. 192–201, 2010.
%
%Rutten 1991
% - 0.5 mm diameter
% - 350 a motor fibers
% - SOURCE 18
%   
%   R. Close, "Properties of motor units in fast and slow skeletal muscles
%   of the rat," J. Physiol., vol. 193, pp. 45~55. 1967.
%
%   OTHERS
%---------------------------------------------
% Boyd and Davey 1968
%   


%   Perhaps just take the density and expand ...


import NEURON.reproductions.*

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

%SLICE_DIMS    = {'zy' 'xz'};
SLICE_DIMS    = {'xz' 'xz'};

EL_LOCATIONS = {[0 0 -200; 0 0 200] [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 20; %Not sure I want to run this to 30, given my example ...

%C.MAX_STIM_LEVELS         = [90 80 70 50 40 30 20 20 20];



C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = 14;
C.MAX_STIM_LEVELS         = 35; %This can impact whether or not C.X_LIMITS is valid
C.N_SIMS                  = 10000; %# of simulations to run


C.X_LIMITS = [-400 400];
X_DIFF = C.X_LIMITS(2) - C.X_LIMITS(1);

%13.6 um mean
%1.55 um variance
%400 neurons
%400 um diameter
%Area = pi*d^2/4
DENSITY = 400/(pi*400^2/4);
%0.0032 per um^2
C.N_NEURONS = ceil(X_DIFF^2*DENSITY);


%C.MAX_DIAMETER            = 

n_diameters = length(C.FIBER_DIAMETERS);

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:n_diameters
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_LEVELS(iDiameter),...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_LEVELS(iDiameter));
    end
    rs_all{iPair} = temp_cell(1,:);
    rd_all{iPair} = temp_cell(2,:);
end

bounds_all = zeros(2,2);
for iPair = 1:2
   bounds_all(iPair,1) = rs_all{iPair}{1}.xyz_used{1}(1);
   bounds_all(iPair,2) = rd_all{iPair}{1}.xyz_used{1}(1);
end

%==========================================================================
%==========================================================================
%                         Random Simulation
%==========================================================================
%==========================================================================

figure(30)
clf

for iPair = 1:2

half_avg_node_spacing = rs_all{1}{1}.internode_length/2;

s = RandStream('mt19937ar','Seed',1);
RandStream.setGlobalStream(s);

xyz_used_double   = rd_all{iPair}{1}.xyz_used;
thresholds_double = rd_all{iPair}{1}.raw_abs_thresholds;
Ix_1 = find(xyz_used_double{1} == -400);
Ix_2 = find(xyz_used_double{1} == 400);
Iy_1 = find(xyz_used_double{2} == -400);
Iy_2 = find(xyz_used_double{2} == 400);
xyz_used_double_trimmed   = [{xyz_used_double{1}(Ix_1:Ix_2) xyz_used_double{2}(Iy_1:Iy_2)} xyz_used_double(3)];
thresholds_double_trimmed = thresholds_double(Ix_1:Ix_2,Iy_1:Iy_2,:);

xyz_used_single   = rs_all{iPair}{1}.xyz_used;
thresholds_single = rs_all{iPair}{1}.raw_abs_thresholds;
Ix_1 = find(xyz_used_single{1} == C.X_LIMITS(1));
Ix_2 = find(xyz_used_single{1} == C.X_LIMITS(2));
Iy_1 = find(xyz_used_single{2} == C.X_LIMITS(1));
Iy_2 = find(xyz_used_single{2} == C.X_LIMITS(2));
xyz_used_single_trimmed   = [{xyz_used_single{1}(Ix_1:Ix_2) xyz_used_single{2}(Iy_1:Iy_2)} xyz_used_single(3)];
thresholds_single_trimmed = thresholds_single(Ix_1:Ix_2,Iy_1:Iy_2,:);

stim_amplitudes_used = rs_all{iPair}{1}.stimulus_amplitudes;
threshold_counts_double = rd_all{iPair}{1}.counts;
threshold_counts_single = rs_all{iPair}{1}.counts;


%Generate locations of a random set of neurons
%--------------------------------------------------------------------------
n_xyz_total = C.N_SIMS*C.N_NEURONS;
xyz = zeros(n_xyz_total,3);
xyz(:,1) = (rand(1,n_xyz_total)-0.5)*X_DIFF;
xyz(:,2) = (rand(1,n_xyz_total)-0.5)*X_DIFF;
xyz(:,3) = 2*(rand(1,n_xyz_total)-0.5)*half_avg_node_spacing;



x = xyz_used_single_trimmed{1};
y = xyz_used_single_trimmed{2};
z = xyz_used_single_trimmed{3};
estimated_thresholds_single = interpn(x,y,z,thresholds_single_trimmed,xyz(:,1),xyz(:,2),xyz(:,3),'linear',NaN);

x = xyz_used_double_trimmed{1};
y = xyz_used_double_trimmed{2};
z = xyz_used_double_trimmed{3};
estimated_thresholds_dual = interpn(x,y,z,thresholds_double_trimmed,xyz(:,1),xyz(:,2),xyz(:,3),'linear',NaN);

estimated_thresholds_single_r = reshape(estimated_thresholds_single,[C.N_SIMS C.N_NEURONS]);
estimated_thresholds_dual_r   = reshape(estimated_thresholds_dual,[C.N_SIMS C.N_NEURONS]);

x_r = reshape(xyz(:,1),C.N_SIMS,C.N_NEURONS);
y_r = reshape(xyz(:,2),C.N_SIMS,C.N_NEURONS);
z_r = reshape(xyz(:,3),C.N_SIMS,C.N_NEURONS);


%Thresholds to n
%--------------------------------------------------------------------------
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

if iPair == 1
   figure(1)
   clf
   %pair_indices
end

XLIM = [0 30];
YLIM = [1 6];

% % % subplot(2,3,1)
% % % plot(stim_amplitudes_used,vol_ratio(1:1000:end,:)')
% % % set(gca,'ylim',YLIM,'xlim',XLIM,'FontSize',18)
% % % ylabel('Volume Ratio')
% % % xlabel('Stimulus Amplitudes (uA)')

STIM_AMP_AVG = find(stim_amplitudes_used == 20,1);
wtf = nanmean(vol_ratio(:,1:STIM_AMP_AVG),2);

[~,I_max] = max(wtf(~isinf(wtf)));
[~,I_min] = min(wtf);

% % % xyz_min = [x_r(I_min,:); y_r(I_min,:); z_r(I_min,:)]';
% % % xyz_max = [x_r(I_max,:); y_r(I_max,:); z_r(I_max,:)]';

subplot(1,2,iPair)
%plot(stim_amplitudes_used,vol_ratio')

vol_ratio_NaN = vol_ratio;
vol_ratio_NaN(isinf(vol_ratio_NaN)) = NaN;

y = quantile(vol_ratio_NaN,0.1:0.1:0.9,1);
all_colors = zeros(8,3);
red_color  = linspace(0.3,1,4)';
all_colors(:,1) = [red_color; red_color(end:-1:1)];
y(5,:) = [];
line_widths = [0.5 1 1.5 2 2 1.5 1 0.5];
hold on
for iPct = 1:8
plot(stim_amplitudes_used,y(iPct,:),'Color',all_colors(iPct,:),'Linewidth',line_widths(iPct))
end
h1 = plot(stim_amplitudes_used,threshold_counts_double./threshold_counts_single,'Linewidth',3,'Color','k');
h2 = plot(stim_amplitudes_used,mean_vol_ratio,':','Linewidth',3,'Color','y');

% plot(stim_amplitudes_used,vol_ratio(I_min,:),'g')
% plot(stim_amplitudes_used,vol_ratio(I_max,:),'b')

hold off
legend([h1 h2],{'From Volume' 'From Random'})
set(gca,'ylim',YLIM,'xlim',XLIM,'FontSize',18)
if iPair == 1
    title('Longitudinal Pairing')
else
    title('Transverse Pairing')
end
xlabel('Stimulus Amplitude (uA)')
ylabel('Volume and Neuron Ratios')
set(gca,'ylim',[1 5])
% subplot(2,3,3)
% plot(stim_amplitudes_used,nanmean(n_single_c,1));
% hold on
% plot(stim_amplitudes_used,nanmean(n_double_c,1));
% hold off
% set(gca,'xlim',XLIM,'FontSize',18)

end

