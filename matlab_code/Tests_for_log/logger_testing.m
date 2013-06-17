%logger_testing

clear_classes
wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 0 0; 200 0 0]);

e = wtf.elec_objs;

log = e.getLogger;

ID = log.find(true);

sim = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-280 910 90; 90 140 10]);
e4 = sim.elec_objs;
log4 = e4.getLogger;
ID4 = log.find(false);

new = [-280 910 90; 90 140 10];
e.moveElectrode(new);
log6 = e.getLogger;
ID6 = log6.find(true);