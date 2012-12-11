# Matlab <==> NEURON Interface #

This code has the following goals:

1. To allow easier access/modification of NEURON code parameters through Matlab
2. To support code reuse through a (somewhat) organized code base.

At this point the majority of code focuses on modeling extracellular stimulation of a neuron.

## Features: ##

1. Asynchronous bidirectional interface between NEURON and Matlab (Windows only, Mac coming soon)
2. Extracellular stimulation using point source electrodes and homogenous tissue

## Current Issues ##

1. Requires some local functions, nearly complete with extracting dependencies into separate directory for optional install

## Requirements ##

1. Windows - temporary requirement, fixable problem
2. NEURON  - http://www.neuron.yale.edu/neuron/