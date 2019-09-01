function figure_vr_walkthrough()
%
%   NEURON.reproductions.Hokanson_2013.figure_vr_walkthrough
%
%   Final figure 2
%
%   This figure illustrates:
%   - slice thresholds
%   - iso-threshold contours
%   - volumes of the individual components
%   - the resulting volume ratios ...

import NEURON.reproductions.*

DIAMETER_USE = 10;

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3];

P.ISO_STIM_PLOT = [5 10 15];

C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};

%SLICE_DIMS    = {'zy' 'xz'};
SLICE_DIMS    = {'xz' 'xz'};

%EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};
EL_LOCATIONS = {[0 0 -200; 0 0 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,1);
    
    %avr : NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:1
        avr.fiber_diameter = DIAMETER_USE;
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all{iPair} = temp_cell(1,:);
    rd_all{iPair} = temp_cell(2,:);
end

%--------------------------------------------------------------------------
%Results cited in text ...
min_ratios = zeros(1,2);
max_ratios = zeros(1,2);
median_ratios = zeros(1,2);
for i = 1:2

sync = rd_all{i}{1};
async = rs_all{i}{1};

xyz_sync = sync.xyz_used;
xyz_async = async.xyz_used;

x_sync = xyz_sync{1};
y_sync = xyz_sync{2};

x_async = xyz_async{1};
y_async = xyz_async{2};
z_async = xyz_async{3};

mask = ismember(x_sync,x_async);

x_I1 = find(mask,1);
x_I2 = find(mask,1,'last');

mask = ismember(y_sync,y_async);

y_I1 = find(mask,1);
y_I2 = find(mask,1,'last');

async_thresholds = async.raw_abs_thresholds;
sync_thresholds = sync.raw_abs_thresholds(x_I1:x_I2,y_I1:y_I2,:);

ratio = sync_thresholds./async_thresholds;

%Ratios at low values are subject to errors based on the resolution 
%we solved for
%
%limit to 1 uA and greater

ratio2 = ratio(async_thresholds >= 1);

min_ratios(i) = min(ratio2);
max_ratios(i) = max(ratio2);
median_ratios(i) = median(ratio2);

end



%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%Thresholds (Independent, Simultaneous), Contours


%THRESHOLD MAPS FIRST
%--------------------------------------------------------------
X_LIMITS = {[-500 500] [-500 500]; [-500 500] [-500 500]};

C_LIM_MAX_ALL = [25 25; 25 25];

plot_indices = [1 2; 4 5];

I = 1;

figure(201)
clf
colormap('jet')
for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(2,3,plot_indices(iPair,1))
plot(temp_s.replicated_slice,'lim_dim1',X_LIMITS{iPair,1})
colorbar
set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

subplot(2,3,plot_indices(iPair,2))
plot(temp_d.slice,'lim_dim1',X_LIMITS{iPair,2})
colorbar
set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);
end


%NOW FOR THE CONTOURS
%--------------------------------------------------------------
amps_plot = [5 10 15; 5 10 15];

I = 1;

figure(202)
clf
c = 'bgr';
colormap('jet')
for iPair = 1:2
    temp_s = rs_all{iPair}{I};
    temp_d = rd_all{iPair}{I};

    subplot(1,2,iPair)
    hold all
    for iAmp = 1:3
        [~,h1] = contour(temp_s.replicated_slice,amps_plot(iPair,iAmp));
        set(h1,'Color',c(iAmp),'LineStyle',':');

        [~,h2] = contour(temp_d.slice,amps_plot(iPair,iAmp));
        set(h2,'Color',c(iAmp));
        title(TITLE_STRINGS{iPair})
    end
    
    axis equal
    set(gca,'xlim',X_LIMITS{1})
    colorbar
    set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

end



%1) Standard, vs amplitude ...
figure(203)
clf
I = 1;
plot_indices2 = [1 3; 2 4];

for iPair = 1:2
    
    temp_s = rs_all{iPair}{I};
    temp_d = rd_all{iPair}{I};
    
    s = temp_s.stimulus_amplitudes;
    ds = s(2)-s(1);
    
    %NOTE: Counts are in units of um^3
    c1 = temp_s.counts./(1000^3);
    c2 = temp_d.counts./(1000^3);
    
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
    
    subplot(2,2,plot_indices2(iPair,1))
    plot(s,c1,'b',s,c2,'g')
    set(gca,'FontSize',18)
    ylabel('Volume (mm^3)')
    %ylabel('Volume (um^3)')
    legend({'Non-simultaneous','Simultaneous'})
    set(gca,'ylim',[0 1.2])
    
    subplot(2,2,plot_indices2(iPair,2))
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

%==========================================================================
figure(204)
clf
I = 1;
plot_indices2 = [1 3; 2 4];

for iPair = 1:2
    
    temp_s = rs_all{iPair}{I};
    temp_d = rd_all{iPair}{I};
    
    s = temp_s.stimulus_amplitudes;
    ds = s(2)-s(1);
    
    %NOTE: Counts are in units of um^3
    c1 = temp_s.counts./(1000^3);
    c2 = temp_d.counts./(1000^3);
    
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
    
    ax = subplot(2,2,plot_indices2(iPair,1));
    plot(s,c1,'b',s,c2,'g')
    semilogy(s,c1,'b',s,c2,'g')
    set(gca,'FontSize',18)
    ylabel('Volume (mm^3)')
    %ylabel('Volume (um^3)')
    legend({'Non-simultaneous','Simultaneous'})
    %set(gca,'ylim',[0 1.2])
    set(ax,'ylim',[1e-4 1.2])
    
    subplot(2,2,plot_indices2(iPair,2))
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

end


