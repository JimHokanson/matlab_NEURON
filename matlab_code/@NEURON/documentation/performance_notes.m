%{

Code Initializaton:
---------------------------------------------------------------------------
3/18/2013 : 0.22 - 0.3 seconds
1) Hide Window (0.049)
The code spends a lot of time waiting to hide the window. This is most
likely time waiting for the process to start.
2) Read Result (0.094)
Read result is slow. It would be interesting to tease apart NEURON
execution versus java code parsing.
3) MRG props - 0.02 seconds




%}