%{
---------------------------------------------------------------------------
                                Event Order
---------------------------------------------------------------------------
Currently the main aspects of event order are handled by the class:
*****   NEURON.simulation.extracellular_stim.event_manager   *********

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