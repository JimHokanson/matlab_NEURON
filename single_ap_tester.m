wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 -50  -200; 200 50 200]);
r = wtf.sim__getThresholdsMulipleLocations2({-200:20:200 -200:20:200 -700:20:700});
r.getSolution

%31311
%9518 remaining