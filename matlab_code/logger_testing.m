%logger_testing

clear_classes
wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 0 0; 200 0 0]);

e = wtf.elec_objs;

log = e.getLogger;

ID = log.find(true);