function figure3_new()
%
%   NEURON.reproductions.Hokanson_2013.figure3_new
%
%   =======================================================================
%                       Ratio of thresholds
%   =======================================================================
%
%   This bit of code examines the ratio of the change in appplied voltage
%   and compares that to the change in the threshold at a given location.
%
%   NOTE: This not yet included in the current version of the paper
%

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 3];


%NOTE: We might want to increase this for the plot ...
C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
%avr.merge_solvers  = true;
avr.use_new_solver = true;

TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};
SLICE_DIMS    = {'xz' 'xz'}; %NOTE: Both slices are now in xz, since no y variation is present
%EL_LOCATIONS = {[0 -50 -200; 0 50 200]      [-200 0 0;200 0 0]};
EL_LOCATIONS = {[0 0 -200; 0 0 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = 10;

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

keyboard
%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

s_long_slice  = rs_all{1}{1}.replicated_slice;
s_trans_slice = rs_all{2}{1}.replicated_slice;

d_long_slice  = rd_all{1}{1}.slice;
d_trans_slice = rd_all{2}{1}.slice;

all_slices = [s_long_slice s_trans_slice d_long_slice d_trans_slice];

x_min_all = zeros(1,4);
x_max_all = zeros(1,4);
z_min_all = zeros(1,4);
z_max_all = zeros(1,4);

for iSlice = 1:4
    cur_slice = all_slices(iSlice);
    x_min_all(iSlice) = min(cur_slice.xyz{1});
    x_max_all(iSlice) = max(cur_slice.xyz{1});
    z_min_all(iSlice) = min(cur_slice.xyz{2});
    z_max_all(iSlice) = max(cur_slice.xyz{2});
end

%Single +/- 420 x
%double , 860, 700 x -> need to remove indices

X_LIMIT = 420;

all_data = cell(1,4);

for iSlice = 1:4
    cur_slice = all_slices(iSlice);
    data = cur_slice.thresholds;
    x_data = cur_slice.xyz{1};
    
    if iSlice == 1
    z_data_plot = cur_slice.xyz{2};
    x_data_plot = x_data;
    end
    I1 = find(x_data == -1*X_LIMIT);
    I2 = find(x_data == X_LIMIT);
    all_data{iSlice} = data(I1:I2,:);
end

s_long_final = all_data{1}';
d_long_final = all_data{3}';

ratio_long = d_long_final./s_long_final;
ratio_long(ratio_long > 1) = 1;

subplot(2,2,2)
imagesc(x_data_plot,z_data_plot,ratio_long);
colorbar
axis equal
title('Sim./Ind., Long')

s_trans_final = all_data{2}';
d_trans_final = all_data{4}';

ratio_trans = d_trans_final./s_trans_final;
ratio_trans(ratio_trans > 1) = 1;

subplot(2,2,4)
imagesc(x_data_plot,z_data_plot,ratio_trans);
colorbar
axis equal
title('Sim./Ind., Trans')

all_voltages = NEURON.reproductions.Hokanson_2013.addVoltage;

STEP_SIZE = 1;

temp_long = ratio_long(1:STEP_SIZE:end,1:STEP_SIZE:end)';
c_long = corr(all_voltages{1}(:),temp_long(:));

temp_trans = ratio_trans(1:STEP_SIZE:end,1:STEP_SIZE:end)';
c_trans = corr(all_voltages{2}(:),temp_trans(:));

fprintf(2,'c_long %0.3f, c_trans %0.3f\n',c_long,c_trans);



end