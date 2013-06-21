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

sim.elec_objs.moveElectrode(xyz2);
log = sim.getLogger;
log.find

sim.elec_objs.moveElectrode(xyz3);
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

sim6 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', 700);
log = sim6.getLogger;
log.find

%==========================================================================
%CHANGING THE PROPS  %=====================================================
d1 = .005;  %original value
d2 = .076;

sim7 = NEURON.simulation.extracellular_stim.create_standard_sim();
log = sim7.getLogger;
log.find

changeProps(sim7.props,'dt', d2);                 
log = sim7.getLogger;
log.find

changeProps(sim7.props,'dt', d1);                 
log = sim7.getLogger;
log.find
%==========================================================================
%CHANGING THE CELL  %======================================================
cell = sim7.cell_obj;
cell.props_obj.changeFiberDiameter(8.7);
log = sim7.getLogger;
log.find


%==========================================================================
%CHANGING COMBOS  %========================================================

%==========================================================================
%YAY! IT WORKS! \(^-^)/


