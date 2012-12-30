%{

SIM LOGGER DESIGN NOTES

USAGE OUTLINE
---------------------------------------------------------------------------
1) Load all previously recorded data
2) Enable simulation logging
    - try

NEW OUTLINE
1) Lookup Current Setup
2) Get threshold for subset - and log
3) Predict threshold for subset - no logging


QUESTIONS
---------------------------------------------------------------------------
1) How can we prevent things from changing when doing a log?
    - Do we need to provide a handle to the objects?
    - How can we lock out any property changes?????

The main concern is that we'll run some simulations on one data set, and
then switch and start running on another data set, and then not realize it.
CURRENT SOLUTION: Have a function interface whose first step is matching
the log, and then everything in that function is controlled.
=> like the activation volume solver

%}