function BrannerTest()
%
%   NEURON.reproductions.Hokanson_2013.BrannerTest
%
%   =======================================================================
%                       MULTIPLE ELECTRODE DISTANCES
%   =======================================================================
%
%   Code modified from figure1.m to test a specific electrode configuration



import NEURON.reproductions.*

%trans, depth, long

%800 long, 400 trans, 200 for depth (not used in 0.89 calculation we think)
ELECTRODES_TEST =  [-200   -100   -400;  200  100   400];

P.Y_LIM = [0.5 4];

C.MAX_STIM_TEST_LEVEL      = 20; %Reduced
C.FIBER_DIAMETER           = 14;

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
rs_all = cell(1,1);
rd_all = cell(1,1);
for iPair = 1:1
    %electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(EL_INDICES{iPair});
    
    avr.slice_dims = SLICE_DIMS{iPair};
    
    rs_all{iPair}  = avr.makeRequest(ELECTRODES_TEST,C.MAX_STIM_TEST_LEVEL,...
        'single_with_replication',true);
    rd_all{iPair}  = avr.makeRequest(ELECTRODES_TEST,C.MAX_STIM_TEST_LEVEL);
end

%Temporary code I'm working on ...
% cur_rs = rd_all{1}{4};
% IJK = NEURON.sl.xyz.locationsToIndices(cur_rs.electrode_locations,cur_rs.xyz_used);
% [a,b,c] = NEURON.reproductions.Hokanson_2013.minPathValue(cur_rs.raw_abs_thresholds, IJK(1,:), IJK(2,:));

%Plotting results
%--------------------------------------------------------------------------
keyboard
figure(61)

for iPair = 1:1
    
    electrode_locations_test = {ELECTRODES_TEST};
    
    final_strings = obj.getElectrodeSeparationStrings(electrode_locations_test);
    
    %Change to: versus amplitude ...
    obj.plotVolumeRatio(rs_all,rd_all);
    legend(final_strings)
    title(TITLE_STRINGS{cur_I})
    set(gca,'YLim',P.Y_LIM);
end

%[~,I] = max(vol_ratio)
%  x_axis(I);
%  vol_ratio(I);

%2.1 ratio
%14.6 uA

end