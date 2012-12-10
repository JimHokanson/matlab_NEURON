%{
Extracellular Stim
-----------------------------------------------------------------

An extracellular 


Event Order
-----------------------------------------------------------------

Currently the main aspects of event order are handled by the class:
NEURON.simulation.extracellular_stim.event_manager

1) All relevant objects must be attached to the simulation class. The
include:
- tissue
- electrodes
- cell
2) Create the cell in NEURON
   - In addition, most cells will take this time to populate spatial
   information so that it is available when calculating the applied voltage
   to the cell from the electrodes
3) Setup recording any properties desired, currently just the membrane
potential 


Spatial Organization
------------------------------------------------------------------
For many 


Pathing

%}