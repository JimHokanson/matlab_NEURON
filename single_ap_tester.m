wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 0 0]);
r = wtf.sim__getSingleAPSolver();
s = r.getSolution({-200:20:200 -200:20:200 -700:20:700});

%31311
%9518 remaining