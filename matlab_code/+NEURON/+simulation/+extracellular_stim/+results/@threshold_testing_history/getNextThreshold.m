function getNextThreshold(obj)
%Threshold

%This method will handle balancing the next stimulus to test with
%the evidence present so far from the simulation ...

%NOTE: After thinking about this, I think I will delay this until we do
%field testing at more than one site => volume testing ...

%NOTE: This could significantly help in cases where we are hovering way
%below threshold

%{
Cases to handle:
---------------------------------------------------------------------------
1) Trying to get upper bound:
    - Close to threshold, increase would place threshold way above expected value 
    - increase would place threshold way below expected value

%POSSIBLE ERROR SOURCES:
%1) max vm already observed with no fired ap - note, we
%should track max vm of non-firing
%NOTE: In general we want to 

%HARDCODED STUFF PRESENT FOR NOW

%How to respond to used values:
%1) value causes ap, then what?
%2) value doesn't cause ap
%    - what membrane potential was observed ????
%        - was it higher or lower than expected????

%How do we benefit?

%Is this different if we are bounded?????
%1) Low bound hit, need uppper bound
%        - provide target, maybe +10 mV or +20 mV
%        
%2) Lower and upper bound determined
%    -> lower bound 

%Rule 1:
%Given tests, and next test
%



%}