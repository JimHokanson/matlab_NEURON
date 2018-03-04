function figure_showSingleStimulusMerger
%
%   NEURON.reproductions.Hokanson_2013.figure_showSingleStimulusMerger
%
%   This was going to go into an appendix but was ultimately not included.
%
%   Show results of replicating single stimulus ...
%

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3.5];

P.ISO_STIM_PLOT = [5 10 15];

C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = true;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};

SLICE_DIMS    = {'xz' 'xz'};

EL_LOCATIONS = {[0 0 -800; 0 0 800]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL  = 30;
C.STIM_WIDTH           = {[0.2 0.4]};
C.FIBER_DIAMETERS      = 10;

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
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all{iPair} = temp_cell(1,:);
    rd_all{iPair} = temp_cell(2,:);
end

rs_long  = rs_all{1}{1};
rs_trans = rs_all{2}{1};

keyboard

YLIM = [-700 700];
XLIM = [-700 700];
CLIM = [0 40];

subplot(2,2,1)
plot(rs_trans.slice)
set(gca,'ylim',YLIM,'xlim',XLIM,'clim',CLIM)
axis image
colorbar
subplot(2,2,2)
plot(rs_trans.replicated_slice)
set(gca,'ylim',YLIM,'xlim',XLIM,'clim',CLIM)
axis image
colorbar
subplot(2,2,3)
plot(rs_long.slice)
set(gca,'ylim',YLIM,'xlim',XLIM,'clim',CLIM)
axis image
colorbar
subplot(2,2,4)
plot(rs_long.replicated_slice)
set(gca,'ylim',YLIM,'xlim',XLIM,'clim',CLIM)
axis image
colorbar




