function figure7()
%
%   NEURON.reproductions.Hokanson_2013.figure7
%
%   =======================================================================
%                       MULTIPLE FIBER DIAMETERS
%   =======================================================================
%
%   The goal here is to explore the effect of different fiber diameters on
%   the volume ratio.
%
%   This is tentatively:
%       NEW FIGURE 2

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3];



C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = true;
avr.merge_solvers  = false;
avr.use_new_solver = true;

RESISTIVITY   = {[500 500 500] [1211 1211 350] [1211 1211 87.5] [1211 1211 175]};
TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};
SLICE_DIMS    = {'zy' 'xz'};
EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);
n_resist    = length(RESISTIVITY);
%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(n_resist,2);
rd_all = cell(n_resist,2);
for iRes  = 1:n_resist
for iPair = 1:2
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    avr.custom_setup_function = @(x,y) helper__changeResistivity(x,y,RESISTIVITY{iRes});
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:n_diameters
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all{iRes,iPair} = temp_cell(1,:);
    rd_all{iRes,iPair} = temp_cell(2,:);
end
end

keyboard
%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%1) Standard, vs amplitude ...
for iPair = 1:2
    subplot(1,2,iPair)
    final_strings = sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs_all{iPair},rd_all{iPair});
    legend(final_strings)
    title(TITLE_STRINGS{iPair})
    set(gca,'YLim',P.Y_LIM);
end

end

function helper__changeResistivity(~,xstim,resistivity)
    xstim.tissue_obj.resistivity = resistivity;
end


