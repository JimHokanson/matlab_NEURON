%Goals
%{

%MATCHING PREVIOUS RESULTS
%==========================================================================
1) For a given simulation, find relevant log
    1.1) stimulus matching
            - write stimulus equivalency tests ...
    NOTE: For each solution we can save the generating stimulus but only 
    the duration matters, not the number of electrodes as this gets encoded
    into the spatial variation of the stimulus
    1.2) cell morphology and parameter equivalency tests .... Yikes!
    1.3) cell dynamics equivalencies Double Yikes!

MAIN GOAL: Be able to find data that is relevant to current stimulation

%STORAGE
%==========================================================================
%NOTE: Ideally this would be moved to a database backend ...


%Level 1) matching previous simulation type
%Level 2) applied voltages and results ..., might store more info on stimulus
electrodes as this would allow us to recreate everything, as the other
information in the simulation is used to distinguish between matrices, and
only the stimulation setup (oh, and tissue paramaters) are not saved in the
file



%METHODS
%==========================================================================
%1) Merge testing results ...
%   - given top level results, merge simulations ...


Questions:
1) What to record? Just the applied voltage?
    - if we record voltage and differences, this might make distance
    comparision more difficult (or it might not)
2) How to handle positional variation?
    Given a trained model, we can easily test many different positions
    simultaneously like Peterson et al 2011, however when training it is
    unclear which of these to keep ...
3) Can we truncate the applied voltage? This might allow circular shifting
to maximally align things. Alternatively it would be great to have a
circular shift maximal alignment mechanism for high dimensional data ....
4) 

%}