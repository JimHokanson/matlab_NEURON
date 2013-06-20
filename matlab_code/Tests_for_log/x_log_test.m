clear_classes
clc

xyz1 = [-20 90 0; 21090 -70 0];
xyz2 = [-220 90 0; 21090 -70 0];
xyz3 = [1 2 3; 4 5 6];

%MOVING THE ELECTRODES  %==================================================
sim = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',xyz1);
log = sim.getLogger;
mims = log.ID_LOGGER__multi_id_manager;

log.find

sim2 = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',xyz2);
log = sim2.getLogger;
log.find

sim1.elec_objs.movesElectrode(xyz2);
log = sim.getLogger;
log.find

sim1.elec_objs.moveElectrode(xyz3);
log = sim.getLogger;
log.find

%==========================================================================
%CHANGING THE TISSUE  %====================================================
t1_h = [1.2 54.3 29];
t2_h = 42;

sim3 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t1_h);
log = sim3.getLogger;
log.find

sim4 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t2_h);
log = sim4.getLogger;
log.find

sim5 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t1_h);
log = sim5.getLogger;
log.find

%==========================================================================
%CHANGING THE PROPS  %=====================================================

%==========================================================================
%CHANGING THE CELL  %======================================================

%==========================================================================
%CHANGING COMBOS  %========================================================

%==========================================================================
%YAY! IT WORKS! \(^-^)/

