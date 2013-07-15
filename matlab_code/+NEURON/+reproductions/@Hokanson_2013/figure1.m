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

C.MAX_STIM_TEST_LEVEL      = 30;
C.FIBER_DIAMETER           = 15;

TITLE_STRINGS = {'Transverse pairings'  'Longitudinal pairings'};
EL_INDICES    = {15:-1:9    8:-1:2};

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.fiber_diameter = C.FIBER_DIAMETER;

avr.quick_test     = true;
avr.merge_solvers  = true;
% avr.use_new_solver = true;

%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(1,2);
rd_all = cell(1,2);
for iPair = 1:2
    electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(EL_INDICES{iPair});
    
    rs_all{iPair}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
        'single_with_replication',true);
    rd_all{iPair}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
end

keyboard
%Plotting results
%--------------------------------------------------------------------------
for iPair = 1:2
    
    electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(EL_INDICES{iPair});
    
    final_strings = obj.getElectrodeSeparationStrings(electrode_locations_test);
    
    %Change to: versus amplitude ...
    obj.plotVolumeRatio(rs_all{iPair},rd_all{iPair},false);
    legend(final_strings)
    title(TITLE_STRINGS{iPair})
end

end