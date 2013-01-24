%{


---------------------------------------------------------------------------
                         NEURON DIRECTORY ORDER
---------------------------------------------------------------------------
1) On loading the simulation, the functions defined for NEURON are loaded
2) On defining the cell, the 

---------------------------------------------------------------------------
                                Event Order
---------------------------------------------------------------------------
Currently the main aspects of event order are handled by the class:

1) Simulation is initiated. At this point in time the simulation variables
are declared.

2) All relevant objects must be attached to the simulation class. These
include:
    - tissue
    - electrodes
    - cell

3) Before running any simulation, the following method is called:
NEURON.simulation.extracellular_stim.init__simulation

This method runs through the following steps:
---------------------------------------------------------------------------

4) Verification of assigned objects

5) Threshold Info from the cell is transfered to the threshold analysis
object

6) Creation of the cell in NEURON

   Most cells will take this time to populate spatial information so that
   it is available when calculating the applied voltage to the cell from
   the electrodes.





3) Setup recording any properties desired, currently just the membrane
potential is automatically setup for recording ...

4) Create the stimulation info
    NEURON.simulation.extracellular_stim.init__create_stim_info
    
5) Load the stimulation info into NEURON. Note, this does not apply the
stimulus, as it needs to be scaled first before applying it.
    xstim__load_data.hoc
    xstim__setup_stim_playback.hoc

Running the stimulation
-------------------------------------------------
xstim__run_stimulation.hoc

6) Setup the actual stimulus to be applied during the simulation


7) Run the simulation

8) Get and analyze results

NOTE: Steps 6 - 8 may be repeated with different stimulus amplitudes
without repeating steps 1 - 5





%}