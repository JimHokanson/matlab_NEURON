%xstim_single_ap_solver

wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 0 0]);

thresholds = wtf.sim__getThresholdsMulipleLocations2({-200:20:200 -200:20:200 -700:20:700});