%{


Threshold sign:

This class relies on comparisons of applied stimuli. One of the problems in
doing this is that there is an infinite # of possible threshold/scaling
combinations that result in the same applied stimulus. To try and help with
this a scale of 1 is recommended for one of the stimuli. This obviously
does not fix the problem but does help. 

Another problem is the sign of stimuli. A negative threshold and a negative
scale is the same as a positive threshold with a positive scale. To
facilitate lookup all thresholds should be positive. Thus if a negative
threshold is being looked for, the applied stimuli should be multipled by
-1 so that a positive multiplier (threshold) can be matched.
For example:

scale = -1, threshold (multipler) = 5, threshold = -5 uA

scale = 1, find a negative threshold
        => given the same conditions, we would find that our negative
        threshold is -5. Now we have two different stimuli that differ
        by being opposites of each other, but they also also have opposite
        threshold values

To remedy this for the negative threshold we multiple the stimulus by -1.
Find that our threshold is 5, and since we multipled the stimulus by -1,
our threshold is -5, which given the scale also refers to a final threshold
of -5 uA


%}