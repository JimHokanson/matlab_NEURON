function gridfit_test
%gridfit testing
%
%   NEURON.reproductions.Hokanson_2013.gridfit_test
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



keyboard


for iApproach = 1:n_approaches
    
    %Change things here that we want to be different between the different
    %methods ...
%     switch iApproach
%         case 1
%            rh  = NEURON.xstim.single_AP_sim.request_handler(xstim,STIM_SIGN);
%         case 2
%            rh  = NEURON.xstim.single_AP_sim.request_handler(xstim,STIM_SIGN);
%     end
    
    predictor_info = rh.runTester(st);
    
end

