# Matlab <==> NEURON Interface #

This code has the following goals:

1. To allow easier access/modification of NEURON code parameters through Matlab
2. To support code reuse through a (somewhat) organized code base.

At this point the majority of code focuses on modeling extracellular stimulation of a neuron.

## Features: ##

1. Bidirectional interface between NEURON and Matlab.
2. Extracellular stimulation using point source electrodes and homogenous tissue (isotropic or anisotropic)

## Installation ##

1. Make sure NEURON is installed
2. Copy the Example_Options.txt over into a new file options.txt (same directory) and change the values for your system. Eventually I'd like to have a GUI which helps with this.
3. Run the initialization script 'intialize.m'. I put this in my startup.m script. Example: run('C:\repos\matlab_git\matlab_NEURON\initialize.m')
4. Compile NEURON mechanisms
4. TODO: Finish this ...

## Current Issues ##

1. Matlab keeps local information regarding properties rather than dynamically reading and writing them to NEURON. This saves times but also means one needs to be careful about values getting stale if set elsewhere

## Requirements ##

1. NEURON  - http://www.neuron.yale.edu/neuron/
2. Curve Fitting Toolbox

## Future Design Plans ##

1. Create NEURON class analogs in Matlab for exploring common NEURON objects - sectionlist, list, section
2. Implement intracellular stim. simulations

## Other Smaller TODOs ##

1. Create a method to reload NEURON hoc library
2. Selectively load library given simulation type