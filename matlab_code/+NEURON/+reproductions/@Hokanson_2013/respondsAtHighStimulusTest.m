function respondsAtHighStimulusTest()
%
%   NEURON.reproductions.Hokanson_2013.respondsAtHighStimulusTest

STEP_SIZE  = 20;
STIM_SCALE = 50;

%We'll take advantage of the symmetry
Y_TEST_MAX = 800;
Y_TEST_MIN = 0;
X_MIN = 0;
X_MAX = 200;
XYZ_MESH_SINGLE = {X_MIN:STEP_SIZE:X_MAX 0 Y_TEST_MIN:STEP_SIZE:Y_TEST_MAX};

%TEST 1 - SINGLE ELECTRODE ------------------------------------------------
obj          = NEURON.reproductions.Hokanson_2013;
options = {...
    'electrode_locations',[0 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

x_locations = XYZ_MESH_SINGLE{1};
z_locations = XYZ_MESH_SINGLE{3};

nX = length(x_locations);
nZ = length(z_locations);

fired_matrix = false(nX,nZ);
tissue_fried = false(nX,nZ);

t = tic;
for iX = 1:nX
    fprintf('%d/%d\n',iX,nX)
    for iZ = 1:nZ
        xstim_obj.cell_obj.moveCenter([x_locations(iX),0,z_locations(iZ)])
        temp = xstim_obj.sim__single_stim(STIM_SCALE);
        fired_matrix(iX,iZ) = temp.ap_propagated;
        tissue_fried(iX,iZ) = temp.tissue_fried;
    end
end
toc(t)

keyboard

figure
colormap([0 0.5 0; 0.25 1 0.25])
subplot(1,3,1)
imagesc(x_locations,z_locations,fired_matrix')
axis equal
title(sprintf('Tissue responded at %d\n',STIM_SCALE));

subplot(1,3,2)
imagesc(x_locations,z_locations,tissue_fried')
axis equal
title(sprintf('Tissue fried at %d\n',STIM_SCALE));

subplot(1,3,3)
imagesc(x_locations,z_locations,(tissue_fried | fired_matrix)')
axis equal
title(sprintf('Tissue fried or responded %d\n',STIM_SCALE));



%TEST 2 - DOUBLE ELECTRODE ------------------------------------------------
