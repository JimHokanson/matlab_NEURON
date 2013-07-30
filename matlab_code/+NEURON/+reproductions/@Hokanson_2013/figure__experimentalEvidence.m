function figure__experimentalEvidence()

C.QUICK_TEST     = false;
C.MERGE_SOLVERS  = true;
C.USE_NEW_SOLVER = true;
C.MAX_STIM       = 30;

%Branner
%--------------------------------------------------------------------------
% Branner et al 2001 (Figure 9)
% - cat sciatic nerve
% - EDL FORCE
% - 200 us per phase, 100 us interphase
% - electrodes 0.89 mm apart (2 sites one way, 1 site the other, which is 
%       not known but I am guessing 2 in the long, 1 in the trans, 
%       Almut didn’t remember.  Larger spacing in the long direction 
%       is more likely if you look at the spatial layout of the array 
%       for figure 6
% - individual amplitudes are at 25% of max force (which for some reason 
%       dual stim exceeds, my guess is due to avoiding co-contraction)
% - sum – 2 N (1 N each), simultaneous about 6, maybe 5.8 or 5.7, ratio is thus 2.8 - 3

[obj,avr] = helper__reinitializeObj(C);

B.EL_LOCATIONS = [-200 -100 -400; 200 100 400];
%Alternatively 
%EL_LOCATIONS = [-400 -50 -200; 400 50 200];
B.WIDTHS     = [0.2 0.1 0.2];
B.AMPLITUDES = [-1 0 1];
B.custom_setup_function = @(x,y)helper__setupBranner(x,y,B);
%Fiber diameter????
%- See Fig 3d Boyd and Davey, Composition of Peripheral Nerves
B.FIBER_DIAMETER = 12.8;

avr.custom_setup_function = B.custom_setup_function;
avr.fiber_diameter        = B.FIBER_DIAMETER;

rs_b = avr.makeRequest(B.EL_LOCATIONS,C.MAX_STIM,...
            'single_with_replication',true);
rd_b = avr.makeRequest(B.EL_LOCATIONS,C.MAX_STIM);       

keyboard

%Rutten
%--------------------------------------------------------------------------
% Rutten et al 1991 
% -	EDL muscle rat
% -	pg 195 discusses result, pg 196 has figure 3
% -	150 um interdistance between electrodes
% - electrodes spaced transversly
% -	0.13 N combined, 0.02 N alone, EDL isometric force
% -	Maximum EDL force 0.7 N
% -	Lowest attainable force 0.002 to 0.015, they are probably 
%   single motor unit levels (18)
% -	100 us pulse width
% -	Unspecified stimulus current amplitude

[obj,avr] = helper__reinitializeObj(C);
R.EL_LOCATIONS = [-75 0 0; 75 0 0];
R.STIM_WIDTHS  = 0.2;
R.PHASE_AMPLITUDES = -1;
R.FIBER_DIAMETER = 10; %Source 14 in paper

avr.fiber_diameter   = R.FIBER_DIAMETER;
avr.stim_widths      = R.STIM_WIDTHS;
avr.phase_amplitudes = R.PHASE_AMPLITUDES;

rs_r = avr.makeRequest(R.EL_LOCATIONS,C.MAX_STIM,...
            'single_with_replication',true);
rd_r = avr.makeRequest(R.EL_LOCATIONS,C.MAX_STIM);      


%Yoshida
%--------------------------------------------------------------------------
% Yoshida et al 1993
% -	Gastrocnemius muscle, cat
% -	Two LIFEs, single fascicle
% -	At short pulse widths, the ratio is higher, as an example, 
%   around 500 us, we see a simultaneous force of roughly 6N, and a 
%   combined force of around 1 N (600%), (NOTE: We should be able to see 
%   this effect that at smaller pulse widths, the effect is more pronounced
% -	At longer values we get roughly 3N for summed and 6 for simultaneous, 
%   so a volume ratio of 200%
% -	NOTE: Our model would not exceed the point where Sum A + B goes above 
%   A & B, rr. (at least in our analysis), since this indicates that 
%   stimulation from A and stim from B are activating some of the same 
%   neurons, and that these neurons are not double counted when using 
%   the refractory technique.
% -	They say that on average the simultaneous was 63% larger than 
%   refractory, data in Figure 3 does not support this claim …
% -	These electrodes are confusing and not point sources. They might be 
%   more susceptible to this effect since they have such a large area of 
%   tissue between the exposed surfaces of the two electrodes.
% -	Unspecified stimulus current amplitude




end

function [obj,avr] = helper__reinitializeObj(C)
obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = C.QUICK_TEST;
%avr.merge_solvers  = C.MERGE_SOLVERS;
avr.use_new_solver = C.USE_NEW_SOLVER;
end

function helper__setupBranner(~,xstim)
%Change stimulus

xstim.elec_objs.setStimPattern(0.1,B.WIDTHS,B.AMPLITUDES);

end