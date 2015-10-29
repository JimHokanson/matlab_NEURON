function figure_boundeIllustrationPart2()
%
%   NEURON.reproductions.Hokanson_2013.figure_boundeIllustrationPart2
%
%   NOT CURRENTLY USED
%

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
EL_LOCATIONS = {[0 0 -800;0 0 800]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:1
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
    
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
    
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
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',DIAMETER_USE);
        
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
    set(gca,'ylim',[-1e7 2e7])
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
amps_plot = [2.2    7    3.5    8.9;    7    11.5    14.3     17.2];

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

figure(5)
%g - simultaneous
%b - independent

%plot_indices2 = [1 3 5; 2 4 6];

c = 'ggbb';

for iRow = 1:3
    for iPair = 1:2
    I = plot_indices2(iPair,iRow);
    subplot(3,2,I)
    hold on
    y_lim = get(gca,'ylim');
    for iType = 1:4
    x = amps_plot(iPair,iType);
    line([x x],y_lim,'Color',c(iType))
    end
    end
    
end



