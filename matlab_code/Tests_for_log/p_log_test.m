% 
% values = {obj.celsius   obj.tstop  obj.dt};
% props  = {'celsius'     'tstop'    'dt'};
%
%Call: changeProps(obj,varargin)
%
%--------------------------------------------------------------------------
clc
clear_classes

c1 = 37;    %original value
c2 = 76;
c3 = 4;
d1 = .005;  %original value
d2 = .076;
t1 = 1.2;   %original value
t2 = 4.3;

%First simulation----------------------------------------------------------
sim1 = NEURON.simulation.extracellular_stim.create_standard_sim();
p1 = sim1.props;
log1 = p1.getLogger;
ID1 = log1.find(true);

changeProps(sim1.props,'dt', d2);                 %c1 d2 t1
log2 = p1.getLogger;
ID2 = log2.find(true);

changeProps(sim1.props,'celsius', c2);            %c2 d2 t1
log3 = p1.getLogger;
ID3 = log3.find(true);

changeProps(sim1.props,'tstop', t2);              %c2 d2 t2
log4 = p1.getLogger;
ID4 = log4.find(true);

%revert back to orginal cases----------------------------------------------
changeProps(sim1.props,'tstop', t1);              %c2 d2 t1
log5 = p1.getLogger;
ID5 = log5.find(true);

changeProps(sim1.props,'celsius', c1);            %c1 d2 t1
log6 = p1.getLogger;
ID6 = log6.find(true);

%create another simulation-------------------------------------------------
sim2 = NEURON.simulation.extracellular_stim.create_standard_sim();
p2 = sim2.props;
log7 = p2.getLogger;
ID7 = log7.find(true);                      %should match ID1

changeProps(sim2.props,'tstop', t2);              %c1 d1 t2
log8 = p2.getLogger;
ID8 = log8.find(true);

changeProps(sim2.props,'dt', d2);                 %c1 d2 t2
log9 = p2.getLogger;
ID9 = log9.find(true);

changeProps(sim2.props,'celsius', c2)             %c2 d2 t2
log10 = p2.getLogger;
ID10 = log10.find(true);                    %should match ID4

%Go back to the first simulation-------------------------------------------
changeProps(sim1.props,'dt', d2);                 %c1 d2 t1
log11 = p1.getLogger;
ID11 = log11.find(true);                    %should match ID2

changeProps(sim1.props,'tstop', t2);              %c1 d2 t2
log12 = p1.getLogger;
ID12 = log12.find(true);                    %should match ID9

changeProps(sim1.props,'celsius', c3);            %c3 d2 t2
log13 = p1.getLogger;
ID13 = log13.find(true);

%Print our values----------------------------------------------------------
ID1                 %#ok
ID2                 %#ok
ID3                 %#ok
ID4                 %#ok
ID5                 %#ok
ID6                 %#ok
ID7                 %#ok
ID8                 %#ok
ID9                 %#ok
ID10                %#ok
ID11                %#ok
ID12                %#ok
ID13                %#ok
