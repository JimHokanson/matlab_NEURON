function p_cell = gridfit_test
%gridfit testing
%
%   p_cell = NEURON.reproductions.Hokanson_2013.gridfit_test
%
%   Written for Ivana's presentation
%   Eventually we will build in a testing framework

import NEURON.reproductions.*


STIM_SIGN = 1;
EL_LOCATIONS = [-200 0 0; 200 0 0];

obj = Hokanson_2013;

%Step 1: Create xstim object ...

%Change fiber diameter?
%Change electrode locations??


xstim = obj.instantiateXstim(EL_LOCATIONS);

%Step 2: Initialize request handler
rh  = NEURON.xstim.single_AP_sim.request_handler(xstim,STIM_SIGN);

%Step 3: Initialize system tester
%----------------------------------------------
st = NEURON.xstim.single_AP_sim.system_tester;

%This can be used to pass in specific data points ...
ldo = rh.getLoggedDataObject;

%NOTE: We can edit st to use different training locations

n_approaches = 3;

p_cell = cell(1,n_approaches);
for iApproach = 1:n_approaches
    
    %Change things here that we want to be different between the different
    %methods ...
    switch iApproach
        case 1           
        case 2
           rh.solver.predicter =  NEURON.xstim.single_AP_sim.gridPredictor(rh.solver);
        case 3            
           rh.solver.grouper =  NEURON.xstim.single_AP_sim.gridPredictor(rh.solver);
    end
    rng(1) %This should be an input
    p_cell{iApproach} = rh.runTester(st);
end

%  figure; hold all; 
%  plot(p_cell{1}.threshold_prediction_error);
%  plot(p_cell{2}.threshold_prediction_error);
%  plot(p_cell{3}.threshold_prediction_error);
 

%Moving average filter of threshold errors
p1 = p_cell{1};
p2 = p_cell{2};
p3 = p_cell{3};
% plot(abs(p1.threshold_prediction_error))
figure; hold all
B = 1./100*ones(1,100);
A = 1;
temp1 = filter(B,A,abs(p1.threshold_prediction_error));
temp2 = filter(B,A,abs(p2.threshold_prediction_error));
temp3 = filter(B,A,abs(p3.threshold_prediction_error));
plot(temp1,'b','Linewidth',2)
plot(temp2,'r','Linewidth',2)
plot(temp3,'g','Linewidth',2)
set(gca, 'FontSize', 18 )
xlabel('Threshold Index','FontSize', 18)
ylabel('Percent Error', 'FontSize', 18)

