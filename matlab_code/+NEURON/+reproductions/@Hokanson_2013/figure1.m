function figure1()
%
%   NEURON.reproductions.Hokanson_2013.figure1
%
%   =======================================================================
%                       MULTIPLE ELECTRODE DISTANCES
%   =======================================================================
%
%   This method examines the volume-ratio for a range of distances and
%   amplitudes for a single fiber diameter. It is meant to provide insight
%   into what stimulus separations are acceptable

import NEURON.reproductions.*

P.Y_LIM = [0.5 4];

C.MAX_STIM_TEST_LEVEL      = 30;
C.FIBER_DIAMETER           = 15;

TITLE_STRINGS = {'Longitudinal pairings' 'Transverse pairings' 'Utah Array Long'};
%EL_INDICES    = {15:-1:9    8:-1:2};
%EL_INDICES    = {23:-1:17    8:-1:2};
EL_INDICES    = {[23:-1:17 24]  [8:-1:2 25] [15:-1:9 26]};
SLICE_DIMS    = {'xz' 'xz' 'xz'};

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.fiber_diameter = C.FIBER_DIAMETER;

avr.quick_test     = false;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,3);
rd_all = cell(1,3);
for iPair = 1:3
    electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(EL_INDICES{iPair});
    
    avr.slice_dims = SLICE_DIMS{iPair};
    
    rs_all{iPair}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
        'single_with_replication',true);
    rd_all{iPair}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
end

%Temporary code I'm working on ...
% cur_rs = rd_all{1}{4};
% IJK = NEURON.sl.xyz.locationsToIndices(cur_rs.electrode_locations,cur_rs.xyz_used);
% [a,b,c] = NEURON.reproductions.Hokanson_2013.minPathValue(cur_rs.raw_abs_thresholds, IJK(1,:), IJK(2,:));

%Plotting results
%--------------------------------------------------------------------------
figure(60)
new_order = [2 1 3];
for iPair = 1:3
    subplot(1,3,iPair)
    cur_I = new_order(iPair);
    
    electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(EL_INDICES{cur_I});
    
    final_strings = obj.getElectrodeSeparationStrings(electrode_locations_test);
    
    %Change to: versus amplitude ...
    obj.plotVolumeRatio(rs_all{cur_I},rd_all{cur_I});
    legend(final_strings)
    title(TITLE_STRINGS{cur_I})
    set(gca,'YLim',P.Y_LIM);
end

end