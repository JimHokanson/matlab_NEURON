function figure2()
%
%   NEURON.reproductions.Hokanson_2013.figure2
%
%   This is Figure 4 in the final paper.
%
%   =======================================================================
%                       MULTIPLE FIBER DIAMETERS
%   =======================================================================
%
%   
%
%   The goal here is to explore the effect of different fiber diameters on
%   the volume ratio.
%

import NEURON.reproductions.*

DIAMETER_FOR_SLICE = 10;

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3.5];

P.ISO_STIM_PLOT = [5 10 15];

C.MAX_STIM_TEST_LEVEL = 30;

%NEURON.reproductions.Hokanson_2013
obj = Hokanson_2013;

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor
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

%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%Main Result
%------------
figure(40)
clf
for iPair = 1:2
    ax(iPair) = subplot(1,2,iPair);
    final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair}(end:-1:1),rd_all{iPair}(end:-1:1));
    legend(final_strings(end:-1:1))
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

end