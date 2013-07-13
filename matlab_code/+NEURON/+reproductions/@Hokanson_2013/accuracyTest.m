function accuracyTest(obj)
%
%
%   NEURON.reproductions.Hokanson_2013.accuracyTest

STEP_SIZE  = 10; %Twice the resolution, we'd expect poorer response
%to come at the halfway point between the other solved values ...

%We'll take advantage of the symmetry
Y_TEST_MAX = 800;
Y_TEST_MIN = 0;
X_MIN = 0;
X_MAX = 200;
XYZ_MESH_SINGLE = {X_MIN:STEP_SIZE:X_MAX 0 Y_TEST_MIN:STEP_SIZE:Y_TEST_MAX};
XYZ_MESH_DOUBLE = {-0:STEP_SIZE:400 0 Y_TEST_MIN:STEP_SIZE:Y_TEST_MAX};


%TEST 1 - SINGLE ELECTRODE ------------------------------------------------
obj          = NEURON.reproductions.Hokanson_2013;
options = {...
    'electrode_locations',[0 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

temp = xstim_obj.sim__getThresholdsMulipleLocations(XYZ_MESH_SINGLE);

helper__plotResults(temp,XYZ_MESH_SINGLE)

%TEST 2 - DOUBLE ELECTRODE ------------------------------------------------
obj          = NEURON.reproductions.Hokanson_2013;
options = {...
    'electrode_locations',[-200 0 0; 200 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

temp = xstim_obj.sim__getThresholdsMulipleLocations(XYZ_MESH_DOUBLE);

helper__plotResults(temp,XYZ_MESH_DOUBLE)



keyboard

end

function helper__plotResults(temp,XYZ_MESH)

results_2d = squeeze(temp)';
imagesc(results_2d);
axis equal

results_2d_low_res = results_2d(1:2:end,1:2:end);
missing_values     = results_2d(2:2:end,2:2:end);

sz = size(results_2d);

x_o = 1:2:sz(1);
y_o = 1:2:sz(2);
x_i = 2:2:sz(1);
y_i = 2:2:sz(2);
interp_missing = interp2(x_o,y_o',results_2d_low_res',x_i,y_i')';

d = interp_missing - missing_values;


x_plot = XYZ_MESH{1}(y_i);
y_plot = XYZ_MESH{3}(x_i);

figure
subplot(1,2,1)
imagesc(x_plot,y_plot,d)
title('Absolute error by spatial layout')
axis equal
subplot(1,2,2)
plot(d(:))
title('Absolute error of all elements plotted')

end