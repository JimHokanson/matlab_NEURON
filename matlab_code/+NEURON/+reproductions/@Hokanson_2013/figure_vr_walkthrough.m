function figure_vr_walkthrough()
%
%   NEURON.reproductions.Hokanson_2013.figure_vr_walkthrough
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

keyboard
%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%Thresholds (Independent, Simultaneous), Contours


%THRESHOLD MAPS FIRST
%--------------------------------------------------------------
X_LIMITS = {[-400 400] [-400 400]; [-400 400] [-400 400]};

C_LIM_MAX_ALL = [25 25; 25 25];

plot_indices = [1 2; 4 5];

I = 1;

figure(3)
clf
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
plot_indices2 = [3 6];
for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(2,3,plot_indices2(iPair))
hold all
contour(temp_s.replicated_slice,amps_plot(iPair,:))
%contour(temp_s.replicated_slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);

%subplot(2,2,plot_indices(iPair,2))
contour(temp_d.slice,amps_plot(iPair,:)+0.05) %This helps us with illustrator :/
%contour(temp_d.slice,amps_plot(iPair,2))
% colorbar
% set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);
title(TITLE_STRINGS{iPair})
set(gca,'xlim',X_LIMITS{1})
axis equal
colorbar
set(gca,'clim',[0 C_LIM_MAX_ALL(iPair,1)]);


end




%1) Standard, vs amplitude ...
figure(1)
clf
I = 1;
plot_indices2 = [1 3; 2 4];

for iPair = 1:2
    
    temp_s = rs_all{iPair}{I};
    temp_d = rd_all{iPair}{I};
    
    s = temp_s.stimulus_amplitudes;
    ds = s(2)-s(1);
    c1 = temp_s.counts;
    c2 = temp_d.counts;
    
    final_strings = sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
    
    subplot(2,2,plot_indices2(iPair,1))
    plot(s,c1,s,c2)
    set(gca,'FontSize',18)
    ylabel('Volume (um^3)')
    legend({'Independent','Simultaneous'})
    
    subplot(2,2,plot_indices2(iPair,2))
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end





figure(5)

%1) Standard, vs amplitude ...
clf
I = 1;
plot_indices2 = [1 3 5; 2 4 6];

for iPair = 1:2
    
    temp_s = rs_all{iPair}{I};
    temp_d = rd_all{iPair}{I};
    
    s = temp_s.stimulus_amplitudes;
    ds = s(2)-s(1);
    c1 = temp_s.counts;
    c2 = temp_d.counts;
    
    %NOTE: This might not be in the NEURON library
    %- computes difference by averaging differences of 
    dc1 = dif2(c1)./ds;
    dc2 = dif2(c2)./ds;
    
    B = 1/3*ones(1,3);
    
    dc1 = filtfilt(B,1,dc1);
    dc2 = filtfilt(B,1,dc2);
        
    subplot(3,2,plot_indices2(iPair,1))
    final_strings = sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
    
    
    subplot(3,2,plot_indices2(iPair,2))
    plot(s,dc1,s,dc2)
    set(gca,'FontSize',18)
    %plot(s,abs(dc1),s,abs(dc2))
    legend({'Independent','Simultaneous'})
    ylabel('1st Derivative (um^3/uA)')
    dc1 = dif2(abs(dc1))./ds;
    dc2 = dif2(abs(dc2))./ds;
    
    
    subplot(3,2,plot_indices2(iPair,3))
    plot(s,dc1,s,dc2)
    set(gca,'FontSize',18)
    %plot(s,abs(dc1),s,abs(dc2))
    legend({'Independent','Simultaneous'})
    ylabel('2nd Derivative (um^3/uA^2)')


end



%Amplitudes of interest
%----------------------------------------------------------
%Long 
%   - 2.2, 6.9 - s
%   - 3.5, 8.9
%Trans 
%   - 7, 11.4 - s
%   - 14.1 16.9 - i


figure(6)
clf
%           Longitudinal                  Transverse
%           Simultaneous   Independent    Simultaneous   Independent
amps_plot = [2.2    7.1    3.5    8.9;    7.3    11.8    14.2     17.5];

I = 1;
plot_indices3 = [1 2; 3 4];
for iPair = 1:2
temp_s = rs_all{iPair}{I};
temp_d = rd_all{iPair}{I};


subplot(2,2,plot_indices3(iPair,1))
contour(temp_s.replicated_slice,amps_plot(iPair,3:4))
title(sprintf('%s, Independent',TITLE_STRINGS{iPair}))
set(gca,'xlim',[-500 500])
axis equal

subplot(2,2,plot_indices3(iPair,2))
contour(temp_d.slice,amps_plot(iPair,1:2))
title(sprintf('%s, Simultaneous',TITLE_STRINGS{iPair}))
set(gca,'xlim',[-500 500])
axis equal


end

