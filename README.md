# Matlab <==> NEURON Interface #

This code has the following goals:

1. To allow easier access/modification of NEURON code parameters through Matlab
2. To support code reuse through a (somewhat) organized code base.

At this point the majority of code focuses on modeling extracellular stimulation of a neuron.

## Features: ##

1. Bidirectional interface between NEURON and Matlab.
2. Extracellular stimulation using point source electrodes and homogenous tissue (isotropic or anisotropic)

## Current Issues ##

1. Installation in Matlab takes a bit of effort. I have plans to clean this up.

## Requirements ##

1. NEURON  - http://www.neuron.yale.edu/neuron/

## Future Design Plans ##

1. Create NEURON class analogs in Matlab for exploring common NEURON objects - sectionlist, list, section
2. Implement intracellular stim. simulations

## Other Smaller TODOs ##

1. Create a method to reload NEURON hoc library
2. Selectively load library given simulation type