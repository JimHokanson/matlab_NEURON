%{

NOTES ON STIMULUS AMPLITUDE
===========================================================================
The concept of stimulation current amplitude is all relative in this
framework. The problem arises when referring to a stimulation in terms of a
fixed stimulus amplitude. 

Even for a  single electrode, we almost never use a single current amplitude due to
biphasic stimulation. For example, we might stimulate at 3 uA, but what we
really might mean is -3 uA followed by 3 uA for charge balancing.
Alternatively we might stimulate at -3 uA followed by 1.5 uA with twice the
duration, but we report that all as 3 uA. 

Things get more complicated with multiple electrodes. We might have a
single electrode at a given stimulus level, with two other electrodes
stimulating at half of the stimulus level of the first. In these cases it
is unclear what a stimulus amplitude means unless described in the context
of the setup.

The solver will solve for threshold using a
single factor which is multiplied by the SCALES (property .scale) of all electrodes before
they are applied. 

For example: To represent a -3 uA current, followed by a 1.5 uA current, we
will typically enter the scale property for the electrode as:

scale = [-1 0.5]

During stimulation testing we will apply a stimulus level in the simulator
of 3. This will apply our desired stimulus level. We could alternatively
have flipped the signs of the scale, but then our stimulus level would be
-3, which is fine, maybe a little bit more accurate at first passing, but
is also not how we refer to stimulation amplitudes in discussing. In other
words, we tend to discuss positive stimulation amplitudes which are
actually negative stimuli. Again, it all comes back to explaining the
actual stimulation setup.


%}