%
% Testing the tissue. 
%
% Because it is unsure if it is possible to change the tissue
% for a given xstim after its initiation, we will be initiating a new
% simulation for each resistance.
%
%
% see: NEURON.simulation.extracellular_stim.set_Tissue
%       (and the Improvements)

clc
clear_classes

%set.resistivity(obj,value)
%TESTING ONLY ISOTROPIC----------------------------------------------------
%resistivities
% t1_h = 1.2;
% t2_h = 42;
% t3_h = .754;
% t4_h = 75;
% t5_h = 9;
% t6_h = 4;
% t7_h = 54.2;

%TESTING ONLY ANISOTROPIC--------------------------------------------------
%resistivities
% t1_h = [1.2 54.3 29];
% t2_h = [42 75.4  .345];
% t3_h = [.754 2.6 73];
% t4_h = [75 7.34 .05];
% t5_h = [9 73 254]; 
% t6_h = [4 .062 .04];
% t7_h = [54.2 1643 9.3];

%TESTING BOTH TISSUE TYPES-------------------------------------------------
%resistivites
t1_h = [1.2 54.3 29];
t2_h = 42;
t3_h = [.754 2.6 73];
t4_h = 75;
t5_h = [9 73 254]; 
t6_h = [4 .062 .04];
t7_h = 54.2;

%SIMULATIONS---------------------------------------------------------------
%first time sims
sim2 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t2_h);
t2h = sim2.tissue_obj;
log2 = t2h.getLogger;
ID2 = log2.find(true);

sim1 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t1_h);
t1h = sim1.tissue_obj;
log1 = t1h.getLogger;
ID1 = log1.find(true);

sim3 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t3_h);
t3h = sim3.tissue_obj;
log3 = t3h.getLogger;
ID3 = log3.find(true);

sim4 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t4_h);
t4h = sim4.tissue_obj;
log4 = t4h.getLogger;
ID4 = log4.find(true);

%repeating simulations 3 and 1
% JK! Hahaha! Don't do this!  log# is an alias so nothing about this
% statement refers it back to the original tissue...
% 
% ID3a = log3.find(true);
% ID1a = log1.find(true);
log3a = t3h.getLogger;
ID3a = log3.find(true);

log1a = t1h.getLogger;
ID1a = log1.find(true);

%more new simulations
sim5 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t5_h);
t5h = sim5.tissue_obj;
log5 = t5h.getLogger;
ID5 = log5.find(true);

sim6 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t6_h);
t6h = sim6.tissue_obj;
log6 = t6h.getLogger;
ID6 = log6.find(true);

sim7 = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity', t7_h);
t7h = sim7.tissue_obj;
log7 = t7h.getLogger;
ID7 = log7.find(true);

%repeating sims again
log3b = t3h.getLogger;
ID3b = log3b.find(true);

log1b = t1h.getLogger;
ID1b = log1b.find(true);

log5b = t5h.getLogger;
ID5b = log5b.find(true);


%print out values
ID1                 %#ok
ID2                 %#ok
ID3                 %#ok
ID4                 %#ok
ID5                 %#ok
ID6                 %#ok

ID3a                %#ok
ID1a                %#ok

ID3b                %#ok
ID1b                %#ok
ID5b                %#ok


