clc
clear_classes

xyz1    =   [-200 0 0; -200 -70 0];
xyz2    =   [-280 910 90; -70 140 10];
xyz3    =   [-200 10 10; -270 10 10];
xyz4    =   [4 5 6; -1 2 7];
xyz5    =   [1 2 3; -4 5 7];
xyz6    =   [12 41 6; -43 7432 13];
xyz7    =   [-12 41 6; -43 7432 13];
xyz8    =   [0 0 0; 0 -1 7];
xyz9    =   [1 1 1; -674, 78, 97];

%FIRST SIMULATION----------------------------------------------------------
sim = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',xyz1);
e1 = sim.elec_objs;
log1 = e1.getLogger;
ID1 = log1.find(true);

e1.moveElectrode(xyz2);
log2 = e1.getLogger;
ID2 = log2.find(true);

e1.moveElectrode(xyz3);
log3 = e1.getLogger;
ID3 = log3.find(true);

e1.moveElectrode(xyz4);
log4 = e1.getLogger;
ID4 = log4.find(true);

%SECOND SIMULATION---------------------------------------------------------
sim2 = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',xyz5);
e2 = sim2.elec_objs;
log5 = e2.getLogger;
ID5 = log5.find(true);

e2.moveElectrode(xyz6);
log6 = e2.getLogger;
ID6 = log6.find(true);

e2.moveElectrode(xyz2);
log7 = e2.getLogger;
ID7 = log7.find(true);

%MOVING BACK TO FIRST SIM -------------------------------------------------
e1.moveElectrode(xyz7);
log8 = e1.getLogger();
ID8 = log8.find(true);

e1.moveElectrode(xyz8);
log9 = e1.getLogger;
ID9 = log9.find(true);

%MOVING BACK TO SECOND SIM ------------------------------------------------
e2.moveElectrode(xyz2);
log10 = e2.getLogger;
ID10 = log10.find(true);

e2.moveElectrode(xyz1);
log11 = e2.getLogger;
ID11 = log11.find(true);

e2.moveElectrode(xyz9);
log12 = e2.getLogger;
ID12 = log12.find(true);

%COMPARING IDs-------------------------------------------------------------

%NOTE
%in any case where we have just moved the electrode the logger should be
%the same so any moves or changes should propagate e.g: log1-4 is the same
%and log5-7 is the same

%Question what will the IDs be?
% In theory ID2 == ID7.
% What will the n_trials read? 4 & 3?
%WHAT ON EARTH HAS TAKEN THE PLACE OF THE SECOND SIMULATION??????

ID1
ID2
ID3
ID4
ID5
ID6
ID7
ID8
ID9
ID10
ID11
ID12


% log9
% log7
% log10
% log12
